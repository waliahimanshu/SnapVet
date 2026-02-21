// SnapVet Design System - Parameter Tile Component
import SwiftUI

enum ParameterStatus {
    case normal
    case warning
    case alert
}

struct ParameterTileView: View {
    let name: String
    let value: String
    let unit: String
    let status: ParameterStatus
    var previousValue: String? = nil
    var action: () -> Void = {}

    private var borderColor: Color {
        switch status {
        case .normal:
            return Color.snapvetBorderSubtle
        case .warning:
            return Color.snapvetAccentWarning.opacity(0.6)
        case .alert:
            return Color.snapvetAccentAlert.opacity(0.6)
        }
    }

    private var valueColor: Color {
        switch status {
        case .normal:
            return Color.snapvetTextPrimary
        case .warning:
            return Color.snapvetAccentWarning
        case .alert:
            return Color.snapvetAccentAlert
        }
    }

    private var shouldShowPreviousValue: Bool {
        guard let prev = previousValue else { return false }
        return prev != value
    }

    var body: some View {
        Button(action: action) {
            VStack(spacing: 8) {
                // Parameter name + previous value
                HStack {
                    Text(name)
                        .font(SnapVetFont.bodyMedium)
                        .fontWeight(.medium)
                        .foregroundColor(.snapvetTextSecondary)

                    Spacer()

                    if shouldShowPreviousValue, let prev = previousValue {
                        Text(prev)
                            .font(SnapVetFont.bodySmall)
                            .foregroundColor(.snapvetTextTertiary)
                    }
                }

                // Value with unit
                HStack(alignment: .lastTextBaseline, spacing: 4) {
                    Text(value)
                        .font(SnapVetFont.displayLarge.weight(.bold))
                        .tracking(-0.5)
                        .foregroundColor(valueColor)

                    if !unit.isEmpty {
                        Text(unit)
                            .font(SnapVetFont.bodySmall)
                            .fontWeight(.medium)
                            .foregroundColor(.snapvetTextSecondary)
                    }
                }
            }
            .frame(maxWidth: .infinity)
            .frame(minHeight: 140)
            .background(Color.snapvetTileBg)
            .cornerRadius(12)
            .overlay(
                RoundedRectangle(cornerRadius: 12)
                    .stroke(borderColor, lineWidth: 1)
            )
            .shadow(radius: 4)
        }
        .buttonStyle(PlainButtonStyle())
    }
}

// MARK: - Previews

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

#Preview("ParameterTile - With Previous Value") {
    VStack(spacing: 16) {
        ParameterTileView(
            name: "Heart Rate",
            value: "88",
            unit: "bpm",
            status: .normal,
            previousValue: "85"
        )
        ParameterTileView(
            name: "Temp",
            value: "37.8",
            unit: "°C",
            status: .warning,
            previousValue: "38.1"
        )
        // Same value — previous should NOT show
        ParameterTileView(
            name: "SpO₂",
            value: "98",
            unit: "%",
            status: .normal,
            previousValue: "98"
        )
    }
    .padding(16)
    .background(Color.snapvetPrimaryBg)
}
