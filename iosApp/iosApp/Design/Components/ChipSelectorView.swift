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
