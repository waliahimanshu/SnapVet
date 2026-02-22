import SwiftUI
import Shared

struct CaseSetupScreen: View {
    @ObservedObject var viewModel: CaseSetupViewModelWrapper
    var onCaseCreated: (Case) -> Void = { _ in }
    var onCancel: () -> Void = {}

    @FocusState private var focusedField: Field?
    @State private var didAttemptSubmit = false
    @State private var premedSelections: Set<String> = []
    @State private var anticholinergicSelection: String?
    @State private var inductionSelection: String?
    @State private var maintenanceSelection: String?
    @State private var oxygenCarrierSelection: String?
    @State private var analgesiaSelections: Set<String> = []

    private enum Field {
        case name
        case weight
    }

    private var state: CaseSetupState { viewModel.state }

    private let procedureOptions = [
        "Spay (OVH / OHE)",
        "Neuter (castration)",
        "Dental scale & polish",
        "Dental extraction",
        "Lump / mass removal",
        "Wound repair",
        "Laceration suturing",
        "Abscess drainage",
        "C-section",
        "Exploratory laparotomy",
        "Orthopaedic (TPLO, fracture repair)",
        "Endoscopy",
        "Imaging under GA (CT / MRI)"
    ]

    private let premedicationOptions = [
        "Medetomidine",
        "Dexmedetomidine",
        "Acepromazine",
        "Methadone",
        "Buprenorphine",
        "Butorphanol"
    ]

    private let anticholinergicOptions = [
        "Atropine",
        "Glycopyrrolate"
    ]

    private let inductionOptions = [
        "Propofol",
        "Alfaxalone",
        "Ketamine + benzodiazepine",
        "Mask induction (cats)"
    ]

    private let maintenanceOptions = [
        "Isoflurane",
        "Sevoflurane",
        "TIVA (Propofol CRI)"
    ]

    private let oxygenCarrierOptions = [
        "Oxygen only",
        "Oxygen + Air"
    ]

    private let analgesiaAddOnOptions = [
        "NSAID (Meloxicam / Carprofen)",
        "Local block",
        "Epidural",
        "CRI (Fentanyl / Ketamine)"
    ]

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
                                    get: { state.weight.map { formatWeightInput(Double(truncating: $0)) } ?? "" },
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
                            Menu {
                                Section("Small Animal – Common") {
                                    ForEach(procedureOptions, id: \.self) { option in
                                        Button(option) { viewModel.updateProcedure(option) }
                                    }
                                }
                            } label: {
                                dropdownLabel(
                                    text: state.procedure.isEmpty ? "Select procedure type" : state.procedure,
                                    isPlaceholder: state.procedure.isEmpty
                                )
                            }
                        }

                        labelledField(title: "Anesthetic Protocol") {
                            VStack(alignment: .leading, spacing: 10) {
                                Menu {
                                    ForEach(premedicationOptions, id: \.self) { option in
                                        Button {
                                            togglePremedication(option)
                                        } label: {
                                            Label(option, systemImage: premedSelections.contains(option) ? "checkmark.circle.fill" : "circle")
                                        }
                                    }
                                } label: {
                                    dropdownLabel(
                                        text: multiSelectionText(
                                            selections: premedSelections,
                                            options: premedicationOptions,
                                            placeholder: "Premedication"
                                        ),
                                        isPlaceholder: premedSelections.isEmpty
                                    )
                                }

                                Menu {
                                    ForEach(anticholinergicOptions, id: \.self) { option in
                                        Button {
                                            selectAnticholinergic(option)
                                        } label: {
                                            Label(option, systemImage: anticholinergicSelection == option ? "checkmark.circle.fill" : "circle")
                                        }
                                    }
                                    if anticholinergicSelection != nil {
                                        Divider()
                                        Button("Clear") { selectAnticholinergic(nil) }
                                    }
                                } label: {
                                    dropdownLabel(
                                        text: anticholinergicSelection ?? "Atropine / Glycopyrrolate",
                                        isPlaceholder: anticholinergicSelection == nil
                                    )
                                }

                                Menu {
                                    ForEach(inductionOptions, id: \.self) { option in
                                        Button(option) { selectInduction(option) }
                                    }
                                } label: {
                                    dropdownLabel(
                                        text: inductionSelection ?? "Induction",
                                        isPlaceholder: inductionSelection == nil
                                    )
                                }

                                Menu {
                                    ForEach(maintenanceOptions, id: \.self) { option in
                                        Button(option) { selectMaintenance(option) }
                                    }
                                } label: {
                                    dropdownLabel(
                                        text: maintenanceSelection ?? "Maintenance",
                                        isPlaceholder: maintenanceSelection == nil
                                    )
                                }

                                Menu {
                                    ForEach(oxygenCarrierOptions, id: \.self) { option in
                                        Button(option) { selectOxygenCarrier(option) }
                                    }
                                    if oxygenCarrierSelection != nil {
                                        Divider()
                                        Button("Clear") { selectOxygenCarrier(nil) }
                                    }
                                } label: {
                                    dropdownLabel(
                                        text: oxygenCarrierSelection ?? "Oxygen carrier",
                                        isPlaceholder: oxygenCarrierSelection == nil
                                    )
                                }

                                Menu {
                                    ForEach(analgesiaAddOnOptions, id: \.self) { option in
                                        Button {
                                            toggleAnalgesiaAddOn(option)
                                        } label: {
                                            Label(option, systemImage: analgesiaSelections.contains(option) ? "checkmark.circle.fill" : "circle")
                                        }
                                    }
                                } label: {
                                    dropdownLabel(
                                        text: multiSelectionText(
                                            selections: analgesiaSelections,
                                            options: analgesiaAddOnOptions,
                                            placeholder: "Analgesia add-ons"
                                        ),
                                        isPlaceholder: analgesiaSelections.isEmpty
                                    )
                                }

                                if !state.anestheticProtocol.isEmpty {
                                    Text(state.anestheticProtocol)
                                        .font(SnapVetFont.bodySmall)
                                        .foregroundColor(.snapvetTextSecondary)
                                        .padding(.top, 2)
                                }
                            }
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
    }

    private var header: some View {
        VStack(alignment: .leading, spacing: 8) {
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

    private func dropdownLabel(text: String, isPlaceholder: Bool) -> some View {
        HStack {
            Text(text)
                .foregroundColor(isPlaceholder ? .snapvetTextTertiary : .snapvetTextPrimary)
                .lineLimit(2)
                .multilineTextAlignment(.leading)
            Spacer(minLength: 8)
            Image(systemName: "chevron.down")
                .foregroundColor(.snapvetTextSecondary)
        }
        .padding(.horizontal, 14)
        .frame(minHeight: 50)
        .snapvetFormBackground()
    }

    private func togglePremedication(_ option: String) {
        if premedSelections.contains(option) {
            premedSelections.remove(option)
        } else {
            premedSelections.insert(option)
        }
        syncAnestheticProtocolText()
    }

    private func selectAnticholinergic(_ value: String?) {
        anticholinergicSelection = value
        syncAnestheticProtocolText()
    }

    private func selectInduction(_ value: String) {
        inductionSelection = value
        syncAnestheticProtocolText()
    }

    private func selectMaintenance(_ value: String) {
        maintenanceSelection = value
        syncAnestheticProtocolText()
    }

    private func selectOxygenCarrier(_ value: String?) {
        oxygenCarrierSelection = value
        syncAnestheticProtocolText()
    }

    private func toggleAnalgesiaAddOn(_ option: String) {
        if analgesiaSelections.contains(option) {
            analgesiaSelections.remove(option)
        } else {
            analgesiaSelections.insert(option)
        }
        syncAnestheticProtocolText()
    }

    private func syncAnestheticProtocolText() {
        var segments: [String] = []

        let orderedPremeds = orderedSelections(from: premedSelections, by: premedicationOptions)
        if !orderedPremeds.isEmpty || anticholinergicSelection != nil {
            var items = orderedPremeds
            if let anticholinergicSelection {
                items.append(anticholinergicSelection)
            }
            segments.append("Premed: " + items.joined(separator: " + "))
        }

        if let inductionSelection {
            segments.append("Induction: " + inductionSelection)
        }

        if let maintenanceSelection {
            if let oxygenCarrierSelection {
                segments.append("Maintenance: \(maintenanceSelection) (\(oxygenCarrierSelection))")
            } else {
                segments.append("Maintenance: \(maintenanceSelection)")
            }
        } else if let oxygenCarrierSelection {
            segments.append("Carrier: \(oxygenCarrierSelection)")
        }

        let orderedAnalgesia = orderedSelections(from: analgesiaSelections, by: analgesiaAddOnOptions)
        if !orderedAnalgesia.isEmpty {
            segments.append("Analgesia: " + orderedAnalgesia.joined(separator: " + "))
        }

        viewModel.updateAnestheticProtocol(segments.joined(separator: " | "))
    }

    private func orderedSelections(from selections: Set<String>, by options: [String]) -> [String] {
        options.filter { selections.contains($0) }
    }

    private func multiSelectionText(selections: Set<String>, options: [String], placeholder: String) -> String {
        let ordered = orderedSelections(from: selections, by: options)
        return ordered.isEmpty ? placeholder : ordered.joined(separator: " + ")
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
