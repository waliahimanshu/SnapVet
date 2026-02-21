// SnapVet Design System - Patient Info Bar Component
import SwiftUI

struct PatientInfoBarView: View {
    let patientName: String
    let weight: String
    let species: String
    let elapsedTime: String
    let batteryLevel: Int // 0-100
    @Environment(\.horizontalSizeClass) private var horizontalSizeClass

    var body: some View {
        VStack(spacing: 0) {
            Group {
                if horizontalSizeClass == .compact {
                    VStack(alignment: .leading, spacing: 8) {
                        patientInfo
                        HStack {
                            timerAndBattery
                            Spacer()
                        }
                    }
                } else {
                    HStack(spacing: 16) {
                        patientInfo
                        Spacer()
                        timerAndBattery
                    }
                }
            }
            .padding(12)
            .background(Color.snapvetHeaderBg)

            Divider()
                .background(Color.snapvetDivider)
        }
    }

    private var patientInfo: some View {
        VStack(alignment: .leading, spacing: 4) {
            Text(patientName)
                .font(SnapVetFont.titleLarge)
                .fontWeight(.semibold)
                .foregroundColor(.snapvetTextPrimary)

            HStack(spacing: 12) {
                Text("\(weight) kg")
                    .font(SnapVetFont.bodySmall)
                    .foregroundColor(.snapvetTextSecondary)

                Circle()
                    .fill(Color.snapvetBorderSubtle)
                    .frame(width: 3, height: 3)

                Text(species)
                    .font(SnapVetFont.bodySmall)
                    .foregroundColor(.snapvetTextSecondary)
            }
        }
    }

    private var timerAndBattery: some View {
        VStack(alignment: .trailing, spacing: 4) {
            HStack(spacing: 6) {
                Image(systemName: "timer")
                    .font(.system(size: 14, weight: .semibold))

                Text(elapsedTime)
                    .font(SnapVetFont.titleMedium)
                    .fontWeight(.semibold)
            }
            .foregroundColor(.snapvetAccentPrimary)

            HStack(spacing: 4) {
                BatteryIndicatorView(level: batteryLevel)

                Text("\(batteryLevel)%")
                    .font(SnapVetFont.bodySmall)
                    .foregroundColor(.snapvetTextSecondary)
            }
        }
    }
}

struct BatteryIndicatorView: View {
    let level: Int

    var batteryColor: Color {
        switch level {
        case 0...20:
            return Color.snapvetAccentAlert
        case 21...50:
            return Color.snapvetAccentWarning
        default:
            return Color.snapvetAccentPrimary
        }
    }

    var body: some View {
        HStack(spacing: 1) {
            RoundedRectangle(cornerRadius: 2)
                .fill(batteryColor)
                .frame(width: 2, height: 8)

            RoundedRectangle(cornerRadius: 1)
                .fill(batteryColor.opacity(0.5))
                .frame(width: 2, height: 8)

            RoundedRectangle(cornerRadius: 1)
                .fill(batteryColor.opacity(0.3))
                .frame(width: 2, height: 8)
        }
        .frame(width: 10, height: 8)
    }
}

// MARK: - Previews

#Preview("PatientInfoBar - Dog") {
    PatientInfoBarView(
        patientName: "Max",
        weight: "28.5",
        species: "Dog",
        elapsedTime: "12:34",
        batteryLevel: 85
    )
}

#Preview("PatientInfoBar - Cat") {
    PatientInfoBarView(
        patientName: "Whiskers",
        weight: "4.2",
        species: "Cat",
        elapsedTime: "05:20",
        batteryLevel: 35
    )
}
