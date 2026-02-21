import SwiftUI

struct ContentView: View {
    @StateObject private var appState = AppState()

    enum Route: Hashable {
        case caseSetup
        case monitoring
        case sessionEnded
        case activeRecords
    }

    @State private var path: [Route] = []

    var body: some View {
        NavigationStack(path: $path) {
            CaseListScreen(viewModel: appState.caseListWrapper) {
                appState.prepareNewCase()
                path.append(.caseSetup)
            }
            .toolbar(.hidden, for: .navigationBar)
            .navigationDestination(for: Route.self) { route in
                switch route {
                case .caseSetup:
                    CaseSetupScreen(viewModel: appState.caseSetupWrapper) { createdCase in
                        appState.startSession(caseInfo: createdCase)
                        path = [.monitoring]
                    }
                case .monitoring:
                    if let monitoring = appState.monitoringWrapper {
                        MonitoringScreen(
                            viewModel: monitoring,
                            patientName: appState.activeCase?.patientName ?? "",
                            species: appState.activeCase?.species.name ?? "",
                            weight: appState.activeCase?.weight.description ?? ""
                        ) {
                            appState.endSession()
                            path = [.sessionEnded]
                        }
                        .navigationBarBackButtonHidden(true)
                    }
                case .sessionEnded:
                    SessionEndedScreen(
                        patientName: appState.activeCase?.patientName ?? "This case",
                        onBrowseCases: {
                            appState.resetFlowToBrowse()
                            path = []
                        },
                        onViewRecords: {
                            if appState.recordTableWrapper != nil {
                                path = [.activeRecords]
                            }
                        },
                        onStartNewCase: {
                            appState.prepareNewCase()
                            path = [.caseSetup]
                        }
                    )
                    .navigationBarBackButtonHidden(true)
                case .activeRecords:
                    if let records = appState.recordTableWrapper {
                        RecordTableScreen(viewModel: records)
                    }
                }
            }
        }
        .background(Color.snapvetPrimaryBg)
    }
}

private struct SessionEndedScreen: View {
    let patientName: String
    let onBrowseCases: () -> Void
    let onViewRecords: () -> Void
    let onStartNewCase: () -> Void

    var body: some View {
        VStack(spacing: 20) {
            Spacer()

            Image(systemName: "checkmark.circle.fill")
                .font(.system(size: 72))
                .foregroundColor(.snapvetAccentPrimary)

            Text("Session Ended")
                .font(SnapVetFont.titleLarge)
                .foregroundColor(.snapvetTextPrimary)

            Text("\(patientName) anesthesia has been completed.")
                .font(SnapVetFont.bodyMedium)
                .foregroundColor(.snapvetTextSecondary)
                .multilineTextAlignment(.center)
                .padding(.horizontal, 24)

            VStack(spacing: 12) {
                Button("View Case Records", action: onViewRecords)
                    .buttonStyle(.borderedProminent)
                    .controlSize(.large)

                Button("Browse Cases", action: onBrowseCases)
                    .buttonStyle(.bordered)
                    .controlSize(.large)

                Button("Start New Case", action: onStartNewCase)
                    .buttonStyle(.bordered)
                    .controlSize(.large)
            }

            Spacer()
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .padding(24)
        .background(Color.snapvetPrimaryBg)
        .navigationTitle("Complete")
    }
}

#Preview {
    ContentView()
}
