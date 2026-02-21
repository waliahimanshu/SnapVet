import SwiftUI
import Shared

struct CaseListScreen: View {
    @ObservedObject var viewModel: CaseListViewModelWrapper

    var body: some View {
        NavigationView {
            List(viewModel.state.cases, id: \ .id) { item in
                VStack(alignment: .leading, spacing: 4) {
                    Text(item.patientName)
                        .font(SnapVetFont.titleMedium)
                        .foregroundColor(.snapvetTextPrimary)
                    Text("\(item.species) • \(item.weight)kg")
                        .font(SnapVetFont.bodySmall)
                        .foregroundColor(.snapvetTextSecondary)
                }
            }
            .navigationTitle("Cases")
        }
    }
}
