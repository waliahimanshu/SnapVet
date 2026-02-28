import SwiftUI
import Shared
import UIKit

private enum NumericField: String, CaseIterable, Identifiable {
    case hr = "HR"
    case rr = "RR"
    case spo2 = "SpO₂"
    case etco2 = "EtCO₂"
    case bpSys = "Systolic BP"
    case bpDia = "Diastolic BP"
    case temp = "Temp"
    case sevoIso = "Iso/Sevo"
    case o2Flow = "O₂"

    var unit: String {
        switch self {
        case .hr, .rr: return "bpm"
        case .spo2: return "%"
        case .etco2, .bpSys, .bpDia: return "mmHg"
        case .temp: return "°C"
        case .sevoIso: return "%"
        case .o2Flow: return "L/min"
        }
    }

    var allowsDecimal: Bool {
        switch self {
        case .temp, .sevoIso, .o2Flow:
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
    @State private var showDiscardConfirm = false
    @State private var showEndConfirm = false
    @State private var previousIdleTimerDisabled = false
    @State private var lastErrorMessage: String?
    @FocusState private var isNotesFieldFocused: Bool

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
                            recordedSnapshotsPanel
                        }

                        observationsPanel

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
                unitLabel: field.unit,
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
        .onChange(of: state.errorMessage) { message in
            guard let message, !message.isEmpty else { return }
            guard message != lastErrorMessage else { return }
            lastErrorMessage = message
            SnapVetHaptics.error()
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
                        unit: field.unit,
                        status: status(for: field),
                        previousValue: previousValue(for: field)
                    ) {
                        feedbackSelection()
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
        append("Temp", formatOptionalDouble(record.temp?.doubleValue))
        append("Iso/Sevo", formatOptionalDouble(record.sevoIso?.doubleValue))
        append("O₂", formatOptionalDouble(record.o2Flow?.doubleValue))

        return metrics
    }

    private func snapshotBloodPressure(for record: VitalRecord) -> String? {
        let sys = record.bpSys?.intValue
        let dia = record.bpDia?.intValue
        let map = record.bpMap?.intValue

        if sys == nil, dia == nil, map == nil {
            return nil
        }

        if sys == nil, dia == nil, let map {
            return "MAP \(map)"
        }

        let pressure = "\(sys.map(String.init) ?? "-")/\(dia.map(String.init) ?? "-")"
        if let map {
            return "\(pressure) (MAP \(map))"
        }
        return pressure
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
                    ObservationOption(id: "ATRIAL_FIB", label: "A-Fib")
                ],
                selectedId: current.ecg?.name,
                onSelect: { viewModel.updateEcg(name: $0) }
            )

            observationRow(
                title: "CRT (Capillary Refill Time)",
                options: [
                    ObservationOption(id: "LESS_THAN_2_SEC", label: "<2s"),
                    ObservationOption(id: "GREATER_THAN_2_SEC", label: ">2s")
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
                    ObservationOption(id: "GREY", label: "Grey"),
                    ObservationOption(id: "MUDDY", label: "Muddy")
                ],
                selectedId: current.mucousMembrane?.name,
                onSelect: { viewModel.updateMucousMembrane(name: $0) }
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
                        .stroke(state.shouldNudgeSave ? Color.snapvetAccentWarning : Color.clear, lineWidth: 2)
                )
            }
            .buttonStyle(.plain)

            Text(saveStatusText)
                .font(SnapVetFont.bodySmall)
                .foregroundColor(state.shouldNudgeSave ? .snapvetAccentWarning : .snapvetTextSecondary)
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
        case .bpSys: return displayInt(current.bpSys)
        case .bpDia: return displayInt(current.bpDia)
        case .temp: return displayDouble(current.temp)
        case .sevoIso: return displayDouble(current.sevoIso)
        case .o2Flow: return displayDouble(current.o2Flow)
        }
    }

    private func previousValue(for field: NumericField) -> String? {
        guard let lastSaved else { return nil }
        switch field {
        case .hr: return lastSaved.hr?.intValue.description
        case .rr: return lastSaved.rr?.intValue.description
        case .spo2: return lastSaved.spo2?.intValue.description
        case .etco2: return lastSaved.etco2?.intValue.description
        case .bpSys: return lastSaved.bpSys?.intValue.description
        case .bpDia: return lastSaved.bpDia?.intValue.description
        case .temp: return formatOptionalDouble(lastSaved.temp?.doubleValue)
        case .sevoIso: return formatOptionalDouble(lastSaved.sevoIso?.doubleValue)
        case .o2Flow: return formatOptionalDouble(lastSaved.o2Flow?.doubleValue)
        }
    }

    private func rawFieldValue(for field: NumericField) -> String {
        switch field {
        case .hr: return current.hr?.intValue.description ?? ""
        case .rr: return current.rr?.intValue.description ?? ""
        case .spo2: return current.spo2?.intValue.description ?? ""
        case .etco2: return current.etco2?.intValue.description ?? ""
        case .bpSys: return current.bpSys?.intValue.description ?? ""
        case .bpDia: return current.bpDia?.intValue.description ?? ""
        case .temp: return formatOptionalDouble(current.temp?.doubleValue) ?? ""
        case .sevoIso: return formatOptionalDouble(current.sevoIso?.doubleValue) ?? ""
        case .o2Flow: return formatOptionalDouble(current.o2Flow?.doubleValue) ?? ""
        }
    }

    private func applyNumeric(field: NumericField, value: String) {
        var hr = current.hr
        var rr = current.rr
        var spo2 = current.spo2
        var etco2 = current.etco2
        var bpSys = current.bpSys
        var bpDia = current.bpDia
        var bpMap = current.bpMap
        var temp = current.temp
        var sevoIso = current.sevoIso
        var o2Flow = current.o2Flow

        switch field {
        case .hr: hr = kotlinInt(value)
        case .rr: rr = kotlinInt(value)
        case .spo2: spo2 = kotlinInt(value)
        case .etco2: etco2 = kotlinInt(value)
        case .bpSys:
            bpSys = kotlinInt(value)
            bpMap = computeMap(sys: bpSys, dia: bpDia)
        case .bpDia:
            bpDia = kotlinInt(value)
            bpMap = computeMap(sys: bpSys, dia: bpDia)
        case .temp: temp = kotlinDouble(value)
        case .sevoIso: sevoIso = kotlinDouble(value)
        case .o2Flow: o2Flow = kotlinDouble(value)
        }

        viewModel.updateVitals(
            VitalsInput(
                hr: hr,
                rr: rr,
                spo2: spo2,
                etco2: etco2,
                bpSys: bpSys,
                bpDia: bpDia,
                bpMap: bpMap,
                temp: temp,
                sevoIso: sevoIso,
                o2Flow: o2Flow,
                ecg: current.ecg,
                crt: current.crt,
                mucousMembrane: current.mucousMembrane,
                notes: current.notes
            )
        )
    }

    private func computeMap(sys: KotlinInt?, dia: KotlinInt?) -> KotlinInt? {
        guard let sys, let dia else { return nil }
        let map = (Int(sys.intValue) + (2 * Int(dia.intValue))) / 3
        return KotlinInt(int: Int32(map))
    }

    private func status(for field: NumericField) -> ParameterStatus {
        switch field {
        case .hr:
            return statusForInt(current.hr, warningRange: 60...160, alertRange: 45...190)
        case .rr:
            return statusForInt(current.rr, warningRange: 8...45, alertRange: 5...60)
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
        case .bpSys:
            return statusForInt(current.bpSys, warningRange: 80...170, alertRange: 70...190)
        case .bpDia:
            return statusForInt(current.bpDia, warningRange: 45...110, alertRange: 35...130)
        case .temp:
            guard let value = current.temp?.doubleValue else { return .normal }
            if value < 35.5 || value > 40 { return .alert }
            if value < 36.5 || value > 39 { return .warning }
            return .normal
        case .sevoIso, .o2Flow:
            return .normal
        }
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
        return "\(value) lb"
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
