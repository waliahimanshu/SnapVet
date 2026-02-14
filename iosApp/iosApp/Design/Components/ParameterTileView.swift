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

    var body: some View {
        Button(action: action) {
            VStack(spacing: 8) {
                // Parameter name
                Text(name)
                    .font(SnapVetFont.bodyMedium)
                    .fontWeight(.medium)
                    .foregroundColor(.snapvetTextSecondary)

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
