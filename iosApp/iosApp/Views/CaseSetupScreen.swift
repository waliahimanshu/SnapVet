import SwiftUI
import Shared

struct CaseSetupScreen: View {
    @ObservedObject var viewModel: CaseSetupViewModelWrapper
    var onCaseCreated: (Case) -> Void = { _ in }
    @FocusState private var focusedField: Field?

    private enum Field {
        case name
        case weight
        case procedure
        case protocolField
    }

    var body: some View {
        ScrollView {
            VStack(spacing: 16) {
                TextField("Patient Name", text: Binding(
                    get: { viewModel.state.patientName },
                    set: { viewModel.updatePatientName($0) }
                ))
                .textFieldStyle(.roundedBorder)
                .focused($focusedField, equals: .name)

                HStack {
                    Button("Dog") { viewModel.updateSpecies(Species.dog) }
                    Button("Cat") { viewModel.updateSpecies(Species.cat) }
                }

                TextField("Weight (kg)", text: Binding(
                    get: { viewModel.state.weight?.description ?? "" },
                    set: { viewModel.updateWeight(Double($0)) }
                ))
                .textFieldStyle(.roundedBorder)
                .keyboardType(.decimalPad)
                .focused($focusedField, equals: .weight)

                TextField("Procedure", text: Binding(
                    get: { viewModel.state.procedure },
                    set: { viewModel.updateProcedure($0) }
                ))
                .textFieldStyle(.roundedBorder)
                .focused($focusedField, equals: .procedure)

                TextField("Anesthetic Protocol", text: Binding(
                    get: { viewModel.state.anestheticProtocol },
                    set: { viewModel.updateAnestheticProtocol($0) }
                ))
                .textFieldStyle(.roundedBorder)
                .focused($focusedField, equals: .protocolField)

                Button("Next") {
                    focusedField = nil
                    viewModel.startCase()
                }
                    .buttonStyle(.borderedProminent)
                    .disabled(!canStartCase)

                if let message = viewModel.state.errorMessage {
                    Text(message)
                        .foregroundColor(.red)
                        .font(.footnote)
                }
            }
            .padding(16)
        }
        .toolbar {
            ToolbarItemGroup(placement: .keyboard) {
                Spacer()
                Button("Done") { focusedField = nil }
            }
        }
        .onChange(of: viewModel.state.createdCase?.id) { _ in
            if let created = viewModel.state.createdCase { onCaseCreated(created) }
        }
        .navigationTitle("New Case")
    }

    private var canStartCase: Bool {
        let state = viewModel.state
        return !state.patientName.isEmpty && state.species != nil && state.weight != nil
    }
}
