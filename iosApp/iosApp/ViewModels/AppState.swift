import Foundation
import Shared

@MainActor
final class AppState: ObservableObject {
    @Published var activeCaseId: String? = nil
    @Published var activeCase: Case? = nil

    @Published var selectedCase: Case? = nil
    @Published var selectedRecordTableWrapper: RecordTableViewModelWrapper? = nil

    let provider: RepositoryProvider
    private let endAnesthesiaUsecase: EndAnesthesiaUsecase
    private let deleteCaseUsecase: DeleteCaseUsecase
    private let syncCatalogFromSeedUsecase: SyncCatalogFromSeedUsecase

    let caseListWrapper: CaseListViewModelWrapper
    let caseSetupWrapper: CaseSetupViewModelWrapper
    let procedureCatalogWrapper: CatalogPickerViewModelWrapper
    @Published var monitoringWrapper: MonitoringViewModelWrapper?

    init() {
        let driverFactory = DatabaseDriverFactory()
        let database = DatabaseFactory(driverFactory: driverFactory).create()
        let provider = SqlDelightRepositoryProvider(database: database)
        self.provider = provider
        self.endAnesthesiaUsecase = EndAnesthesiaUsecase(
            caseRepository: provider.caseRepository(),
            timeProvider: SystemTimeProvider()
        )
        self.deleteCaseUsecase = DeleteCaseUsecase(
            caseRepository: provider.caseRepository(),
            vitalRecordRepository: provider.vitalRecordRepository()
        )
        let observeCatalogItemsUsecase = ObserveCatalogItemsUsecase(
            catalogRepository: provider.catalogRepository()
        )
        self.syncCatalogFromSeedUsecase = SyncCatalogFromSeedUsecase(
            catalogRepository: provider.catalogRepository(),
            timeProvider: SystemTimeProvider()
        )

        self.caseListWrapper = CaseListViewModelWrapper(
            viewModel: CaseListViewModel(
                observeCaseListUsecase: ObserveCaseListUsecase(caseRepository: provider.caseRepository()),
                scope: nil
            )
        )
        self.caseSetupWrapper = CaseSetupViewModelWrapper(
            viewModel: CaseSetupViewModel(
                startCaseUsecase: StartCaseUsecase(
                    caseRepository: provider.caseRepository(),
                    idGenerator: RandomIdGenerator(),
                    timeProvider: SystemTimeProvider()
                ),
                scope: nil
            )
        )
        self.procedureCatalogWrapper = CatalogPickerViewModelWrapper(
            viewModel: CatalogPickerViewModel(
                kind: CatalogKind.procedure,
                observeCatalogItemsUsecase: observeCatalogItemsUsecase,
                addCustomCatalogItemUsecase: AddCustomCatalogItemUsecase(
                    catalogRepository: provider.catalogRepository(),
                    idGenerator: RandomIdGenerator(),
                    timeProvider: SystemTimeProvider()
                ),
                scope: nil
            )
        )
        syncCatalogSeed()
    }

    func prepareNewCase() {
        activeCaseId = nil
        activeCase = nil
        selectedCase = nil
        monitoringWrapper = nil
        selectedRecordTableWrapper = nil
    }

    func startSession(caseInfo: Case) {
        activeCaseId = caseInfo.id
        activeCase = caseInfo
        monitoringWrapper = MonitoringViewModelWrapper(
            viewModel: MonitoringViewModel(
                caseId: caseInfo.id,
                caseStartTimeMillis: caseInfo.startTime.toEpochMilliseconds(),
                saveVitalsUsecase: SaveVitalsUsecase(
                    vitalRecordRepository: provider.vitalRecordRepository(),
                    idGenerator: RandomIdGenerator(),
                    timeProvider: SystemTimeProvider()
                ),
                getLatestVitalRecordUsecase: GetLatestVitalRecordUsecase(
                    vitalRecordRepository: provider.vitalRecordRepository()
                ),
                observeVitalRecordsUsecase: ObserveVitalRecordsUsecase(
                    vitalRecordRepository: provider.vitalRecordRepository()
                ),
                timeProvider: SystemTimeProvider(),
                scope: nil
            )
        )
    }

    func openCaseDetails(caseInfo: Case) {
        selectedCase = caseInfo
        selectedRecordTableWrapper = RecordTableViewModelWrapper(
            viewModel: RecordTableViewModel(
                caseId: caseInfo.id,
                observeVitalRecordsUsecase: ObserveVitalRecordsUsecase(
                    vitalRecordRepository: provider.vitalRecordRepository()
                ),
                scope: nil
            )
        )
    }

    func endSessionAndOpenDetails() async -> String? {
        guard let caseId = activeCaseId else { return nil }

        _ = try? await endAnesthesiaUsecase.invoke(caseId: caseId)

        let resolvedCase = (try? await provider.caseRepository().getCaseById(id: caseId))
            ?? activeCase

        if let resolvedCase {
            openCaseDetails(caseInfo: resolvedCase)
        }

        activeCaseId = nil
        activeCase = nil
        monitoringWrapper = nil

        return resolvedCase?.id ?? caseId
    }

    func discardActiveSession() async {
        guard let caseId = activeCaseId else { return }
        await deleteCase(caseId: caseId)
    }

    func deleteCase(caseId: String) async {
        _ = try? await deleteCaseUsecase.invoke(caseId: caseId)

        if activeCaseId == caseId {
            activeCaseId = nil
            activeCase = nil
            monitoringWrapper = nil
        }
        if selectedCase?.id == caseId {
            selectedCase = nil
            selectedRecordTableWrapper = nil
        }
    }

    private func syncCatalogSeed() {
        guard let seedJson = CatalogSeedLoader.loadSeedJson() else { return }
        Task {
            await Task.yield()

#if DEBUG
            let startedAt = Date()
            print("[CatalogSeed] sync started")
#endif

            let syncedCount = try? await syncCatalogFromSeedUsecase.invoke(seedJson: seedJson)

#if DEBUG
            let elapsedMs = Int(Date().timeIntervalSince(startedAt) * 1000)
            if let syncedCount {
                print("[CatalogSeed] sync completed (\(syncedCount) items, \(elapsedMs)ms)")
            } else {
                print("[CatalogSeed] sync failed (\(elapsedMs)ms)")
            }
#endif
        }
    }
}
