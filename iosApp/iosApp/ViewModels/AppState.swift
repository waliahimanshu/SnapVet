import Foundation
import Shared

@MainActor
final class AppState: ObservableObject {
    @Published var activeCaseId: String? = nil
    @Published var selectedTab: AppTab = .monitoring

    let provider: RepositoryProvider

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

    func startSession(caseId: String) {
        activeCaseId = caseId
        monitoringWrapper = MonitoringViewModelWrapper(
            viewModel: MonitoringViewModel(
                caseId: caseId,
                saveVitalsUsecase: SaveVitalsUsecase(
                    vitalRecordRepository: provider.vitalRecordRepository(),
                    idGenerator: RandomIdGenerator(),
                    timeProvider: SystemTimeProvider()
                ),
                getLatestVitalRecordUsecase: GetLatestVitalRecordUsecase(
                    vitalRecordRepository: provider.vitalRecordRepository()
                ),
                scope: nil
            )
        )
        recordTableWrapper = RecordTableViewModelWrapper(
            viewModel: RecordTableViewModel(
                caseId: caseId,
                observeVitalRecordsUsecase: ObserveVitalRecordsUsecase(
                    vitalRecordRepository: provider.vitalRecordRepository()
                ),
                scope: nil
            )
        )
        selectedTab = .monitoring
    }

    func endSession() {
        selectedTab = .records
    }
}

enum AppTab: Hashable {
    case cases
    case setup
    case monitoring
    case records
}
