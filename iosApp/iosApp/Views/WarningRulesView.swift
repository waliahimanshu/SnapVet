import SwiftUI

private struct WarningRuleRow: Identifiable {
    let id = UUID()
    let parameter: String
    let canineWarning: String
    let canineAlert: String
    let felineWarning: String
    let felineAlert: String
}

struct WarningRulesView: View {
    @Environment(\.dismiss) private var dismiss

    private let rows: [WarningRuleRow] = [
        WarningRuleRow(
            parameter: "HR",
            canineWarning: "50...160",
            canineAlert: "40...200",
            felineWarning: "80...180",
            felineAlert: "60...220"
        ),
        WarningRuleRow(
            parameter: "RR",
            canineWarning: "8...40",
            canineAlert: "5...55",
            felineWarning: "12...45",
            felineAlert: "8...60"
        ),
        WarningRuleRow(
            parameter: "BP Systolic",
            canineWarning: "80...170",
            canineAlert: "70...190",
            felineWarning: "90...170",
            felineAlert: "80...190"
        ),
        WarningRuleRow(
            parameter: "MAP",
            canineWarning: "60...120",
            canineAlert: "55...130",
            felineWarning: "65...120",
            felineAlert: "60...130"
        ),
        WarningRuleRow(
            parameter: "Temp (°C)",
            canineWarning: "36.5...39.0",
            canineAlert: "35.5...40.0",
            felineWarning: "37.0...39.5",
            felineAlert: "36.0...40.5"
        )
    ]

    private let columns: [GridItem] = [
        GridItem(.flexible(minimum: 120), alignment: .leading),
        GridItem(.flexible(minimum: 180), alignment: .leading),
        GridItem(.flexible(minimum: 180), alignment: .leading)
    ]

    var body: some View {
        NavigationStack {
            ScrollView([.vertical, .horizontal]) {
                LazyVGrid(columns: columns, spacing: 10) {
                    headerCell("Parameter")
                    speciesHeader("Canine", symbol: "dog.fill")
                    speciesHeader("Feline", symbol: "cat.fill")

                    ForEach(rows) { row in
                        dataCell(row.parameter)
                        rangeCell(warning: row.canineWarning, alert: row.canineAlert)
                        rangeCell(warning: row.felineWarning, alert: row.felineAlert)
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

    private func rangeCell(warning: String, alert: String) -> some View {
        VStack(alignment: .leading, spacing: 4) {
            HStack(spacing: 6) {
                Text("Warning:")
                    .font(SnapVetFont.bodySmall.weight(.semibold))
                    .foregroundColor(.snapvetAccentWarning)
                Text(warning)
                    .font(SnapVetFont.bodySmall)
                    .foregroundColor(.snapvetTextSecondary)
            }
            HStack(spacing: 6) {
                Text("Alert:")
                    .font(SnapVetFont.bodySmall.weight(.semibold))
                    .foregroundColor(.snapvetAccentAlert)
                Text(alert)
                    .font(SnapVetFont.bodySmall)
                    .foregroundColor(.snapvetTextSecondary)
            }
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .padding(.vertical, 8)
        .padding(.horizontal, 10)
        .background(
            RoundedRectangle(cornerRadius: 8, style: .continuous)
                .fill(Color.snapvetTileBg.opacity(0.75))
        )
    }

    private func speciesHeader(_ title: String, symbol: String) -> some View {
        HStack(spacing: 6) {
            Image(systemName: symbol)
                .foregroundColor(.snapvetAccentPrimary)
            Text(title)
        }
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
}

#Preview {
    WarningRulesView()
}
