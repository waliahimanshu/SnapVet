import SwiftUI
import Shared

struct CaseListScreen: View {
    @ObservedObject var viewModel: CaseListViewModelWrapper
    var onNewCase: () -> Void = {}

    var body: some View {
        ZStack(alignment: .bottomTrailing) {
            Group {
                if viewModel.state.cases.isEmpty {
                    emptyState
                } else {
                    List(viewModel.state.cases, id: \.id) { item in
                        VStack(alignment: .leading, spacing: 4) {
                            Text(item.patientName)
                                .font(SnapVetFont.titleMedium)
                                .foregroundColor(.snapvetTextPrimary)
                            Text("\(item.species) • \(item.weight)kg")
                                .font(SnapVetFont.bodySmall)
                                .foregroundColor(.snapvetTextSecondary)
                        }
                        .listRowBackground(Color.snapvetTileBg)
                    }
                    .scrollContentBackground(.hidden)
                }
            }

            Button(action: onNewCase) {
                HStack(spacing: 8) {
                    Image(systemName: "plus")
                    Text("New Case")
                        .fontWeight(.semibold)
                }
                .padding(.horizontal, 18)
                .frame(height: 52)
                .background(Color.snapvetAccentPrimary)
                .foregroundColor(.white)
                .clipShape(Capsule())
                .shadow(color: .black.opacity(0.25), radius: 8, x: 0, y: 4)
            }
            .padding(20)
        }
        .background(Color.snapvetPrimaryBg.ignoresSafeArea())
    }

    private var emptyState: some View {
        VStack(spacing: 12) {
            Image(systemName: "list.bullet.clipboard")
                .font(.system(size: 36))
                .foregroundColor(.snapvetTextSecondary)
            Text("No cases yet")
                .font(SnapVetFont.titleMedium)
                .foregroundColor(.snapvetTextPrimary)
            Text("Create your first anesthesia case to begin monitoring.")
                .font(SnapVetFont.bodySmall)
                .foregroundColor(.snapvetTextSecondary)
                .multilineTextAlignment(.center)
                .padding(.horizontal, 24)
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
    }
}
