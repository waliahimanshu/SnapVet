import SwiftUI
import Shared
import UIKit

private enum NumericField: String, CaseIterable, Identifiable {
    case hr = "HR"
    case rr = "RR"
    case spo2 = "SpO₂"
    case etco2 = "EtCO₂"
    case bp = "BP"
    case temp = "Temp"
    case sevoIso = "Iso/Sevo"
    case o2Flow = "O₂"
    case fluids = "Fluids"

    var unit: String {
        switch self {
        case .hr, .rr: return "bpm"
        case .spo2: return "%"
        case .etco2: return "mmHg"
        case .bp: return ""
        case .temp: return "°C"
        case .sevoIso: return "%"
        case .o2Flow: return "L/min"
        case .fluids: return "ml/hr"
        }
    }

    var allowsDecimal: Bool {
        switch self {
        case .temp, .sevoIso, .o2Flow, .fluids:
            return true
        default:
            return false
        }
    }

    var id: String { rawValue }
}

private struct ObservationOption: Identifiable {
    let id: String
    let label: String
}

private struct SnapshotMetric {
    let label: String
    let value: String
}

private enum BloodPressureEditorField: CaseIterable {
    case sap
    case dap
    case map

    var shortLabel: String {
        switch self {
        case .sap: return "SAP"
        case .dap: return "DAP"
        case .map: return "MAP"
        }
    }

    var fullLabel: String {
        switch self {
        case .sap: return "Systolic Arterial Pressure"
        case .dap: return "Diastolic Arterial Pressure"
        case .map: return "Mean Arterial Pressure"
        }
    }
}

struct MonitoringScreen: View {
    @ObservedObject var viewModel: MonitoringViewModelWrapper
    var patientName: String
    var species: String
    var weight: String
    var onDiscardSession: () -> Void = {}
    var onEndSession: () -> Void = {}

    @State private var selectedField: NumericField?
    @State private var keypadValue: String = ""
    @State private var shouldReplaceOnNextInput = false
    @State private var showBpEditor = false
    @State private var showEcgOtherEditor = false
    @State private var ecgOtherInput = ""
    @State private var bpSysInput = ""
    @State private var bpDiaInput = ""
    @State private var bpMapInput = ""
    @State private var selectedBpField: BloodPressureEditorField = .sap
    @State private var showDiscardConfirm = false
    @State private var showEndConfirm = false
    @State private var previousIdleTimerDisabled = false
    @State private var lastErrorMessage: String?
    @State private var nudgeHapticArmed = true
    @FocusState private var isNotesFieldFocused: Bool
    @FocusState private var isEcgOtherFieldFocused: Bool
    @AppStorage("snapvet_weight_unit") private var weightUnitRawValue = WeightUnit.lb.rawValue
    @AppStorage("snapvet_temperature_unit") private var temperatureUnitRawValue = TemperatureUnit.celsius.rawValue
    @AppStorage("snapvet_save_nudge_interval_minutes") private var saveNudgeIntervalMinutes = 5
    @AppStorage("snapvet_enable_vital_warnings") private var enableVitalWarnings = true

    private var state: MonitoringState { viewModel.state }
    private var current: VitalsInput { state.currentVitals }
    private var lastSaved: VitalRecord? { state.lastSaved }

    var body: some View {
        ZStack {
            LinearGradient(
                colors: [Color.snapvetHeaderBg, Color.snapvetPrimaryBg],
                startPoint: .top,
                endPoint: .bottom
            )
            .ignoresSafeArea()

            GeometryReader { proxy in
                let isWide = proxy.size.width >= 950

                ScrollView {
                    VStack(spacing: 14) {
                        header

                        if isWide {
                            HStack(alignment: .top, spacing: 14) {
                                vitalsGrid(columns: 3)
                                    .frame(maxWidth: .infinity)
                                recordedSnapshotsPanel
                                    .frame(width: 340)
                            }
                        } else {
                            vitalsGrid(columns: proxy.size.width < 650 ? 2 : 3)
                            observationsPanel
                            recordedSnapshotsPanel
                        }

                        if isWide {
                            observationsPanel
                        }

                        if let error = state.errorMessage {
                            Text(error)
                                .font(SnapVetFont.bodySmall)
                                .foregroundColor(.snapvetAccentAlert)
                        }
                    }
                    .padding(16)
                    .padding(.bottom, 98)
                }
            }
        }
        .safeAreaInset(edge: .bottom) {
            saveBar
        }
        .sheet(item: $selectedField, onDismiss: {
            shouldReplaceOnNextInput = false
        }) { field in
            NumericKeypadView(
                currentValue: $keypadValue,
                unitLabel: unitLabel(for: field),
                showsDecimalKey: field.allowsDecimal,
                onNumberTap: { number in
                    feedbackSelection()
                    if shouldReplaceOnNextInput {
                        keypadValue = number
                        shouldReplaceOnNextInput = false
                    } else {
                        keypadValue.append(number)
                    }
                },
                onDecimalTap: {
                    guard field.allowsDecimal else { return }
                    if shouldReplaceOnNextInput {
                        feedbackSelection()
                        keypadValue = "0."
                        shouldReplaceOnNextInput = false
                        return
                    }
                    guard !keypadValue.contains(".") else { return }
                    feedbackSelection()
                    keypadValue.append(".")
                },
                onBackspaceTap: {
                    feedbackSelection()
                    shouldReplaceOnNextInput = false
                    if !keypadValue.isEmpty {
                        keypadValue.removeLast()
                    }
                },
                onConfirm: {
                    feedbackSaveAction()
                    applyNumeric(field: field, value: keypadValue)
                    shouldReplaceOnNextInput = false
                    selectedField = nil
                },
                onClear: {
                    feedbackSelection()
                    keypadValue = ""
                    shouldReplaceOnNextInput = false
                },
                onCancel: {
                    SnapVetHaptics.lightTap()
                    shouldReplaceOnNextInput = false
                    selectedField = nil
                }
            )
            .padding(12)
            .background(Color.snapvetPrimaryBg)
            .presentationDetents([.medium])
            .presentationDragIndicator(.visible)
        }
        .sheet(isPresented: $showBpEditor) {
            bloodPressureEditor
                .background(Color.snapvetPrimaryBg)
        }
        .sheet(isPresented: $showEcgOtherEditor) {
            ecgOtherEditor
                .background(Color.snapvetPrimaryBg)
        }
        .navigationBarBackButtonHidden(true)
        .toolbar {
            ToolbarItem(placement: .topBarLeading) {
                Button(action: {
                    SnapVetHaptics.lightTap()
                    showDiscardConfirm = true
                }) {
                    Image(systemName: "chevron.backward")
                        .font(.system(size: 17, weight: .semibold))
                }
                .accessibilityLabel("Back")
            }

            ToolbarItem(placement: .topBarTrailing) {
                Button(action: {
                    SnapVetHaptics.primaryAction()
                    showEndConfirm = true
                }) {
                    HStack(spacing: 6) {
                        Image(systemName: "stop.circle.fill")
                        Text("End")
                    }
                    .font(SnapVetFont.titleMedium.weight(.semibold))
                    .foregroundColor(.white)
                    .padding(.horizontal, 10)
                    .padding(.vertical, 6)
                    .background(
                        Capsule()
                            .fill(Color.snapvetAccentAlert)
                    )
                }
                .buttonStyle(.plain)
                .accessibilityLabel("End Anesthesia")
            }
        }
        .confirmationDialog(
            "Discard session?",
            isPresented: $showDiscardConfirm,
            titleVisibility: .visible
        ) {
            Button("Discard", role: .destructive) {
                SnapVetHaptics.warning()
                onDiscardSession()
            }
            Button("Keep Monitoring", role: .cancel) {}
        } message: {
            Text("If you go back now, this active session will be discarded and cannot be resumed.")
        }
        .alert("End anesthesia session?", isPresented: $showEndConfirm) {
            Button("Cancel", role: .cancel) {}
            Button("End Session", role: .destructive) {
                SnapVetHaptics.prominentCommit()
                onEndSession()
            }
        } message: {
            Text("This marks the case as completed. You can still view records from Case History.")
        }
        .onAppear {
            previousIdleTimerDisabled = UIApplication.shared.isIdleTimerDisabled
            UIApplication.shared.isIdleTimerDisabled = true
        }
        .onDisappear {
            UIApplication.shared.isIdleTimerDisabled = previousIdleTimerDisabled
        }
        .onChange(of: state.errorMessage) { _, message in
            guard let message, !message.isEmpty else { return }
            guard message != lastErrorMessage else { return }
            lastErrorMessage = message
            SnapVetHaptics.error()
        }
        .onChange(of: shouldNudgeSave) { _, active in
            if active, nudgeHapticArmed {
                SnapVetHaptics.warning()
                nudgeHapticArmed = false
            } else if !active {
                nudgeHapticArmed = true
            }
        }
    }

    private var header: some View {
        VStack(alignment: .leading, spacing: 10) {
            HStack(alignment: .bottom) {
                VStack(alignment: .leading, spacing: 4) {
                    Text(patientName.isEmpty ? "Unnamed Case" : patientName)
                        .font(SnapVetFont.headlineLarge)
                        .foregroundColor(.snapvetTextPrimary)

                    Text("\(displaySpecies(species))   \(displayWeight(weight))")
                        .font(SnapVetFont.bodyMedium)
                        .foregroundColor(.snapvetTextSecondary)
                }

                Spacer()

                HStack(spacing: 8) {
                    Image(systemName: "clock")
                        .foregroundColor(.snapvetTextPrimary)
                    Text(formatElapsed(seconds: state.elapsedSeconds))
                        .font(.system(size: 42, weight: .bold, design: .monospaced))
                        .foregroundColor(.snapvetTextPrimary)
                        .minimumScaleFactor(0.7)
                }
            }
        }
        .padding(16)
        .snapVetGlassCard(cornerRadius: 20)
    }

    private func vitalsGrid(columns: Int) -> some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("Vital Parameters")
                .font(SnapVetFont.headlineMedium)
                .foregroundColor(.snapvetTextPrimary)

            LazyVGrid(columns: Array(repeating: GridItem(.flexible(), spacing: 10), count: columns), spacing: 10) {
                ForEach(NumericField.allCases) { field in
                    ParameterTileView(
                        name: field.rawValue,
                        value: formattedValue(for: field),
                        unit: unitLabel(for: field),
                        status: status(for: field),
                        previousValue: previousValue(for: field)
                    ) {
                        feedbackSelection()
                        dismissKeyboard()
                        isNotesFieldFocused = false

                        if field == .bp {
                            bpSysInput = current.bpSys?.intValue.description ?? ""
                            bpDiaInput = current.bpDia?.intValue.description ?? ""
                            bpMapInput = current.bpMap?.intValue.description ?? ""
                            selectedBpField = .sap
                            showBpEditor = true
                            return
                        }
                        let existingValue = rawFieldValue(for: field)
                        keypadValue = existingValue
                        shouldReplaceOnNextInput = !existingValue.isEmpty
                        selectedField = field
                    }
                }
            }
        }
        .padding(16)
        .snapVetGlassCard(cornerRadius: 20)
    }

    private var recordedSnapshotsPanel: some View {
        VStack(alignment: .leading, spacing: 12) {
            HStack {
                Text("Recorded Vitals")
                    .font(SnapVetFont.headlineMedium)
                    .foregroundColor(.snapvetTextPrimary)

                Spacer()

                Text("\(state.recentRecords.count)")
                    .font(SnapVetFont.labelMedium.weight(.bold))
                    .foregroundColor(.white)
                    .padding(.horizontal, 10)
                    .padding(.vertical, 4)
                    .background(
                        Capsule()
                            .fill(Color.snapvetAccentPrimary)
                    )
            }

            if state.recentRecords.isEmpty {
                Text("No records yet")
                    .font(SnapVetFont.bodyMedium)
                    .foregroundColor(.snapvetTextTertiary)
                    .frame(maxWidth: .infinity, minHeight: 120)
            } else {
                VStack(spacing: 8) {
                    ForEach(Array(state.recentRecords.prefix(4).enumerated()), id: \.element.id) { index, record in
                        snapshotCard(record: record, index: state.recentRecords.count - index)
                    }
                }
            }
        }
        .padding(16)
        .snapVetGlassCard(cornerRadius: 20)
    }

    private func snapshotCard(record: VitalRecord, index: Int) -> some View {
        let metrics = snapshotMetrics(for: record)
        return VStack(alignment: .leading, spacing: 6) {
            HStack {
                Text("#\(index)")
                    .font(SnapVetFont.titleMedium.weight(.bold))
                    .foregroundColor(.snapvetTextPrimary)
                Spacer()
                Text(formatTime(record.timestamp))
                    .font(SnapVetFont.bodySmall)
                    .foregroundColor(.snapvetTextSecondary)
            }

            Divider().background(Color.snapvetDivider)

            if metrics.isEmpty {
                Text("No key vitals entered")
                    .font(SnapVetFont.bodySmall)
                    .foregroundColor(.snapvetTextTertiary)
            } else {
                LazyVGrid(
                    columns: [
                        GridItem(.flexible(), spacing: 8, alignment: .leading),
                        GridItem(.flexible(), spacing: 8, alignment: .leading)
                    ],
                    alignment: .leading,
                    spacing: 6
                ) {
                    ForEach(Array(metrics.enumerated()), id: \.offset) { _, metric in
                        Text("\(metric.label) \(metric.value)")
                            .font(SnapVetFont.bodySmall.weight(.semibold))
                            .foregroundColor(.snapvetTextSecondary)
                            .frame(maxWidth: .infinity, alignment: .leading)
                    }
                }
            }

            let notes = record.notes?.trimmingCharacters(in: .whitespacesAndNewlines) ?? ""
            if !notes.isEmpty {
                Text("Notes: \(notes)")
                    .font(SnapVetFont.bodySmall)
                    .foregroundColor(.snapvetTextSecondary)
                    .lineLimit(2)
            }
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .padding(12)
        .background(
            RoundedRectangle(cornerRadius: 12, style: .continuous)
                .fill(Color.snapvetHeaderBg.opacity(0.5))
        )
        .overlay(
            RoundedRectangle(cornerRadius: 12, style: .continuous)
                .stroke(Color.snapvetBorderSubtle, lineWidth: 1)
        )
    }

    private func snapshotMetrics(for record: VitalRecord) -> [SnapshotMetric] {
        var metrics: [SnapshotMetric] = []

        func append(_ label: String, _ value: String?) {
            guard let value, !value.isEmpty else { return }
            metrics.append(SnapshotMetric(label: label, value: value))
        }

        append("HR", record.hr?.intValue.description)
        append("RR", record.rr?.intValue.description)
        append("SpO₂", record.spo2?.intValue.description)
        append("EtCO₂", record.etco2?.intValue.description)
        append("BP", snapshotBloodPressure(for: record))
        append("Temp", displayTemperature(record.temp?.doubleValue))
        append("Iso/Sevo", formatOptionalDouble(record.sevoIso?.doubleValue))
        append("O₂", formatOptionalDouble(record.o2Flow?.doubleValue))
        append("Fluids", formatOptionalDouble(record.fluids?.doubleValue))
        append("Pulse", displayEnum(record.pulseQuality?.name, fallback: ""))

        return metrics
    }

    private func snapshotBloodPressure(for record: VitalRecord) -> String? {
        let sys = record.bpSys?.intValue
        let dia = record.bpDia?.intValue
        let map = record.bpMap?.intValue
        let formatted = formatBloodPressure(sys: sys, dia: dia, map: map)
        return formatted == "—" ? nil : formatted
    }

    private var observationsPanel: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("Clinical Observations")
                .font(SnapVetFont.headlineMedium)
                .foregroundColor(.snapvetTextPrimary)

            observationRow(
                title: "ECG",
                options: [
                    ObservationOption(id: "NSR", label: "Normal"),
                    ObservationOption(id: "SINUS_BRADY", label: "Brady"),
                    ObservationOption(id: "SINUS_TACHY", label: "Tachy"),
                    ObservationOption(id: "VPCS", label: "VPCs"),
                    ObservationOption(id: "ATRIAL_FIB", label: "A-Fib"),
                    ObservationOption(id: "ASYSTOLE", label: "Asystole"),
                    ObservationOption(id: "OTHER", label: ecgOtherChipLabel)
                ],
                selectedId: current.ecg?.name,
                onSelect: { selected in
                    if selected == "OTHER" {
                        ecgOtherInput = current.ecgOtherText ?? ""
                        viewModel.updateEcg(name: selected)
                        showEcgOtherEditor = true
                    } else {
                        viewModel.updateEcg(name: selected)
                        viewModel.updateEcgOtherText(nil)
                    }
                }
            )

            observationRow(
                title: "CRT (Capillary Refill Time)",
                options: [
                    ObservationOption(id: "LESS_THAN_1_SEC", label: "< 1 sec"),
                    ObservationOption(id: "BETWEEN_1_AND_2_SEC", label: "1-2 sec"),
                    ObservationOption(id: "BETWEEN_2_AND_3_SEC", label: "2-3 sec"),
                    ObservationOption(id: "GREATER_THAN_3_SEC", label: "> 3 sec")
                ],
                selectedId: current.crt?.name,
                onSelect: { viewModel.updateCrt(name: $0) }
            )

            observationRow(
                title: "Mucous Membrane (MM)",
                options: [
                    ObservationOption(id: "PINK", label: "Pink"),
                    ObservationOption(id: "PALE", label: "Pale"),
                    ObservationOption(id: "BLUE", label: "Cyanotic"),
                    ObservationOption(id: "INJECTED", label: "Injected"),
                    ObservationOption(id: "ICTERIC", label: "Icteric")
                ],
                selectedId: current.mucousMembrane?.name,
                onSelect: { viewModel.updateMucousMembrane(name: $0) }
            )

            observationRow(
                title: "Pulse Quality",
                options: [
                    ObservationOption(id: "STRONG", label: "Strong"),
                    ObservationOption(id: "MODERATE", label: "Moderate"),
                    ObservationOption(id: "WEAK", label: "Weak"),
                    ObservationOption(id: "ABSENT", label: "Absent")
                ],
                selectedId: current.pulseQuality?.name,
                onSelect: { viewModel.updatePulseQuality(name: $0) }
            )

            VStack(alignment: .leading, spacing: 6) {
                Text("Notes")
                    .font(SnapVetFont.titleMedium)
                    .foregroundColor(.snapvetTextSecondary)

                TextField(
                    "Quick notes (optional)",
                    text: Binding(
                        get: { current.notes ?? "" },
                        set: { viewModel.updateNotes($0) }
                    )
                )
                .focused($isNotesFieldFocused)
                .padding(.horizontal, 14)
                .frame(height: 46)
                .background(
                    RoundedRectangle(cornerRadius: 10, style: .continuous)
                        .fill(Color.snapvetHeaderBg.opacity(0.5))
                )
                .overlay(
                    RoundedRectangle(cornerRadius: 10, style: .continuous)
                        .stroke(Color.snapvetBorderSubtle, lineWidth: 1)
                )
                .foregroundColor(.snapvetTextPrimary)
            }
        }
        .padding(16)
        .snapVetGlassCard(cornerRadius: 20)
    }

    private func observationRow(
        title: String,
        options: [ObservationOption],
        selectedId: String?,
        onSelect: @escaping (String) -> Void
    ) -> some View {
        VStack(alignment: .leading, spacing: 8) {
            Text(title)
                .font(SnapVetFont.titleMedium)
                .foregroundColor(.snapvetTextSecondary)

            LazyVGrid(columns: [GridItem(.adaptive(minimum: 88), spacing: 8)], alignment: .leading, spacing: 8) {
                ForEach(options) { option in
                    Button(action: {
                        SnapVetHaptics.selection()
                        onSelect(option.id)
                    }) {
                        Text(option.label)
                            .font(SnapVetFont.bodyMedium.weight(.semibold))
                            .foregroundColor(selectedId == option.id ? .white : .snapvetTextPrimary)
                            .frame(maxWidth: .infinity)
                            .frame(height: 38)
                            .background(
                                RoundedRectangle(cornerRadius: 10, style: .continuous)
                                    .fill(selectedId == option.id ? Color.snapvetAccentPrimary : Color.snapvetHeaderBg.opacity(0.5))
                            )
                            .overlay(
                                RoundedRectangle(cornerRadius: 10, style: .continuous)
                                    .stroke(selectedId == option.id ? Color.snapvetAccentPrimary : Color.snapvetBorderSubtle, lineWidth: 1)
                            )
                    }
                    .buttonStyle(.plain)
                }
            }
        }
    }

    private var saveBar: some View {
        VStack(spacing: 6) {
            Button(action: {
                dismissKeyboard()
                isNotesFieldFocused = false
                SnapVetHaptics.majorSave()
                viewModel.save()
            }) {
                HStack(spacing: 8) {
                    Image(systemName: "square.and.arrow.down")
                    Text(state.isSaving ? "Saving..." : "Save Entry")
                        .font(SnapVetFont.titleLarge.weight(.semibold))
                }
                .foregroundColor(.white)
                .frame(maxWidth: .infinity)
                .frame(height: 52)
                .background(
                    RoundedRectangle(cornerRadius: 12, style: .continuous)
                        .fill(Color.snapvetAccentSuccess)
                )
                .overlay(
                    RoundedRectangle(cornerRadius: 12, style: .continuous)
                        .stroke(shouldNudgeSave ? Color.snapvetAccentWarning : Color.clear, lineWidth: 2)
                )
            }
            .buttonStyle(.plain)

            Text(saveStatusText)
                .font(SnapVetFont.bodySmall)
                .foregroundColor(shouldNudgeSave ? .snapvetAccentWarning : .snapvetTextSecondary)
        }
        .padding(.horizontal, 16)
        .padding(.vertical, 10)
        .background(
            Rectangle()
                .fill(Color.snapvetHeaderBg.opacity(0.92))
                .ignoresSafeArea(edges: .bottom)
        )
    }

    private var saveStatusText: String {
        if let seconds = state.secondsSinceLastSave?.int64Value {
            return "Saved \(relativeElapsed(seconds: seconds)) ago"
        }
        return "Not saved yet"
    }

    private func formattedValue(for field: NumericField) -> String {
        switch field {
        case .hr: return displayInt(current.hr)
        case .rr: return displayInt(current.rr)
        case .spo2: return displayInt(current.spo2)
        case .etco2: return displayInt(current.etco2)
        case .bp:
            return formatBloodPressure(
                sys: current.bpSys?.intValue,
                dia: current.bpDia?.intValue,
                map: current.bpMap?.intValue
            )
        case .temp: return displayTemperature(current.temp?.doubleValue) ?? "--"
        case .sevoIso: return displayDouble(current.sevoIso)
        case .o2Flow: return displayDouble(current.o2Flow)
        case .fluids: return displayDouble(current.fluids)
        }
    }

    private func previousValue(for field: NumericField) -> String? {
        guard let lastSaved else { return nil }
        switch field {
        case .hr: return lastSaved.hr?.intValue.description
        case .rr: return lastSaved.rr?.intValue.description
        case .spo2: return lastSaved.spo2?.intValue.description
        case .etco2: return lastSaved.etco2?.intValue.description
        case .bp:
            return formatBloodPressure(
                sys: lastSaved.bpSys?.intValue,
                dia: lastSaved.bpDia?.intValue,
                map: lastSaved.bpMap?.intValue
            )
        case .temp: return displayTemperature(lastSaved.temp?.doubleValue)
        case .sevoIso: return formatOptionalDouble(lastSaved.sevoIso?.doubleValue)
        case .o2Flow: return formatOptionalDouble(lastSaved.o2Flow?.doubleValue)
        case .fluids: return formatOptionalDouble(lastSaved.fluids?.doubleValue)
        }
    }

    private func rawFieldValue(for field: NumericField) -> String {
        switch field {
        case .hr: return current.hr?.intValue.description ?? ""
        case .rr: return current.rr?.intValue.description ?? ""
        case .spo2: return current.spo2?.intValue.description ?? ""
        case .etco2: return current.etco2?.intValue.description ?? ""
        case .bp: return ""
        case .temp: return displayTemperature(current.temp?.doubleValue) ?? ""
        case .sevoIso: return formatOptionalDouble(current.sevoIso?.doubleValue) ?? ""
        case .o2Flow: return formatOptionalDouble(current.o2Flow?.doubleValue) ?? ""
        case .fluids: return formatOptionalDouble(current.fluids?.doubleValue) ?? ""
        }
    }

    private func applyNumeric(field: NumericField, value: String) {
        var hr = current.hr
        var rr = current.rr
        var spo2 = current.spo2
        var etco2 = current.etco2
        var temp = current.temp
        var sevoIso = current.sevoIso
        var o2Flow = current.o2Flow
        var fluids = current.fluids

        switch field {
        case .hr: hr = kotlinInt(value)
        case .rr: rr = kotlinInt(value)
        case .spo2: spo2 = kotlinInt(value)
        case .etco2: etco2 = kotlinInt(value)
        case .bp:
            break
        case .temp:
            if let parsed = Double(value), temperatureUnit == .fahrenheit {
                temp = KotlinDouble(double: (parsed - 32.0) * 5.0 / 9.0)
            } else {
                temp = kotlinDouble(value)
            }
        case .sevoIso: sevoIso = kotlinDouble(value)
        case .o2Flow: o2Flow = kotlinDouble(value)
        case .fluids: fluids = kotlinDouble(value)
        }

        viewModel.updateVitals(
            VitalsInput(
                hr: hr,
                rr: rr,
                spo2: spo2,
                etco2: etco2,
                bpSys: current.bpSys,
                bpDia: current.bpDia,
                bpMap: current.bpMap,
                temp: temp,
                sevoIso: sevoIso,
                o2Flow: o2Flow,
                fluids: fluids,
                ecg: current.ecg,
                ecgOtherText: current.ecgOtherText,
                crt: current.crt,
                pulseQuality: current.pulseQuality,
                mucousMembrane: current.mucousMembrane,
                notes: current.notes
            )
        )
    }

    private func computeMap(sys: KotlinInt?, dia: KotlinInt?) -> KotlinInt? {
        guard let sys, let dia else { return nil }
        let map = Int(dia.intValue) + ((Int(sys.intValue) - Int(dia.intValue)) / 3)
        return KotlinInt(int: Int32(map))
    }

    private func status(for field: NumericField) -> ParameterStatus {
        guard enableVitalWarnings else { return .normal }
        let isFeline = speciesProfile == .feline

        switch field {
        case .hr:
            return statusForInt(
                current.hr,
                warningRange: isFeline ? 80...180 : 50...160,
                alertRange: isFeline ? 60...220 : 40...200
            )
        case .rr:
            return statusForInt(
                current.rr,
                warningRange: isFeline ? 12...45 : 8...40,
                alertRange: isFeline ? 8...60 : 5...55
            )
        case .spo2:
            guard let value = current.spo2?.intValue else { return .normal }
            if value < 90 { return .alert }
            if value < 95 { return .warning }
            return .normal
        case .etco2:
            guard let value = current.etco2?.intValue else { return .normal }
            if value < 25 || value > 65 { return .alert }
            if value < 30 || value > 55 { return .warning }
            return .normal
        case .bp:
            let systolicStatus = statusForInt(
                current.bpSys,
                warningRange: isFeline ? 90...170 : 80...170,
                alertRange: isFeline ? 80...190 : 70...190
            )
            let diastolicStatus = statusForInt(current.bpDia, warningRange: 45...110, alertRange: 35...130)
            let mapStatus = statusForInt(
                current.bpMap,
                warningRange: isFeline ? 65...120 : 60...120,
                alertRange: isFeline ? 60...130 : 55...130
            )
            if systolicStatus == .alert || diastolicStatus == .alert || mapStatus == .alert { return .alert }
            if systolicStatus == .warning || diastolicStatus == .warning || mapStatus == .warning { return .warning }
            return .normal
        case .temp:
            guard let value = current.temp?.doubleValue else { return .normal }
            let celsius = value
            if isFeline {
                if celsius < 36.0 || celsius > 40.5 { return .alert }
                if celsius < 37.0 || celsius > 39.5 { return .warning }
                return .normal
            }
            if celsius < 35.5 || celsius > 40.0 { return .alert }
            if celsius < 36.5 || celsius > 39.0 { return .warning }
            return .normal
        case .sevoIso, .o2Flow, .fluids:
            return .normal
        }
    }

    private var speciesProfile: SpeciesProfile {
        let normalized = species.trimmingCharacters(in: .whitespacesAndNewlines).lowercased()
        if normalized.contains("feline") || normalized.contains("cat") {
            return .feline
        }
        return .canine
    }

    private func statusForInt(_ value: KotlinInt?, warningRange: ClosedRange<Int>, alertRange: ClosedRange<Int>) -> ParameterStatus {
        guard let value = value?.intValue else { return .normal }
        if !alertRange.contains(Int(value)) { return .alert }
        if !warningRange.contains(Int(value)) { return .warning }
        return .normal
    }

    private func displayInt(_ value: KotlinInt?) -> String {
        value?.intValue.description ?? "--"
    }

    private func displayDouble(_ value: KotlinDouble?) -> String {
        formatOptionalDouble(value?.doubleValue) ?? "--"
    }

    private func formatOptionalDouble(_ value: Double?) -> String? {
        guard let value else { return nil }
        if value.rounded() == value {
            return "\(Int(value))"
        }
        return String(format: "%.1f", value)
    }

    private var shouldNudgeSave: Bool {
        guard let seconds = state.secondsSinceLastSave?.int64Value else { return false }
        return seconds >= Int64(max(1, saveNudgeIntervalMinutes) * 60)
    }

    private var weightUnit: WeightUnit {
        WeightUnit(rawValue: weightUnitRawValue) ?? .lb
    }

    private var temperatureUnit: TemperatureUnit {
        TemperatureUnit(rawValue: temperatureUnitRawValue) ?? .celsius
    }

    private func unitLabel(for field: NumericField) -> String {
        if field == .temp {
            return temperatureUnit.title
        }
        return field.unit
    }

    private func displayTemperature(_ celsius: Double?) -> String? {
        guard let celsius else { return nil }
        if temperatureUnit == .fahrenheit {
            return formatOptionalDouble((celsius * 9.0 / 5.0) + 32.0)
        }
        return formatOptionalDouble(celsius)
    }

    private func feedbackSelection() {
        SnapVetHaptics.selection()
    }

    private func feedbackSaveAction() {
        SnapVetHaptics.primaryAction()
    }

    private func dismissKeyboard() {
        UIApplication.shared.sendAction(
            #selector(UIResponder.resignFirstResponder),
            to: nil,
            from: nil,
            for: nil
        )
    }

    private func displaySpecies(_ value: String) -> String {
        value.capitalized
    }

    private func displayWeight(_ value: String) -> String {
        guard !value.isEmpty else { return "—" }
        guard let pounds = Double(value) else { return "—" }
        let displayed = weightUnit == .kg ? (pounds / 2.20462) : pounds
        if displayed.rounded() == displayed {
            return "\(Int(displayed)) \(weightUnit.title)"
        }
        return String(format: "%.1f %@", displayed, weightUnit.title)
    }

    private var ecgOtherChipLabel: String {
        let text = current.ecgOtherText?.trimmingCharacters(in: .whitespacesAndNewlines) ?? ""
        return text.isEmpty ? "Other" : text
    }

    private func displayEnum(_ rawName: String?, fallback: String) -> String {
        guard let rawName else { return fallback }
        return rawName
            .replacingOccurrences(of: "_", with: " ")
            .lowercased()
            .capitalized
    }

    private func formatElapsed(seconds: Int64) -> String {
        let hours = max(0, seconds / 3600)
        let minutes = max(0, (seconds % 3600) / 60)
        let remaining = max(0, seconds % 60)
        return String(format: "%02d:%02d:%02d", hours, minutes, remaining)
    }

    private func relativeElapsed(seconds: Int64) -> String {
        if seconds >= 3600 {
            return "\(seconds / 3600)h"
        }
        if seconds >= 60 {
            return "\(seconds / 60)m"
        }
        return "\(seconds)s"
    }

    private func formatTime(_ instant: KotlinInstant) -> String {
        let date = Date(timeIntervalSince1970: TimeInterval(instant.toEpochMilliseconds()) / 1000)
        return DateFormatter.snapvetClock.string(from: date)
    }

    private func formatBloodPressure(sys: Int?, dia: Int?, map: Int?) -> String {
        if let sys, let dia, let map {
            return "\(sys)/\(dia) (\(map))"
        }
        if let sys, let dia {
            return "\(sys)/\(dia)"
        }
        if let map {
            return "MAP \(map)"
        }
        return "—"
    }

    private var ecgOtherEditor: some View {
        NavigationStack {
            VStack(alignment: .leading, spacing: 12) {
                Text("Enter custom ECG value")
                    .font(SnapVetFont.titleMedium)
                    .foregroundColor(.snapvetTextSecondary)

                TextField("Type ECG value", text: $ecgOtherInput)
                    .textInputAutocapitalization(.words)
                    .focused($isEcgOtherFieldFocused)
                    .padding(.horizontal, 14)
                    .frame(height: 46)
                    .background(
                        RoundedRectangle(cornerRadius: 10, style: .continuous)
                            .fill(Color.snapvetHeaderBg.opacity(0.5))
                    )
                    .overlay(
                        RoundedRectangle(cornerRadius: 10, style: .continuous)
                            .stroke(Color.snapvetBorderSubtle, lineWidth: 1)
                    )
                    .foregroundColor(.snapvetTextPrimary)

                Spacer()
            }
            .padding(16)
            .onAppear {
                DispatchQueue.main.async {
                    isEcgOtherFieldFocused = true
                }
            }
            .onDisappear {
                isEcgOtherFieldFocused = false
            }
            .navigationTitle("ECG Other")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Cancel") {
                        showEcgOtherEditor = false
                    }
                }
                ToolbarItem(placement: .confirmationAction) {
                    Button("Save") {
                        viewModel.updateEcg(name: "OTHER")
                        viewModel.updateEcgOtherText(ecgOtherInput)
                        showEcgOtherEditor = false
                    }
                }
            }
        }
    }

    private var bloodPressureEditor: some View {
        VStack(spacing: 12) {
            HStack {
                Button("Cancel") {
                    showBpEditor = false
                }
                .font(SnapVetFont.titleMedium.weight(.semibold))

                Spacer()

                Text("Blood Pressure")
                    .font(SnapVetFont.headlineMedium.weight(.semibold))
                    .foregroundColor(.snapvetTextPrimary)

                Spacer()

                Button("Save") {
                    applyBloodPressureInputs()
                    showBpEditor = false
                }
                .font(SnapVetFont.titleMedium.weight(.semibold))
            }
            .padding(.horizontal, 16)
            .padding(.vertical, 12)
            .background(
                RoundedRectangle(cornerRadius: 12, style: .continuous)
                    .fill(Color.snapvetHeaderBg.opacity(0.75))
            )
            .overlay(
                RoundedRectangle(cornerRadius: 12, style: .continuous)
                    .stroke(Color.snapvetBorderSubtle, lineWidth: 1)
            )
            .padding(.horizontal, 12)
            .padding(.top, 24)
            .padding(.bottom, 8)

            VStack(spacing: 12) {
                VStack(spacing: 8) {
                    ForEach(BloodPressureEditorField.allCases, id: \.shortLabel) { field in
                        Button {
                            selectedBpField = field
                            feedbackSelection()
                        } label: {
                            HStack {
                                VStack(alignment: .leading, spacing: 2) {
                                    Text("\(field.shortLabel) - \(field.fullLabel)")
                                        .font(SnapVetFont.bodySmall)
                                        .foregroundColor(.snapvetTextSecondary)
                                    Text(bpFieldValue(field).isEmpty ? "—" : bpFieldValue(field))
                                        .font(SnapVetFont.titleMedium.weight(.semibold))
                                        .foregroundColor(.snapvetTextPrimary)
                                }
                                Spacer()
                                if selectedBpField == field {
                                    Image(systemName: "checkmark.circle.fill")
                                        .foregroundColor(.snapvetAccentPrimary)
                                }
                            }
                            .padding(12)
                            .background(
                                RoundedRectangle(cornerRadius: 10, style: .continuous)
                                    .fill(Color.snapvetHeaderBg.opacity(0.55))
                            )
                            .overlay(
                                RoundedRectangle(cornerRadius: 10, style: .continuous)
                                    .stroke(
                                        selectedBpField == field ? Color.snapvetAccentPrimary : Color.snapvetBorderSubtle,
                                        lineWidth: 1
                                    )
                            )
                        }
                        .buttonStyle(.plain)
                    }
                }

                NumericKeypadView(
                    currentValue: Binding(
                        get: { bpFieldValue(selectedBpField) },
                        set: { newValue in
                            updateBpField(selectedBpField) { _ in newValue }
                        }
                    ),
                    unitLabel: "mmHg",
                    showsDecimalKey: false,
                    onNumberTap: { number in
                        feedbackSelection()
                        updateBpField(selectedBpField) { $0 + number }
                    },
                    onDecimalTap: {},
                    onBackspaceTap: {
                        feedbackSelection()
                        updateBpField(selectedBpField) { value in
                            guard !value.isEmpty else { return value }
                            return String(value.dropLast())
                        }
                    },
                    onConfirm: {
                        feedbackSaveAction()
                        if let nextField = nextBpField(after: selectedBpField) {
                            selectedBpField = nextField
                        } else {
                            applyBloodPressureInputs()
                            showBpEditor = false
                        }
                    },
                    onClear: {
                        feedbackSelection()
                        updateBpField(selectedBpField) { _ in "" }
                    },
                    onCancel: {
                        SnapVetHaptics.lightTap()
                        showBpEditor = false
                    }
                )
            }
            .padding(.horizontal, 12)
            .padding(.bottom, 20)
        }
    }

    private func applyBloodPressureInputs() {
        let sys = kotlinInt(bpSysInput)
        let dia = kotlinInt(bpDiaInput)
        let map = bpMapInput.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty
            ? computeMap(sys: sys, dia: dia)
            : kotlinInt(bpMapInput)

        viewModel.updateVitals(
            VitalsInput(
                hr: current.hr,
                rr: current.rr,
                spo2: current.spo2,
                etco2: current.etco2,
                bpSys: sys,
                bpDia: dia,
                bpMap: map,
                temp: current.temp,
                sevoIso: current.sevoIso,
                o2Flow: current.o2Flow,
                fluids: current.fluids,
                ecg: current.ecg,
                ecgOtherText: current.ecgOtherText,
                crt: current.crt,
                pulseQuality: current.pulseQuality,
                mucousMembrane: current.mucousMembrane,
                notes: current.notes
            )
        )
    }

    private func bpFieldValue(_ field: BloodPressureEditorField) -> String {
        switch field {
        case .sap: return bpSysInput
        case .dap: return bpDiaInput
        case .map: return bpMapInput
        }
    }

    private func updateBpField(_ field: BloodPressureEditorField, transform: (String) -> String) {
        switch field {
        case .sap: bpSysInput = transform(bpSysInput)
        case .dap: bpDiaInput = transform(bpDiaInput)
        case .map: bpMapInput = transform(bpMapInput)
        }
    }

    private func nextBpField(after field: BloodPressureEditorField) -> BloodPressureEditorField? {
        switch field {
        case .sap: return .dap
        case .dap: return .map
        case .map: return nil
        }
    }
}

private enum SpeciesProfile {
    case canine
    case feline
}

private extension DateFormatter {
    static let snapvetClock: DateFormatter = {
        let formatter = DateFormatter()
        formatter.timeStyle = .medium
        formatter.dateStyle = .none
        return formatter
    }()
}

private func kotlinInt(_ value: String) -> KotlinInt? {
    guard let intValue = Int32(value) else { return nil }
    return KotlinInt(int: intValue)
}

private func kotlinDouble(_ value: String) -> KotlinDouble? {
    guard let doubleValue = Double(value) else { return nil }
    return KotlinDouble(double: doubleValue)
}

private extension View {
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
