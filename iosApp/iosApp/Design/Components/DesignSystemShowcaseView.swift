// SnapVet Design System - Full Component Showcase
// Shows realistic monitoring screen states: start of case (empty) and mid-surgery
import SwiftUI

// MARK: - Mid-Surgery Showcase (realistic monitoring state ~25 min into surgery)

struct DesignSystemShowcaseView: View {
    @State private var keypadValue: String = "72"
    @State private var selectedChipId: String? = "pink"
    @State private var selectedEcgId: String? = "nsr"
    @State private var selectedCrtId: String? = "lt2"
    @Environment(\.horizontalSizeClass) private var horizontalSizeClass

    private let mucousMembraneOptions = [
        ChipOption(id: "pink", label: "Pink (Normal)", color: Color(red: 1.0, green: 0.75, blue: 0.80)),
        ChipOption(id: "pale", label: "Pale", color: Color(red: 1.0, green: 0.94, blue: 0.96)),
        ChipOption(id: "cyanotic", label: "Cyanotic", color: Color(red: 0.6, green: 0.7, blue: 0.9)),
        ChipOption(id: "grey", label: "Grey (Shock)", color: Color(red: 0.6, green: 0.6, blue: 0.6)),
        ChipOption(id: "muddy", label: "Muddy", color: Color(red: 0.6, green: 0.45, blue: 0.3))
    ]

    private let ecgOptions = [
        ChipOption(id: "nsr", label: "NSR", color: Color.snapvetTileBg),
        ChipOption(id: "sinus_brady", label: "Sinus Bradycardia", color: Color.snapvetTileBg),
        ChipOption(id: "sinus_tachy", label: "Sinus Tachycardia", color: Color.snapvetTileBg),
        ChipOption(id: "vpcs", label: "VPCs", color: Color.snapvetTileBg),
        ChipOption(id: "atrial_fib", label: "Atrial Fibrillation", color: Color.snapvetTileBg)
    ]

    private let crtOptions = [
        ChipOption(id: "lt2", label: "< 2 sec (Normal)", color: Color.snapvetTileBg),
        ChipOption(id: "gt2", label: "> 2 sec (Delayed)", color: Color.snapvetTileBg)
    ]

    var body: some View {
        GeometryReader { proxy in
            let isCompact = isCompactLayout(width: proxy.size.width, sizeClass: horizontalSizeClass)
            let columns = monitoringGridColumns(for: proxy.size.width, sizeClass: horizontalSizeClass)

            VStack(spacing: 0) {
                // Patient Info Bar — always visible at top
                PatientInfoBarView(
                    patientName: "Bella",
                    weight: "12.4",
                    species: "Dog — Labrador Retriever",
                    elapsedTime: "25:10",
                    batteryLevel: 68
                )

                ScrollView {
                    VStack(spacing: 12) {
                        monitoringGrid(columns: columns)

                        Divider().background(Color.snapvetDivider)

                        // Input overlays: Keypad + Chip Selectors side by side
                        inputComponents(isCompact: isCompact)
                    }
                    .padding(16)
                }
                .background(Color.snapvetPrimaryBg)

                // Bottom bar: Save button + status + End Anesthesia
                bottomBar(isCompact: isCompact)
            }
            .background(Color.snapvetPrimaryBg)
        }
    }

    // MARK: - Monitoring Grid (4x3 matching README spec)

    private func monitoringGrid(columns: [GridItem]) -> some View {
        LazyVGrid(columns: columns, spacing: 12) {
            // Row 1: Critical vitals — updated every 5 min
            ParameterTileView(name: "HR", value: "88", unit: "bpm", status: .normal, previousValue: "85")
            ParameterTileView(name: "RR", value: "12", unit: "bpm", status: .normal)
            ParameterTileView(name: "SpO₂", value: "98", unit: "%", status: .normal)
            ParameterTileView(name: "BP", value: "115/65", unit: "(80)", status: .normal)

            // Row 2: Secondary vitals — updated every 10-30 min
            ParameterTileView(name: "EtCO₂", value: "38", unit: "mmHg", status: .normal)
            ParameterTileView(name: "Temp", value: "37.8", unit: "°C", status: .warning, previousValue: "38.1")
            ParameterTileView(name: "Sevo%", value: "2.0", unit: "%", status: .normal)
            ParameterTileView(name: "O₂ Flow", value: "1.5", unit: "L/min", status: .normal)

            // Row 3: Non-numeric (chip selectors) + Notes — usually stable
            ParameterTileView(name: "ECG", value: "NSR", unit: "", status: .normal)
            ParameterTileView(name: "CRT", value: "< 2s", unit: "", status: .normal)
            ParameterTileView(name: "MM", value: "Pink", unit: "", status: .normal)
            ParameterTileView(name: "Notes", value: "—", unit: "", status: .normal)
        }
    }

    // MARK: - Input Components (Keypad + Chip Selectors)

    private func inputComponents(isCompact: Bool) -> some View {
        Group {
            if isCompact {
                VStack(alignment: .leading, spacing: 16) {
                    numericKeypadSection
                    chipSelectorsSection
                }
            } else {
                HStack(alignment: .top, spacing: 16) {
                    numericKeypadSection
                        .frame(maxWidth: 320)
                    chipSelectorsSection
                    Spacer()
                }
            }
        }
    }

    private var numericKeypadSection: some View {
        VStack(alignment: .leading, spacing: 8) {
            sectionHeader("Numeric Keypad — Heart Rate")
            NumericKeypadView(
                currentValue: keypadValue,
                onNumberTap: { num in keypadValue += num },
                onDecimalTap: {
                    if !keypadValue.contains(".") { keypadValue += "." }
                },
                onBackspaceTap: {
                    if !keypadValue.isEmpty { keypadValue.removeLast() }
                },
                onConfirm: {},
                onCancel: { keypadValue = "" }
            )
        }
    }

    private var chipSelectorsSection: some View {
        VStack(alignment: .leading, spacing: 16) {
            VStack(alignment: .leading, spacing: 8) {
                sectionHeader("ECG Rhythm")
                ChipSelectorView(
                    options: ecgOptions,
                    selectedId: selectedEcgId,
                    onSelectionChange: { id in selectedEcgId = id }
                )
                .padding(12)
                .background(Color.snapvetHeaderBg)
                .cornerRadius(12)
            }

            VStack(alignment: .leading, spacing: 8) {
                sectionHeader("CRT")
                ChipSelectorView(
                    options: crtOptions,
                    selectedId: selectedCrtId,
                    onSelectionChange: { id in selectedCrtId = id }
                )
                .padding(12)
                .background(Color.snapvetHeaderBg)
                .cornerRadius(12)
            }

            VStack(alignment: .leading, spacing: 8) {
                sectionHeader("Mucous Membrane")
                ChipSelectorView(
                    options: mucousMembraneOptions,
                    selectedId: selectedChipId,
                    onSelectionChange: { id in selectedChipId = id }
                )
                .padding(12)
                .background(Color.snapvetHeaderBg)
                .cornerRadius(12)
            }
        }
    }

    // MARK: - Bottom Bar (Save button + status + End Anesthesia)

    private func bottomBar(isCompact: Bool) -> some View {
        Group {
            if isCompact {
                VStack(spacing: 12) {
                    HStack(spacing: 16) {
                        saveButton
                        saveStatus
                        Spacer()
                    }
                    endAnesthesiaButton
                }
            } else {
                HStack(spacing: 16) {
                    saveButton
                    saveStatus
                    Spacer()
                    endAnesthesiaButton
                }
            }
        }
        .padding(.horizontal, 16)
        .padding(.vertical, 10)
        .background(Color.snapvetHeaderBg)
    }

    private var saveButton: some View {
        Button(action: {}) {
            HStack(spacing: 8) {
                Image(systemName: "square.and.arrow.down.fill")
                Text("Save")
                    .fontWeight(.semibold)
            }
            .foregroundColor(.white)
            .frame(width: 140)
            .frame(height: 48)
            .background(Color.snapvetAccentPrimary)
            .cornerRadius(12)
        }
    }

    private var saveStatus: some View {
        HStack(spacing: 8) {
            Image(systemName: "checkmark.circle.fill")
                .foregroundColor(.snapvetAccentPrimary)
                .font(.system(size: 16))
            Text("Saved 2m ago")
                .font(SnapVetFont.bodySmall)
                .foregroundColor(.snapvetTextSecondary)
        }
    }

    private var endAnesthesiaButton: some View {
        Button(action: {}) {
            HStack(spacing: 8) {
                Image(systemName: "stop.circle.fill")
                Text("End Anesthesia")
                    .fontWeight(.semibold)
            }
            .foregroundColor(.snapvetAccentAlert)
            .frame(width: 200)
            .frame(height: 48)
            .background(Color.snapvetTileBg)
            .cornerRadius(12)
            .overlay(
                RoundedRectangle(cornerRadius: 12)
                    .stroke(Color.snapvetAccentAlert.opacity(0.4), lineWidth: 1)
            )
        }
    }

    private func sectionHeader(_ title: String) -> some View {
        Text(title)
            .font(SnapVetFont.bodySmall)
            .fontWeight(.semibold)
            .foregroundColor(.snapvetTextTertiary)
            .textCase(.uppercase)
            .tracking(1.2)
            .frame(maxWidth: .infinity, alignment: .leading)
    }
}

// MARK: - Start of Case Showcase (empty tiles at induction)

struct EmptyMonitoringShowcaseView: View {
    @Environment(\.horizontalSizeClass) private var horizontalSizeClass

    var body: some View {
        GeometryReader { proxy in
            let isCompact = isCompactLayout(width: proxy.size.width, sizeClass: horizontalSizeClass)
            let columns = monitoringGridColumns(for: proxy.size.width, sizeClass: horizontalSizeClass)

            VStack(spacing: 0) {
                PatientInfoBarView(
                    patientName: "Whiskers",
                    weight: "4.2",
                    species: "Cat — Domestic Shorthair",
                    elapsedTime: "00:00",
                    batteryLevel: 95
                )

                VStack(spacing: 12) {
                    LazyVGrid(columns: columns, spacing: 12) {
                        // All tiles empty — start of anesthesia, tap any tile to begin entering values
                        ParameterTileView(name: "HR", value: "—", unit: "bpm", status: .normal)
                        ParameterTileView(name: "RR", value: "—", unit: "bpm", status: .normal)
                        ParameterTileView(name: "SpO₂", value: "—", unit: "%", status: .normal)
                        ParameterTileView(name: "BP", value: "—/—", unit: "(—)", status: .normal)

                        ParameterTileView(name: "EtCO₂", value: "—", unit: "mmHg", status: .normal)
                        ParameterTileView(name: "Temp", value: "—", unit: "°C", status: .normal)
                        ParameterTileView(name: "Sevo%", value: "—", unit: "%", status: .normal)
                        ParameterTileView(name: "O₂ Flow", value: "—", unit: "L/min", status: .normal)

                        ParameterTileView(name: "ECG", value: "—", unit: "", status: .normal)
                        ParameterTileView(name: "CRT", value: "—", unit: "", status: .normal)
                        ParameterTileView(name: "MM", value: "—", unit: "", status: .normal)
                        ParameterTileView(name: "Notes", value: "—", unit: "", status: .normal)
                    }
                }
                .padding(16)

                Spacer()

                // Bottom bar — Save disabled (no values yet) + End Anesthesia
                Group {
                    if isCompact {
                        VStack(spacing: 12) {
                            HStack(spacing: 16) {
                                disabledSaveButton
                                tapToBeginStatus
                                Spacer()
                            }
                            endAnesthesiaButton
                        }
                    } else {
                        HStack(spacing: 16) {
                            disabledSaveButton
                            tapToBeginStatus
                            Spacer()
                            endAnesthesiaButton
                        }
                    }
                }
                .padding(.horizontal, 16)
                .padding(.vertical, 10)
                .background(Color.snapvetHeaderBg)
            }
            .background(Color.snapvetPrimaryBg)
        }
    }

    private var disabledSaveButton: some View {
        Button(action: {}) {
            HStack(spacing: 8) {
                Image(systemName: "square.and.arrow.down.fill")
                Text("Save")
                    .fontWeight(.semibold)
            }
            .foregroundColor(.white.opacity(0.4))
            .frame(width: 140)
            .frame(height: 48)
            .background(Color.snapvetAccentPrimary.opacity(0.3))
            .cornerRadius(12)
        }
        .disabled(true)
    }

    private var tapToBeginStatus: some View {
        HStack(spacing: 8) {
            Image(systemName: "circle.dashed")
                .foregroundColor(.snapvetTextTertiary)
                .font(.system(size: 16))
            Text("Tap a tile to begin")
                .font(SnapVetFont.bodySmall)
                .foregroundColor(.snapvetTextTertiary)
        }
    }

    private var endAnesthesiaButton: some View {
        Button(action: {}) {
            HStack(spacing: 8) {
                Image(systemName: "stop.circle.fill")
                Text("End Anesthesia")
                    .fontWeight(.semibold)
            }
            .foregroundColor(.snapvetAccentAlert)
            .frame(width: 200)
            .frame(height: 48)
            .background(Color.snapvetTileBg)
            .cornerRadius(12)
            .overlay(
                RoundedRectangle(cornerRadius: 12)
                    .stroke(Color.snapvetAccentAlert.opacity(0.4), lineWidth: 1)
            )
        }
    }
}

// MARK: - Warning Scenario (hypothermia + dropping SpO₂ mid-surgery)

struct WarningMonitoringShowcaseView: View {
    @Environment(\.horizontalSizeClass) private var horizontalSizeClass

    var body: some View {
        GeometryReader { proxy in
            let isCompact = isCompactLayout(width: proxy.size.width, sizeClass: horizontalSizeClass)
            let columns = monitoringGridColumns(for: proxy.size.width, sizeClass: horizontalSizeClass)

            VStack(spacing: 0) {
                PatientInfoBarView(
                    patientName: "Bella",
                    weight: "12.4",
                    species: "Dog — Labrador Retriever",
                    elapsedTime: "47:30",
                    batteryLevel: 42
                )

                VStack(spacing: 12) {
                    LazyVGrid(columns: columns, spacing: 12) {
                        ParameterTileView(name: "HR", value: "142", unit: "bpm", status: .warning, previousValue: "120")
                        ParameterTileView(name: "RR", value: "8", unit: "bpm", status: .alert, previousValue: "14")
                        ParameterTileView(name: "SpO₂", value: "91", unit: "%", status: .alert, previousValue: "96")
                        ParameterTileView(name: "BP", value: "85/40", unit: "(55)", status: .warning)

                        ParameterTileView(name: "EtCO₂", value: "52", unit: "mmHg", status: .warning, previousValue: "40")
                        ParameterTileView(name: "Temp", value: "36.2", unit: "°C", status: .alert, previousValue: "37.1")
                        ParameterTileView(name: "Sevo%", value: "2.5", unit: "%", status: .normal)
                        ParameterTileView(name: "O₂ Flow", value: "2.0", unit: "L/min", status: .normal)

                        ParameterTileView(name: "ECG", value: "S.Tachy", unit: "", status: .warning)
                        ParameterTileView(name: "CRT", value: "> 2s", unit: "", status: .alert)
                        ParameterTileView(name: "MM", value: "Pale", unit: "", status: .warning)
                        ParameterTileView(name: "Notes", value: "—", unit: "", status: .normal)
                    }
                }
                .padding(16)

                Spacer()

                // Bottom bar — Save with 5-min nudge glow + warning status + End Anesthesia
                Group {
                    if isCompact {
                        VStack(spacing: 12) {
                            HStack(spacing: 16) {
                                saveWithNudgeButton
                                warningStatus
                                Spacer()
                            }
                            endAnesthesiaButton
                        }
                    } else {
                        HStack(spacing: 16) {
                            saveWithNudgeButton
                            warningStatus
                            Spacer()
                            endAnesthesiaButton
                        }
                    }
                }
                .padding(.horizontal, 16)
                .padding(.vertical, 10)
                .background(Color.snapvetHeaderBg)
            }
            .background(Color.snapvetPrimaryBg)
        }
    }

    private var saveWithNudgeButton: some View {
        Button(action: {}) {
            HStack(spacing: 8) {
                Image(systemName: "square.and.arrow.down.fill")
                Text("Save")
                    .fontWeight(.semibold)
            }
            .foregroundColor(.white)
            .frame(width: 140)
            .frame(height: 48)
            .background(Color.snapvetAccentPrimary)
            .cornerRadius(12)
            .overlay(
                RoundedRectangle(cornerRadius: 12)
                    .stroke(Color.snapvetAccentWarning, lineWidth: 2)
            )
        }
    }

    private var warningStatus: some View {
        HStack(spacing: 8) {
            Image(systemName: "exclamationmark.circle.fill")
                .foregroundColor(.snapvetAccentWarning)
                .font(.system(size: 16))
            Text("Last saved 6m ago")
                .font(SnapVetFont.bodySmall)
                .foregroundColor(.snapvetAccentWarning)
        }
    }

    private var endAnesthesiaButton: some View {
        Button(action: {}) {
            HStack(spacing: 8) {
                Image(systemName: "stop.circle.fill")
                Text("End Anesthesia")
                    .fontWeight(.semibold)
            }
            .foregroundColor(.snapvetAccentAlert)
            .frame(width: 200)
            .frame(height: 48)
            .background(Color.snapvetTileBg)
            .cornerRadius(12)
            .overlay(
                RoundedRectangle(cornerRadius: 12)
                    .stroke(Color.snapvetAccentAlert.opacity(0.4), lineWidth: 1)
            )
        }
    }
}

// MARK: - Previews

#Preview("1. Start of Case — Empty Tiles") {
    EmptyMonitoringShowcaseView()
        .previewInterfaceOrientation(.landscapeLeft)
        .previewDevice("iPad Pro (12.9-inch) (6th generation)")
}

#Preview("2. Mid-Surgery — Normal (25 min)") {
    DesignSystemShowcaseView()
        .previewInterfaceOrientation(.landscapeLeft)
        .previewDevice("iPad Pro (12.9-inch) (6th generation)")
}

#Preview("3. Mid-Surgery — Warning Scenario (47 min)") {
    WarningMonitoringShowcaseView()
        .previewInterfaceOrientation(.landscapeLeft)
        .previewDevice("iPad Pro (12.9-inch) (6th generation)")
}

#Preview("4. Full Showcase — Portrait") {
    DesignSystemShowcaseView()
        .previewDevice("iPad Pro (11-inch) (4th generation)")
}

#Preview("5. iPhone Portrait") {
    DesignSystemShowcaseView()
        .previewDevice("iPhone 15 Pro")
}

private func isCompactLayout(width: CGFloat, sizeClass: UserInterfaceSizeClass?) -> Bool {
    if sizeClass == .compact { return true }
    return width < 700
}

private func monitoringGridColumns(for width: CGFloat, sizeClass: UserInterfaceSizeClass?) -> [GridItem] {
    let count: Int
    if sizeClass == .compact || width < 700 {
        count = 2
    } else if width < 900 {
        count = 3
    } else {
        count = 4
    }
    return Array(repeating: GridItem(.flexible(), spacing: 12), count: count)
}
