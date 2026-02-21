import SwiftUI
import Shared

struct CaseSetupScreen: View {
    @ObservedObject var viewModel: CaseSetupViewModelWrapper
    var onCaseCreated: (String) -> Void = { _ in }

    var body: some View {
        ScrollView {
            VStack(spacing: 16) {
                TextField("Patient Name", text: Binding(
                    get: { viewModel.state.patientName },
                    set: { viewModel.updatePatientName($0) }
                ))
                .textFieldStyle(.roundedBorder)

                HStack {
                    Button("Dog") { viewModel.updateSpecies(Species.dog) }
                    Button("Cat") { viewModel.updateSpecies(Species.cat) }
                }

                TextField("Weight (kg)", text: Binding(
                    get: { viewModel.state.weight?.description ?? "" },
                    set: { viewModel.updateWeight(Double($0)) }
                ))
                .textFieldStyle(.roundedBorder)

                TextField("Procedure", text: Binding(
                    get: { viewModel.state.procedure },
                    set: { viewModel.updateProcedure($0) }
                ))
                .textFieldStyle(.roundedBorder)

                TextField("Anesthetic Protocol", text: Binding(
                    get: { viewModel.state.anestheticProtocol },
                    set: { viewModel.updateAnestheticProtocol($0) }
                ))
                .textFieldStyle(.roundedBorder)

                Button("Start Case") { viewModel.startCase() }
                    .buttonStyle(.borderedProminent)
            }
            .padding(16)
        }
        .onChange(of: viewModel.state.createdCase?.id) { newValue in
            if let id = newValue { onCaseCreated(id) }
        }
        .navigationTitle("Case Setup")
    }
}
