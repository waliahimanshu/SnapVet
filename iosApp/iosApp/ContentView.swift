import SwiftUI

struct ContentView: View {
    @StateObject private var appState = AppState()

    var body: some View {
        TabView(selection: $appState.selectedTab) {
            CaseListScreen(viewModel: appState.caseListWrapper)
                .tabItem { Label("Cases", systemImage: "list.bullet") }
                .tag(AppTab.cases)

            CaseSetupScreen(viewModel: appState.caseSetupWrapper) { createdCase in
                appState.startSession(caseInfo: createdCase)
            }
            .tabItem { Label("Setup", systemImage: "plus.circle") }
            .tag(AppTab.setup)

            if let monitoring = appState.monitoringWrapper {
                MonitoringScreen(
                    viewModel: monitoring,
                    patientName: appState.activeCase?.patientName ?? "",
                    species: appState.activeCase?.species.name ?? "",
                    weight: appState.activeCase?.weight.description ?? ""
                ) {
                    appState.endSession()
                }
                    .tabItem { Label("Monitor", systemImage: "waveform.path.ecg") }
                    .tag(AppTab.monitoring)
            }

            if let records = appState.recordTableWrapper {
                RecordTableScreen(viewModel: records)
                    .tabItem { Label("Records", systemImage: "tablecells") }
                    .tag(AppTab.records)
            }
        }
        .background(Color.snapvetPrimaryBg)
    }
}

#Preview {
    ContentView()
}
