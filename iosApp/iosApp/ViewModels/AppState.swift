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

    let caseListWrapper: CaseListViewModelWrapper
    let caseSetupWrapper: CaseSetupViewModelWrapper
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

    func endSession() {
        guard let caseId = activeCaseId else { return }
        Task {
            _ = try? await endAnesthesiaUsecase.invoke(caseId: caseId)
        }
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
}
