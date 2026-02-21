import SwiftUI
import Shared

struct RecordTableScreen: View {
    @ObservedObject var viewModel: RecordTableViewModelWrapper

    var body: some View {
        VStack {
            HStack {
                Text("Timestamp")
                Spacer()
                Text("HR")
                Spacer()
                Text("SpO₂")
                Spacer()
                Text("Temp")
            }
            .font(SnapVetFont.bodySmall)
            .foregroundColor(.snapvetTextSecondary)
            .padding(.horizontal, 16)

            List(viewModel.state.records, id: \ .id) { record in
                HStack {
                    Text("\(record.timestamp)")
                        .font(.system(size: 12, design: .monospaced))
                    Spacer()
                    Text(record.hr?.intValue.description ?? "—")
                    Spacer()
                    Text(record.spo2?.intValue.description ?? "—")
                    Spacer()
                    Text(record.temp?.doubleValue.description ?? "—")
                }
                .foregroundColor(.snapvetTextPrimary)
            }
        }
        .navigationTitle("Records")
    }
}
