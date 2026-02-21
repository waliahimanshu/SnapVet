import SwiftUI
import Shared

struct CaseSetupScreen: View {
    @ObservedObject var viewModel: CaseSetupViewModelWrapper
    var onCaseCreated: (Case) -> Void = { _ in }
    var onCancel: () -> Void = {}

    @FocusState private var focusedField: Field?
    @State private var didAttemptSubmit = false

    private enum Field {
        case name
        case weight
        case procedure
        case protocolField
    }

    private var state: CaseSetupState { viewModel.state }

    var body: some View {
        ZStack {
            LinearGradient(
                colors: [Color.snapvetHeaderBg, Color.snapvetPrimaryBg],
                startPoint: .top,
                endPoint: .bottom
            )
            .ignoresSafeArea()

            ScrollView {
                VStack(alignment: .leading, spacing: 16) {
                    header

                    VStack(alignment: .leading, spacing: 14) {
                        labelledField(
                            title: "Patient Name *",
                            error: shouldShowNameError ? "Patient name is required" : nil
                        ) {
                            TextField(
                                "Enter patient name",
                                text: Binding(
                                    get: { state.patientName },
                                    set: { viewModel.updatePatientName($0) }
                                )
                            )
                            .focused($focusedField, equals: .name)
                            .textInputAutocapitalization(.words)
                            .snapvetFormFieldStyle()
                        }

                        labelledField(
                            title: "Species *",
                            error: shouldShowSpeciesError ? "Species is required" : nil
                        ) {
                            Menu {
                                Button("Dog") { viewModel.updateSpecies(Species.dog) }
                                Button("Cat") { viewModel.updateSpecies(Species.cat) }
                            } label: {
                                HStack {
                                    Text(selectedSpeciesLabel)
                                        .foregroundColor(state.species == nil ? .snapvetTextTertiary : .snapvetTextPrimary)
                                    Spacer()
                                    Image(systemName: "chevron.down")
                                        .foregroundColor(.snapvetTextSecondary)
                                }
                                .padding(.horizontal, 14)
                                .frame(height: 50)
                                .snapvetFormBackground()
                            }
                        }

                        labelledField(
                            title: "Weight (lb) *",
                            error: shouldShowWeightError ? "Weight is required" : nil
                        ) {
                            TextField(
                                "Enter weight in pounds",
                                text: Binding(
                                    get: { state.weight.map { formatWeightInput($0) } ?? "" },
                                    set: { viewModel.updateWeight(Double($0.filter { "0123456789.".contains($0) })) }
                                )
                            )
                            .keyboardType(.decimalPad)
                            .focused($focusedField, equals: .weight)
                            .snapvetFormFieldStyle()
                        }

                        labelledField(
                            title: "Procedure *",
                            error: shouldShowProcedureError ? "Procedure is required" : nil
                        ) {
                            TextField(
                                "e.g., Dental cleaning, Spay, Neuter",
                                text: Binding(
                                    get: { state.procedure },
                                    set: { viewModel.updateProcedure($0) }
                                )
                            )
                            .focused($focusedField, equals: .procedure)
                            .snapvetFormFieldStyle()
                        }

                        labelledField(title: "Anesthetic Protocol") {
                            TextField(
                                "Optional protocol details",
                                text: Binding(
                                    get: { state.anestheticProtocol },
                                    set: { viewModel.updateAnestheticProtocol($0) }
                                )
                            )
                            .focused($focusedField, equals: .protocolField)
                            .snapvetFormFieldStyle()
                        }

                        if let message = state.errorMessage {
                            Text(message)
                                .font(SnapVetFont.bodySmall)
                                .foregroundColor(.snapvetAccentAlert)
                        }

                        HStack(spacing: 12) {
                            Button("Cancel") {
                                focusedField = nil
                                onCancel()
                            }
                            .frame(maxWidth: .infinity)
                            .frame(height: 50)
                            .foregroundColor(.snapvetTextPrimary)
                            .background(
                                RoundedRectangle(cornerRadius: 12, style: .continuous)
                                    .fill(Color.white.opacity(0.14))
                            )

                            Button(action: startCase) {
                                Text(state.isSaving ? "Starting..." : "Start Anesthesia")
                                    .font(SnapVetFont.titleMedium.weight(.semibold))
                                    .frame(maxWidth: .infinity)
                                    .frame(height: 50)
                            }
                            .buttonStyle(.plain)
                            .foregroundColor(.white)
                            .background(
                                RoundedRectangle(cornerRadius: 12, style: .continuous)
                                    .fill(canStartCase ? Color.snapvetAccentPrimary : Color.snapvetBorderSubtle)
                            )
                            .disabled(state.isSaving)
                        }
                    }
                    .padding(16)
                    .snapVetGlassCard(cornerRadius: 22)
                }
                .padding(16)
                .padding(.bottom, 24)
            }
        }
        .toolbar {
            ToolbarItemGroup(placement: .keyboard) {
                Spacer()
                Button("Done") { focusedField = nil }
            }
        }
        .onChange(of: state.createdCase?.id) { _ in
            if let created = state.createdCase {
                onCaseCreated(created)
            }
        }
        .navigationBarBackButtonHidden(true)
    }

    private var header: some View {
        VStack(alignment: .leading, spacing: 8) {
            Button(action: onCancel) {
                HStack(spacing: 8) {
                    Image(systemName: "arrow.left")
                    Text("Back")
                }
                .font(SnapVetFont.titleMedium.weight(.semibold))
                .foregroundColor(.snapvetTextSecondary)
            }

            Text("New Anesthesia Case")
                .font(SnapVetFont.headlineLarge)
                .foregroundColor(.snapvetTextPrimary)
        }
        .padding(16)
        .snapVetGlassCard(cornerRadius: 22)
    }

    private var selectedSpeciesLabel: String {
        switch state.species {
        case .dog: return "Dog"
        case .cat: return "Cat"
        default: return "Select species"
        }
    }

    private var canStartCase: Bool {
        !state.patientName.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty &&
            state.species != nil &&
            state.weight != nil &&
            !state.procedure.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty
    }

    private var shouldShowNameError: Bool {
        didAttemptSubmit && state.patientName.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty
    }

    private var shouldShowSpeciesError: Bool {
        didAttemptSubmit && state.species == nil
    }

    private var shouldShowWeightError: Bool {
        didAttemptSubmit && state.weight == nil
    }

    private var shouldShowProcedureError: Bool {
        didAttemptSubmit && state.procedure.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty
    }

    private func startCase() {
        focusedField = nil
        didAttemptSubmit = true
        guard canStartCase else { return }
        viewModel.startCase()
    }

    private func formatWeightInput(_ value: Double) -> String {
        if value.rounded() == value {
            return "\(Int(value))"
        }
        return String(format: "%.1f", value)
    }

    @ViewBuilder
    private func labelledField<Content: View>(title: String, error: String? = nil, @ViewBuilder content: () -> Content) -> some View {
        VStack(alignment: .leading, spacing: 6) {
            Text(title)
                .font(SnapVetFont.titleMedium)
                .foregroundColor(.snapvetTextPrimary)
            content()
            if let error {
                Text(error)
                    .font(SnapVetFont.bodySmall)
                    .foregroundColor(.snapvetAccentAlert)
            }
        }
    }
}

private extension View {
    func snapvetFormFieldStyle() -> some View {
        self
            .padding(.horizontal, 14)
            .frame(height: 50)
            .snapvetFormBackground()
            .foregroundColor(.snapvetTextPrimary)
    }

    func snapvetFormBackground() -> some View {
        self
            .background(
                RoundedRectangle(cornerRadius: 10, style: .continuous)
                    .fill(Color.snapvetHeaderBg.opacity(0.55))
            )
            .overlay(
                RoundedRectangle(cornerRadius: 10, style: .continuous)
                    .stroke(Color.snapvetBorderSubtle, lineWidth: 1)
            )
    }

    @ViewBuilder
    func snapVetGlassCard(cornerRadius: CGFloat) -> some View {
#if swift(>=6.2)
        if #available(iOS 26.0, *) {
            self
                .glassEffect(.regular, in: RoundedRectangle(cornerRadius: cornerRadius, style: .continuous))
                .overlay(
                    RoundedRectangle(cornerRadius: cornerRadius, style: .continuous)
                        .stroke(Color.white.opacity(0.14), lineWidth: 1)
                )
        } else {
            self
                .background(
                    RoundedRectangle(cornerRadius: cornerRadius, style: .continuous)
                        .fill(Color.snapvetTileBg.opacity(0.78))
                )
                .overlay(
                    RoundedRectangle(cornerRadius: cornerRadius, style: .continuous)
                        .stroke(Color.snapvetBorderSubtle, lineWidth: 1)
                )
        }
#else
        self
            .background(
                RoundedRectangle(cornerRadius: cornerRadius, style: .continuous)
                    .fill(Color.snapvetTileBg.opacity(0.78))
            )
            .overlay(
                RoundedRectangle(cornerRadius: cornerRadius, style: .continuous)
                    .stroke(Color.snapvetBorderSubtle, lineWidth: 1)
            )
#endif
    }
}
