// SnapVet Design System - Full Component Showcase
import SwiftUI

struct DesignSystemShowcaseView: View {
    @State private var keypadValue: String = "72"
    @State private var selectedChipId: String? = "pink"

    private let mucousMembraneOptions = [
        ChipOption(id: "pink", label: "Pink (Normal)", color: Color(red: 1.0, green: 0.75, blue: 0.80)),
        ChipOption(id: "pale", label: "Pale", color: Color(red: 1.0, green: 0.94, blue: 0.96)),
        ChipOption(id: "cyanotic", label: "Cyanotic", color: Color(red: 0.6, green: 0.7, blue: 0.9)),
        ChipOption(id: "red", label: "Red/Injected", color: Color(red: 1.0, green: 0.42, blue: 0.42))
    ]

    var body: some View {
        ScrollView {
            VStack(spacing: 0) {
                // Patient Info Bar
                PatientInfoBarView(
                    patientName: "Bella",
                    weight: "12.4",
                    species: "Dog — Labrador Retriever",
                    elapsedTime: "23:15",
                    batteryLevel: 72
                )

                VStack(spacing: 16) {
                    // Section: Parameter Tiles — all statuses
                    sectionHeader("Parameter Tiles")

                    LazyVGrid(
                        columns: [
                            GridItem(.flexible(), spacing: 12),
                            GridItem(.flexible(), spacing: 12),
                            GridItem(.flexible(), spacing: 12)
                        ],
                        spacing: 12
                    ) {
                        // Normal tiles
                        ParameterTileView(
                            name: "Heart Rate",
                            value: "125",
                            unit: "bpm",
                            status: .normal
                        )
                        ParameterTileView(
                            name: "Resp Rate",
                            value: "18",
                            unit: "bpm",
                            status: .normal
                        )
                        ParameterTileView(
                            name: "Temp",
                            value: "38.2",
                            unit: "°C",
                            status: .normal
                        )

                        // Warning tiles
                        ParameterTileView(
                            name: "SpO₂",
                            value: "93",
                            unit: "%",
                            status: .warning
                        )
                        ParameterTileView(
                            name: "ETCO₂",
                            value: "48",
                            unit: "mmHg",
                            status: .warning
                        )
                        ParameterTileView(
                            name: "MAP",
                            value: "58",
                            unit: "mmHg",
                            status: .warning
                        )

                        // Alert tiles
                        ParameterTileView(
                            name: "BP Systolic",
                            value: "75",
                            unit: "mmHg",
                            status: .alert
                        )
                        ParameterTileView(
                            name: "BP Diastolic",
                            value: "35",
                            unit: "mmHg",
                            status: .alert
                        )
                        ParameterTileView(
                            name: "Heart Rate",
                            value: "42",
                            unit: "bpm",
                            status: .alert
                        )
                    }

                    Divider().background(Color.snapvetDivider)

                    // Bottom section: Keypad + Chip Selector side by side
                    HStack(alignment: .top, spacing: 16) {
                        // Numeric Keypad
                        VStack(alignment: .leading, spacing: 8) {
                            sectionHeader("Numeric Keypad")
                            NumericKeypadView(
                                currentValue: keypadValue,
                                onNumberTap: { num in keypadValue += num },
                                onDecimalTap: {
                                    if !keypadValue.contains(".") {
                                        keypadValue += "."
                                    }
                                },
                                onBackspaceTap: {
                                    if !keypadValue.isEmpty {
                                        keypadValue.removeLast()
                                    }
                                },
                                onConfirm: {},
                                onCancel: { keypadValue = "" }
                            )
                        }
                        .frame(maxWidth: 320)

                        // Chip Selector
                        VStack(alignment: .leading, spacing: 8) {
                            sectionHeader("Chip Selector — Mucous Membrane")
                            ChipSelectorView(
                                options: mucousMembraneOptions,
                                selectedId: selectedChipId,
                                onSelectionChange: { id in selectedChipId = id }
                            )
                            .padding(16)
                            .background(Color.snapvetHeaderBg)
                            .cornerRadius(12)
                        }

                        Spacer()
                    }
                }
                .padding(16)
            }
        }
        .background(Color.snapvetPrimaryBg)
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

// MARK: - Previews

#Preview("Design System Showcase") {
    DesignSystemShowcaseView()
        .previewInterfaceOrientation(.landscapeLeft)
        .previewDevice("iPad Pro (12.9-inch) (6th generation)")
}

#Preview("Design System Showcase — Portrait") {
    DesignSystemShowcaseView()
        .previewDevice("iPad Pro (11-inch) (4th generation)")
}
