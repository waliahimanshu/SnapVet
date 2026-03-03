import SwiftUI
import Shared

struct ContentView: View {
    @StateObject private var appState = AppState()
    @AppStorage("snapvet_appearance_mode") private var appearanceModeRawValue = AppAppearance.dark.rawValue

    enum Route: Hashable {
        case caseSetup
        case monitoring
        case caseDetails(String)
        case settings
    }

    @State private var path: [Route] = []

    var body: some View {
        NavigationStack(path: $path) {
            CaseListScreen(
                viewModel: appState.caseListWrapper,
                onOpenSettings: {
                    path.append(.settings)
                },
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
                        procedureCatalogViewModel: appState.procedureCatalogWrapper,
                        onCaseCreated: { createdCase in
                            appState.startSession(caseInfo: createdCase)
                            path = [.monitoring]
                        },
                        onCancel: {
                            path = []
                        }
                    )
                    .toolbar(.visible, for: .navigationBar)

                case .monitoring:
                    if let monitoring = appState.monitoringWrapper {
                        MonitoringScreen(
                            viewModel: monitoring,
                            patientName: appState.activeCase?.patientName ?? "",
                            species: appState.activeCase?.species == .dog
                                ? "Canine"
                                : (appState.activeCase?.species == .cat ? "Feline" : ""),
                            weight: appState.activeCase?.weight.description ?? "",
                            onDiscardSession: {
                                Task {
                                    await appState.discardActiveSession()
                                    path = []
                                }
                            },
                            onEndSession: {
                                Task {
                                    if let caseId = await appState.endSessionAndOpenDetails() {
                                        path = [.caseDetails(caseId)]
                                    } else {
                                        path = []
                                    }
                                }
                            }
                        )
                        .toolbar(.visible, for: .navigationBar)
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
                            onDeleteCase: {
                                Task {
                                    await appState.deleteCase(caseId: selectedCase.id)
                                    path = []
                                }
                            }
                        )
                        .toolbar(.visible, for: .navigationBar)
                    }

                case .settings:
                    SettingsScreen()
                        .toolbar(.visible, for: .navigationBar)
                }
            }
        }
        .background(Color.snapvetPrimaryBg)
        .tint(.snapvetAccentPrimary)
        .preferredColorScheme(currentAppearance.colorScheme)
    }

    private var currentAppearance: AppAppearance {
        AppAppearance(rawValue: appearanceModeRawValue) ?? .dark
    }
}

#Preview {
    ContentView()
}
