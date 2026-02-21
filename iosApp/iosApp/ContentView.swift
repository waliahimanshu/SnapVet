import SwiftUI
import Shared

struct ContentView: View {
    @StateObject private var appState = AppState()

    enum Route: Hashable {
        case caseSetup
        case monitoring
        case caseDetails(String)
    }

    @State private var path: [Route] = []

    var body: some View {
        NavigationStack(path: $path) {
            CaseListScreen(
                viewModel: appState.caseListWrapper,
                onNewCase: {
                    appState.prepareNewCase()
                    path.append(.caseSetup)
                },
                onCaseSelected: { selected in
                    appState.openCaseDetails(caseInfo: selected)
                    path.append(.caseDetails(selected.id))
                }
            )
            .toolbar(.hidden, for: .navigationBar)
            .navigationDestination(for: Route.self) { route in
                switch route {
                case .caseSetup:
                    CaseSetupScreen(
                        viewModel: appState.caseSetupWrapper,
                        onCaseCreated: { createdCase in
                            appState.startSession(caseInfo: createdCase)
                            path = [.monitoring]
                        },
                        onCancel: {
                            path = []
                        }
                    )
                    .navigationBarBackButtonHidden(true)

                case .monitoring:
                    if let monitoring = appState.monitoringWrapper {
                        MonitoringScreen(
                            viewModel: monitoring,
                            patientName: appState.activeCase?.patientName ?? "",
                            species: appState.activeCase?.species.name ?? "",
                            weight: appState.activeCase?.weight.description ?? "",
                            onExit: {
                                path = []
                            },
                            onEndSession: {
                                appState.endSession()
                                path = []
                            }
                        )
                        .navigationBarBackButtonHidden(true)
                    }

                case .caseDetails(let caseId):
                    if
                        let selectedCase = appState.selectedCase,
                        selectedCase.id == caseId,
                        let records = appState.selectedRecordTableWrapper
                    {
                        RecordTableScreen(
                            viewModel: records,
                            caseInfo: selectedCase,
                            onBackToCases: { path = [] },
                            onDeleteCase: {
                                Task {
                                    await appState.deleteCase(caseId: selectedCase.id)
                                    path = []
                                }
                            }
                        )
                        .navigationBarBackButtonHidden(true)
                    }
                }
            }
        }
        .background(Color.snapvetPrimaryBg)
    }
}

#Preview {
    ContentView()
}
