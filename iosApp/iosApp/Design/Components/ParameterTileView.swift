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
            return Color.snapvetAccentWarning.opacity(0.8)
        case .alert:
            return Color.snapvetAccentAlert.opacity(0.8)
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
        guard let previousValue else { return false }
        return previousValue != value
    }

    var body: some View {
        Button(action: action) {
            VStack(alignment: .leading, spacing: 12) {
                HStack(alignment: .firstTextBaseline) {
                    Text(name)
                        .font(SnapVetFont.titleMedium)
                        .foregroundColor(.snapvetTextSecondary)

                    Spacer()

                    if shouldShowPreviousValue, let previousValue {
                        Text(previousValue)
                            .font(SnapVetFont.bodySmall)
                            .foregroundColor(.snapvetTextTertiary)
                    }
                }

                HStack(alignment: .bottom, spacing: 10) {
                    Text(value)
                        .font(SnapVetFont.displayMedium.weight(.bold))
                        .foregroundColor(valueColor)
                        .frame(maxWidth: .infinity, alignment: .leading)
                        .padding(.horizontal, 14)
                        .padding(.vertical, 12)
                        .background(
                            RoundedRectangle(cornerRadius: 10, style: .continuous)
                                .fill(Color.snapvetHeaderBg.opacity(0.45))
                        )
                        .overlay(
                            RoundedRectangle(cornerRadius: 10, style: .continuous)
                                .stroke(Color.snapvetBorderSubtle, lineWidth: 1)
                        )

                    if !unit.isEmpty {
                        Text(unit)
                            .font(SnapVetFont.titleMedium)
                            .foregroundColor(.snapvetTextSecondary)
                            .padding(.bottom, 12)
                    }
                }
            }
            .frame(maxWidth: .infinity)
            .padding(14)
            .background(
                RoundedRectangle(cornerRadius: 14, style: .continuous)
                    .fill(Color.snapvetTileBg.opacity(0.72))
            )
            .overlay(
                RoundedRectangle(cornerRadius: 14, style: .continuous)
                    .stroke(borderColor, lineWidth: 1)
            )
        }
        .buttonStyle(.plain)
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
        name: "Systolic BP",
        value: "72",
        unit: "mmHg",
        status: .alert
    )
    .padding(16)
    .background(Color.snapvetPrimaryBg)
}
