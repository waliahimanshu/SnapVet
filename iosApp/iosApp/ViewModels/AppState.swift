import Foundation
import Shared

@MainActor
final class AppState: ObservableObject {
    @Published var activeCaseId: String? = nil
    @Published var activeCase: Case? = nil

    let provider: RepositoryProvider
    private let endAnesthesiaUsecase: EndAnesthesiaUsecase

    let caseListWrapper: CaseListViewModelWrapper
    let caseSetupWrapper: CaseSetupViewModelWrapper
    @Published var monitoringWrapper: MonitoringViewModelWrapper?
    @Published var recordTableWrapper: RecordTableViewModelWrapper?

    init() {
        // Swap here: InMemoryRepositoryProvider() or SqlDelightRepositoryProvider
        // For SQLDelight:
        // let driverFactory = DatabaseDriverFactory()
        // let database = DatabaseFactory(driverFactory: driverFactory).create()
        // let provider = SqlDelightRepositoryProvider(database: database)
        let provider = InMemoryRepositoryProvider()
        self.provider = provider
        self.endAnesthesiaUsecase = EndAnesthesiaUsecase(
            caseRepository: provider.caseRepository(),
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
    }

    func prepareNewCase() {
        activeCaseId = nil
        activeCase = nil
        monitoringWrapper = nil
        recordTableWrapper = nil
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
                timeProvider: SystemTimeProvider(),
                scope: nil
            )
        )
        recordTableWrapper = RecordTableViewModelWrapper(
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
        if let caseId = activeCaseId {
            Task {
                _ = try? await endAnesthesiaUsecase.invoke(caseId: caseId)
            }
        }
    }

    func resetFlowToBrowse() {
        prepareNewCase()
    }
}
