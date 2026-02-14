// SnapVet Design System - Component Previews
import SwiftUI

struct SnapVetComponentPreviews: View {
    @State private var selectedChip = "pink"

    var body: some View {
        TabView {
            // Tab 1: Parameter Tiles
            VStack(spacing: 16) {
                Text("Parameter Tiles")
                    .font(SnapVetFont.headlineLarge)
                    .fontWeight(.bold)
                    .foregroundColor(.snapvetTextPrimary)

                ParameterTileView(
                    name: "Heart Rate",
                    value: "125",
                    unit: "bpm",
                    status: .normal
                )

                ParameterTileView(
                    name: "SpO2",
                    value: "94",
                    unit: "%",
                    status: .warning
                )

                ParameterTileView(
                    name: "BP Systolic",
                    value: "75",
                    unit: "mmHg",
                    status: .alert
                )

                Spacer()
            }
            .padding(16)
            .background(Color.snapvetPrimaryBg)
            .tabItem {
                Label("Tiles", systemImage: "square.grid.2x2")
            }

            // Tab 2: Numeric Keypad
            VStack {
                Text("Numeric Keypad")
                    .font(SnapVetFont.headlineLarge)
                    .fontWeight(.bold)
                    .foregroundColor(.snapvetTextPrimary)
                    .padding(16)

                NumericKeypadView(
                    currentValue: "125",
                    onConfirm: { print("Confirmed") },
                    onCancel: { print("Cancelled") }
                )
                .padding(16)

                Spacer()
            }
            .background(Color.snapvetPrimaryBg)
            .tabItem {
                Label("Keypad", systemImage: "123.rectangle")
            }

            // Tab 3: Chip Selector
            VStack(spacing: 20) {
                Text("Chip Selector")
                    .font(SnapVetFont.headlineLarge)
                    .fontWeight(.bold)
                    .foregroundColor(.snapvetTextPrimary)
                    .padding(16)

                VStack(alignment: .leading, spacing: 8) {
                    Text("Mucous Membrane Color")
                        .font(SnapVetFont.bodyLarge)
                        .foregroundColor(.snapvetTextSecondary)

                    ChipSelectorView(
                        options: [
                            ChipOption(id: "pink", label: "Pink (Normal)", color: Color(red: 1.0, green: 0.75, blue: 0.80)),
                            ChipOption(id: "pale", label: "Pale", color: Color(red: 1.0, green: 0.94, blue: 0.96)),
                            ChipOption(id: "red", label: "Red/Injected", color: Color(red: 1.0, green: 0.42, blue: 0.42)),
                            ChipOption(id: "muddy", label: "Muddy/Cyanotic", color: Color(red: 0.35, green: 0.24, blue: 0.36))
                        ],
                        selectedId: selectedChip,
                        onSelectionChange: { selectedChip = $0 }
                    )
                }
                .padding(16)

                Spacer()
            }
            .background(Color.snapvetPrimaryBg)
            .tabItem {
                Label("Chips", systemImage: "list.bullet")
            }

            // Tab 4: Patient Info Bar
            VStack {
                PatientInfoBarView(
                    patientName: "Max",
                    weight: "28.5",
                    species: "Dog",
                    elapsedTime: "12:34",
                    batteryLevel: 85
                )

                Spacer()

                PatientInfoBarView(
                    patientName: "Whiskers",
                    weight: "4.2",
                    species: "Cat",
                    elapsedTime: "05:20",
                    batteryLevel: 35
                )

                Spacer()
            }
            .background(Color.snapvetPrimaryBg)
            .tabItem {
                Label("Header", systemImage: "info.circle")
            }
        }
        .preferredColorScheme(.dark)
    }
}

// MARK: - Individual Previews for Each Component
#Preview("ParameterTile - Normal") {
    ParameterTileView(
        name: "Heart Rate",
        value: "125",
        unit: "bpm",
        status: .normal
    )
    .padding(16)
    .background(Color.snapvetPrimaryBg)
}

#Preview("ParameterTile - Warning") {
    ParameterTileView(
        name: "SpO2",
        value: "94",
        unit: "%",
        status: .warning
    )
    .padding(16)
    .background(Color.snapvetPrimaryBg)
}

#Preview("ParameterTile - Alert") {
    ParameterTileView(
        name: "BP Systolic",
        value: "75",
        unit: "mmHg",
        status: .alert
    )
    .padding(16)
    .background(Color.snapvetPrimaryBg)
}

#Preview("NumericKeypad") {
    NumericKeypadView(
        currentValue: "125",
        onConfirm: { print("Saved") }
    )
    .padding(16)
    .background(Color.snapvetPrimaryBg)
}

#Preview("ChipSelector") {
    ChipSelectorView(
        options: [
            ChipOption(id: "pink", label: "Pink (Normal)", color: Color(red: 1.0, green: 0.75, blue: 0.80)),
            ChipOption(id: "pale", label: "Pale", color: Color(red: 1.0, green: 0.94, blue: 0.96)),
            ChipOption(id: "red", label: "Red/Injected", color: Color(red: 1.0, green: 0.42, blue: 0.42))
        ],
        selectedId: "pink"
    )
    .padding(16)
    .background(Color.snapvetPrimaryBg)
}

#Preview("PatientInfoBar") {
    PatientInfoBarView(
        patientName: "Max",
        weight: "28.5",
        species: "Dog",
        elapsedTime: "12:34",
        batteryLevel: 85
    )
}

#Preview {
    SnapVetComponentPreviews()
}
