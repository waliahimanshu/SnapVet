// SnapVet Design System - Chip Selector Component
import SwiftUI

struct ChipOption {
    let id: String
    let label: String
    let color: Color
}

struct ChipSelectorView: View {
    let options: [ChipOption]
    @State var selectedId: String?
    var onSelectionChange: (String) -> Void = { _ in }

    var body: some View {
        VStack(spacing: 8) {
            ForEach(options, id: \.id) { option in
                ChipButton(
                    option: option,
                    isSelected: option.id == selectedId,
                    action: {
                        selectedId = option.id
                        onSelectionChange(option.id)
                    }
                )
            }
        }
    }
}

struct ChipButton: View {
    let option: ChipOption
    let isSelected: Bool
    let action: () -> Void

    var body: some View {
        Button(action: action) {
            HStack {
                Text(option.label)
                    .font(SnapVetFont.bodyLarge)
                    .fontWeight(isSelected ? .bold : .regular)
                    .foregroundColor(
                        isSelected ? Color.snapvetAccentPrimary : Color.snapvetTextPrimary
                    )

                Spacer()

                if isSelected {
                    Image(systemName: "checkmark.circle.fill")
                        .foregroundColor(.snapvetAccentPrimary)
                }
            }
            .frame(maxWidth: .infinity)
            .frame(height: 48)
            .padding(.horizontal, 12)
            .background(isSelected ? option.color : Color.snapvetTileBg)
            .cornerRadius(8)
            .overlay(
                RoundedRectangle(cornerRadius: 8)
                    .stroke(
                        isSelected ? Color.snapvetAccentPrimary : Color.snapvetBorderSubtle,
                        lineWidth: isSelected ? 2 : 1
                    )
            )
        }
        .buttonStyle(PlainButtonStyle())
    }
}

// MARK: - Previews

#Preview("ChipSelector - None Selected") {
    ChipSelectorView(
        options: [
            ChipOption(id: "pink", label: "Pink (Normal)", color: Color(red: 1.0, green: 0.75, blue: 0.80)),
            ChipOption(id: "pale", label: "Pale", color: Color(red: 1.0, green: 0.94, blue: 0.96)),
            ChipOption(id: "red", label: "Red/Injected", color: Color(red: 1.0, green: 0.42, blue: 0.42))
        ],
        selectedId: nil
    )
    .padding(16)
    .background(Color.snapvetPrimaryBg)
}

#Preview("ChipSelector - Selected") {
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
