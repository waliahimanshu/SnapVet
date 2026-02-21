// SnapVet Design System - Numeric Keypad Component
import SwiftUI

struct NumericKeypadView: View {
    @State var currentValue: String = ""
    var unitLabel: String? = nil
    var onNumberTap: (String) -> Void = { _ in }
    var onDecimalTap: () -> Void = {}
    var onBackspaceTap: () -> Void = {}
    var onConfirm: () -> Void = {}
    var onClear: () -> Void = {}
    var onCancel: () -> Void = {}

    let columns = [
        GridItem(.flexible(), spacing: 8),
        GridItem(.flexible(), spacing: 8),
        GridItem(.flexible(), spacing: 8)
    ]

    var body: some View {
        VStack(spacing: 12) {
            // Current value display
            VStack(alignment: .leading, spacing: 4) {
                Text(currentValue.isEmpty ? "0" : currentValue)
                    .font(SnapVetFont.displayLarge)
                    .fontWeight(.bold)
                    .foregroundColor(.snapvetAccentPrimary)
                    .tracking(-1)
                if let unitLabel, !unitLabel.isEmpty {
                    Text(unitLabel)
                        .font(SnapVetFont.bodySmall)
                        .foregroundColor(.snapvetTextSecondary)
                }
            }
            .frame(maxWidth: .infinity, alignment: .center)
            .frame(minHeight: 80)
            .background(Color.snapvetTileBg)
            .cornerRadius(8)
            .padding(.bottom, 8)

            // Number grid (1-9)
            LazyVGrid(columns: columns, spacing: 8) {
                ForEach(1...9, id: \.self) { number in
                    NumericKeypadButton(
                        label: "\(number)",
                        isAccent: false,
                        action: { onNumberTap("\(number)") }
                    )
                }
            }

            // Bottom row (0, ., backspace)
            HStack(spacing: 8) {
                NumericKeypadButton(
                    label: "0",
                    isAccent: false,
                    action: { onNumberTap("0") }
                )
                NumericKeypadButton(
                    label: ".",
                    isAccent: false,
                    action: onDecimalTap
                )
                NumericKeypadButton(
                    label: "⌫",
                    isAccent: false,
                    action: onBackspaceTap
                )
            }

            // Action buttons
            HStack(spacing: 8) {
                Button(action: onClear) {
                    Text("Clear")
                        .fontWeight(.semibold)
                        .foregroundColor(.snapvetAccentPrimary)
                        .frame(maxWidth: .infinity)
                        .frame(height: 52)
                        .background(Color.snapvetAccentPrimary.opacity(0.2))
                        .cornerRadius(8)
                }

                Button(action: onCancel) {
                    Text("Cancel")
                        .fontWeight(.semibold)
                        .foregroundColor(.snapvetTextSecondary)
                        .frame(maxWidth: .infinity)
                        .frame(height: 52)
                        .background(Color.snapvetTileBg)
                        .cornerRadius(8)
                }

                Button(action: onConfirm) {
                    Text("Save")
                        .fontWeight(.bold)
                        .foregroundColor(.white)
                        .frame(maxWidth: .infinity)
                        .frame(height: 52)
                        .background(Color.snapvetAccentPrimary)
                        .cornerRadius(8)
                }
            }
        }
        .padding(16)
        .background(Color.snapvetHeaderBg)
        .cornerRadius(12)
    }
}

struct NumericKeypadButton: View {
    let label: String
    let isAccent: Bool
    let action: () -> Void

    var body: some View {
        Button(action: action) {
            Text(label)
                .font(SnapVetFont.headlineMedium)
                .fontWeight(.bold)
                .frame(maxWidth: .infinity)
                .frame(minHeight: 60)
                .background(
                    isAccent ? Color.snapvetAccentPrimary : Color.snapvetTileBg
                )
                .foregroundColor(.white)
                .cornerRadius(8)
        }
        .buttonStyle(PlainButtonStyle())
    }
}

// MARK: - Previews

#Preview("NumericKeypad") {
    NumericKeypadView(
        currentValue: "125",
        onConfirm: { print("Saved") }
    )
    .padding(16)
    .background(Color.snapvetPrimaryBg)
}

#Preview("NumericKeypad - Empty") {
    NumericKeypadView(
        currentValue: "",
        onConfirm: { print("Saved") }
    )
    .padding(16)
    .background(Color.snapvetPrimaryBg)
}
