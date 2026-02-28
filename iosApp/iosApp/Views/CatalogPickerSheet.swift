import SwiftUI
import Shared

struct CatalogPickerSheet: View {
    let title: String
    @ObservedObject var viewModel: CatalogPickerViewModelWrapper
    var selectedValue: String?
    var onSelect: (CatalogItem) -> Void

    @Environment(\.dismiss) private var dismiss

    var body: some View {
        NavigationStack {
            VStack(spacing: 12) {
                searchField

                if let message = viewModel.state.errorMessage, !message.isEmpty {
                    Text(message)
                        .font(SnapVetFont.bodySmall)
                        .foregroundColor(.snapvetAccentAlert)
                        .frame(maxWidth: .infinity, alignment: .leading)
                }

                if viewModel.state.items.isEmpty {
                    Text("No matches")
                        .font(SnapVetFont.bodyMedium)
                        .foregroundColor(.snapvetTextSecondary)
                        .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .topLeading)
                        .padding(.top, 12)
                } else {
                    List(viewModel.state.items, id: \.code) { item in
                        Button {
                            SnapVetHaptics.selection()
                            onSelect(item)
                            dismiss()
                        } label: {
                            HStack(spacing: 10) {
                                Text(item.displayName)
                                    .foregroundColor(.snapvetTextPrimary)
                                Spacer()
                                if selectedValue == item.displayName {
                                    Image(systemName: "checkmark")
                                        .foregroundColor(.snapvetAccentPrimary)
                                }
                            }
                            .padding(.vertical, 6)
                        }
                        .listRowBackground(Color.snapvetTileBg)
                    }
                    .scrollContentBackground(.hidden)
                }
            }
            .padding(16)
            .background(Color.snapvetPrimaryBg.ignoresSafeArea())
            .navigationTitle(title)
            .toolbar {
                ToolbarItem(placement: .topBarTrailing) {
                    Button("Close") {
                        SnapVetHaptics.lightTap()
                        dismiss()
                    }
                    .foregroundColor(.snapvetAccentPrimary)
                }
            }
            .onDisappear {
                if !viewModel.state.query.isEmpty {
                    viewModel.updateQuery("")
                }
            }
        }
    }

    private var searchField: some View {
        HStack(spacing: 10) {
            Image(systemName: "magnifyingglass")
                .foregroundColor(.snapvetTextSecondary)

            TextField(
                "Search \(title.lowercased())",
                text: Binding(
                    get: { viewModel.state.query },
                    set: { viewModel.updateQuery($0) }
                )
            )
            .textInputAutocapitalization(.never)
            .foregroundColor(.snapvetTextPrimary)

            if !viewModel.state.query.isEmpty {
                Button {
                    SnapVetHaptics.selection()
                    viewModel.updateQuery("")
                } label: {
                    Image(systemName: "xmark.circle.fill")
                        .foregroundColor(.snapvetTextSecondary)
                }
            }
        }
        .padding(.horizontal, 12)
        .frame(height: 44)
        .background(
            RoundedRectangle(cornerRadius: 10, style: .continuous)
                .fill(Color.snapvetHeaderBg.opacity(0.55))
        )
        .overlay(
            RoundedRectangle(cornerRadius: 10, style: .continuous)
                .stroke(Color.snapvetBorderSubtle, lineWidth: 1)
        )
    }
}
