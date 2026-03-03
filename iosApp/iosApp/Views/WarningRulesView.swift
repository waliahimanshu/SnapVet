import SwiftUI

private struct WarningRuleRow: Identifiable {
    let id = UUID()
    let parameter: String
    let species: String
    let orange: String
    let red: String
}

struct WarningRulesView: View {
    @Environment(\.dismiss) private var dismiss

    private let rows: [WarningRuleRow] = [
        WarningRuleRow(parameter: "HR", species: "Dog", orange: "50...160", red: "outside 40...200"),
        WarningRuleRow(parameter: "HR", species: "Cat", orange: "80...180", red: "outside 60...220"),
        WarningRuleRow(parameter: "RR", species: "Dog", orange: "8...40", red: "outside 5...55"),
        WarningRuleRow(parameter: "RR", species: "Cat", orange: "12...45", red: "outside 8...60"),
        WarningRuleRow(parameter: "BP Systolic", species: "Dog", orange: "80...170", red: "outside 70...190"),
        WarningRuleRow(parameter: "BP Systolic", species: "Cat", orange: "90...170", red: "outside 80...190"),
        WarningRuleRow(parameter: "MAP", species: "Dog", orange: "60...120", red: "outside 55...130"),
        WarningRuleRow(parameter: "MAP", species: "Cat", orange: "65...120", red: "outside 60...130"),
        WarningRuleRow(parameter: "Temp (°C)", species: "Dog", orange: "36.5...39.0", red: "outside 35.5...40.0"),
        WarningRuleRow(parameter: "Temp (°C)", species: "Cat", orange: "37.0...39.5", red: "outside 36.0...40.5")
    ]

    private let columns: [GridItem] = [
        GridItem(.flexible(minimum: 90), alignment: .leading),
        GridItem(.flexible(minimum: 70), alignment: .leading),
        GridItem(.flexible(minimum: 110), alignment: .leading),
        GridItem(.flexible(minimum: 130), alignment: .leading)
    ]

    var body: some View {
        NavigationStack {
            ScrollView([.vertical, .horizontal]) {
                LazyVGrid(columns: columns, spacing: 10) {
                    headerCell("Parameter")
                    headerCell("Species")
                    headerCell("Orange")
                    headerCell("Red")

                    ForEach(rows) { row in
                        dataCell(row.parameter)
                        dataCell(row.species)
                        dataCell(row.orange, color: .snapvetAccentWarning)
                        dataCell(row.red, color: .snapvetAccentAlert)
                    }
                }
                .padding(16)
            }
            .background(Color.snapvetPrimaryBg.ignoresSafeArea())
            .navigationTitle("Warning Rules")
            .toolbar {
                ToolbarItem(placement: .topBarTrailing) {
                    Button("Done") { dismiss() }
                }
            }
        }
    }

    private func headerCell(_ text: String) -> some View {
        Text(text)
            .font(SnapVetFont.bodySmall.weight(.bold))
            .foregroundColor(.snapvetTextPrimary)
            .frame(maxWidth: .infinity, alignment: .leading)
            .padding(.vertical, 8)
            .padding(.horizontal, 10)
            .background(
                RoundedRectangle(cornerRadius: 8, style: .continuous)
                    .fill(Color.snapvetHeaderBg.opacity(0.75))
            )
    }

    private func dataCell(_ text: String, color: Color = .snapvetTextSecondary) -> some View {
        Text(text)
            .font(SnapVetFont.bodySmall)
            .foregroundColor(color)
            .frame(maxWidth: .infinity, alignment: .leading)
            .padding(.vertical, 8)
            .padding(.horizontal, 10)
            .background(
                RoundedRectangle(cornerRadius: 8, style: .continuous)
                    .fill(Color.snapvetTileBg.opacity(0.75))
            )
    }
}

#Preview {
    WarningRulesView()
}
