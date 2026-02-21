import SwiftUI
import Shared

struct RecordTableScreen: View {
    @ObservedObject var viewModel: RecordTableViewModelWrapper
    let caseInfo: Case
    var onDeleteCase: () -> Void = {}

    @State private var showExportInfo = false
    @State private var showDeleteConfirm = false

    private let columns: [(String, CGFloat)] = [
        ("#", 42),
        ("Time", 96),
        ("HR", 58),
        ("RR", 58),
        ("SpO₂", 66),
        ("EtCO₂", 72),
        ("SBP", 62),
        ("DBP", 62),
        ("Temp", 62),
        ("Iso", 54),
        ("O₂", 54),
        ("ECG", 94),
        ("CRT", 84),
        ("MM", 98)
    ]

    var body: some View {
        ZStack {
            LinearGradient(
                colors: [Color.snapvetHeaderBg, Color.snapvetPrimaryBg],
                startPoint: .top,
                endPoint: .bottom
            )
            .ignoresSafeArea()

            ScrollView {
                VStack(spacing: 14) {
                    header
                    infoCard
                    vitalsTable
                }
                .padding(16)
                .padding(.bottom, 20)
            }
        }
        .alert("Export PDF", isPresented: $showExportInfo) {
            Button("OK", role: .cancel) {}
        } message: {
            Text("PDF export UI is wired. The document generator is still pending implementation.")
        }
        .alert("Delete this case?", isPresented: $showDeleteConfirm) {
            Button("Cancel", role: .cancel) {}
            Button("Delete", role: .destructive) {
                onDeleteCase()
            }
        } message: {
            Text("This permanently removes the case and all vital records.")
        }
    }

    private var header: some View {
        VStack(alignment: .leading, spacing: 10) {
            HStack {
                Spacer()

                HStack(spacing: 8) {
                    Button(action: { showExportInfo = true }) {
                        HStack(spacing: 6) {
                            Image(systemName: "doc")
                            Text("Export PDF")
                        }
                        .font(SnapVetFont.titleMedium.weight(.semibold))
                        .foregroundColor(.white)
                        .padding(.horizontal, 14)
                        .frame(height: 42)
                        .background(
                            RoundedRectangle(cornerRadius: 11, style: .continuous)
                                .fill(Color.snapvetAccentPrimary)
                        )
                    }
                    .buttonStyle(.plain)

                    Button(action: { showDeleteConfirm = true }) {
                        Image(systemName: "trash")
                            .font(SnapVetFont.titleMedium.weight(.bold))
                            .foregroundColor(.white)
                            .frame(width: 42, height: 42)
                            .background(
                                RoundedRectangle(cornerRadius: 11, style: .continuous)
                                    .fill(Color.snapvetAccentAlert)
                            )
                    }
                    .buttonStyle(.plain)
                }
            }

            Text(caseInfo.patientName)
                .font(SnapVetFont.headlineLarge)
                .foregroundColor(.snapvetTextPrimary)

            HStack(spacing: 10) {
                statusChip
                Text(displaySpecies(caseInfo.species))
                Text(displayWeight(caseInfo.weight))
            }
            .font(SnapVetFont.titleMedium)
            .foregroundColor(.snapvetTextSecondary)
        }
        .padding(16)
        .snapVetGlassCard(cornerRadius: 20)
    }

    private var infoCard: some View {
        HStack(spacing: 12) {
            infoColumn(title: "Procedure", value: caseInfo.procedure)
            infoColumn(title: "Date", value: formatDate(caseInfo.startTime))
            infoColumn(title: "Duration", value: durationText)
            infoColumn(title: "Records", value: "\(viewModel.state.records.count) entries")
        }
        .frame(maxWidth: .infinity)
        .padding(16)
        .snapVetGlassCard(cornerRadius: 20)
    }

    private func infoColumn(title: String, value: String) -> some View {
        VStack(alignment: .leading, spacing: 6) {
            Text(title)
                .font(SnapVetFont.bodySmall)
                .foregroundColor(.snapvetTextTertiary)
            Text(value)
                .font(SnapVetFont.titleLarge)
                .foregroundColor(.snapvetTextPrimary)
                .lineLimit(1)
        }
        .frame(maxWidth: .infinity, alignment: .leading)
    }

    private var vitalsTable: some View {
        VStack(alignment: .leading, spacing: 10) {
            Text("Vital Signs History")
                .font(SnapVetFont.headlineMedium)
                .foregroundColor(.snapvetTextPrimary)

            ScrollView(.horizontal, showsIndicators: false) {
                VStack(spacing: 0) {
                    tableHeader

                    ForEach(Array(viewModel.state.records.enumerated()), id: \.element.id) { index, record in
                        tableRow(record: record, index: index)
                    }
                }
                .padding(.bottom, 4)
            }
        }
        .padding(16)
        .snapVetGlassCard(cornerRadius: 20)
    }

    private var tableHeader: some View {
        HStack(spacing: 0) {
            ForEach(columns, id: \.0) { title, width in
                Text(title)
                    .font(SnapVetFont.bodySmall.weight(.semibold))
                    .foregroundColor(.snapvetTextSecondary)
                    .frame(width: width, height: 34, alignment: .leading)
            }
        }
        .padding(.bottom, 4)
        .overlay(alignment: .bottom) {
            Rectangle()
                .fill(Color.snapvetDivider)
                .frame(height: 1)
        }
    }

    private func tableRow(record: VitalRecord, index: Int) -> some View {
        HStack(spacing: 0) {
            tableCell("\(viewModel.state.records.count - index)", width: 42)
            tableCell(formatTime(record.timestamp), width: 96)
            tableCell(record.hr?.intValue.description ?? "-", width: 58)
            tableCell(record.rr?.intValue.description ?? "-", width: 58)
            tableCell(record.spo2?.intValue.description ?? "-", width: 66)
            tableCell(record.etco2?.intValue.description ?? "-", width: 72)
            tableCell(record.bpSys?.intValue.description ?? "-", width: 62)
            tableCell(record.bpDia?.intValue.description ?? "-", width: 62)
            tableCell(formatDouble(record.temp?.doubleValue), width: 62)
            tableCell(formatDouble(record.sevoIso?.doubleValue), width: 54)
            tableCell(formatDouble(record.o2Flow?.doubleValue), width: 54)
            tableCell(displayEnum(record.ecg?.name), width: 94)
            tableCell(displayEnum(record.crt?.name), width: 84)
            tableCell(displayEnum(record.mucousMembrane?.name), width: 98)
        }
        .frame(height: 42)
        .overlay(alignment: .bottom) {
            Rectangle()
                .fill(Color.snapvetDivider.opacity(0.7))
                .frame(height: 1)
        }
    }

    private func tableCell(_ value: String, width: CGFloat) -> some View {
        Text(value)
            .font(SnapVetFont.bodyMedium)
            .foregroundColor(.snapvetTextPrimary)
            .frame(width: width, alignment: .leading)
    }

    @ViewBuilder
    private var statusChip: some View {
        if caseInfo.status.name == "COMPLETED" {
            Text("completed")
                .font(SnapVetFont.labelMedium.weight(.semibold))
                .foregroundColor(.snapvetTextPrimary)
                .padding(.horizontal, 10)
                .padding(.vertical, 4)
                .background(
                    Capsule()
                        .fill(Color.snapvetTextTertiary.opacity(0.35))
                )
        }
    }

    private var durationText: String {
        let endMillis = caseInfo.endTime?.toEpochMilliseconds() ?? Int64(Date().timeIntervalSince1970 * 1000)
        let seconds = max(0, (endMillis - caseInfo.startTime.toEpochMilliseconds()) / 1000)
        let minutes = seconds / 60
        if minutes >= 60 {
            return "\(minutes / 60)h \(minutes % 60)m"
        }
        return "\(max(1, minutes))m"
    }

    private func displaySpecies(_ value: Species) -> String {
        value == .dog ? "Dog" : "Cat"
    }

    private func displayWeight(_ value: Double) -> String {
        if value.rounded() == value {
            return "\(Int(value)) lb"
        }
        return String(format: "%.1f lb", value)
    }

    private func displayEnum(_ raw: String?) -> String {
        guard let raw else { return "-" }
        return raw.replacingOccurrences(of: "_", with: " ").lowercased().capitalized
    }

    private func formatTime(_ instant: KotlinInstant) -> String {
        let date = Date(timeIntervalSince1970: TimeInterval(instant.toEpochMilliseconds()) / 1000)
        return DateFormatter.snapvetRecordTime.string(from: date)
    }

    private func formatDate(_ instant: KotlinInstant) -> String {
        let date = Date(timeIntervalSince1970: TimeInterval(instant.toEpochMilliseconds()) / 1000)
        return DateFormatter.snapvetRecordDate.string(from: date)
    }

    private func formatDouble(_ value: Double?) -> String {
        guard let value else { return "-" }
        if value.rounded() == value {
            return "\(Int(value))"
        }
        return String(format: "%.1f", value)
    }
}

private extension DateFormatter {
    static let snapvetRecordTime: DateFormatter = {
        let formatter = DateFormatter()
        formatter.timeStyle = .medium
        formatter.dateStyle = .none
        return formatter
    }()

    static let snapvetRecordDate: DateFormatter = {
        let formatter = DateFormatter()
        formatter.dateStyle = .medium
        formatter.timeStyle = .none
        return formatter
    }()
}

private extension View {
    @ViewBuilder
    func snapVetGlassCard(cornerRadius: CGFloat) -> some View {
#if swift(>=6.2)
        if #available(iOS 26.0, *) {
            self
                .glassEffect(.regular, in: RoundedRectangle(cornerRadius: cornerRadius, style: .continuous))
                .overlay(
                    RoundedRectangle(cornerRadius: cornerRadius, style: .continuous)
                        .stroke(Color.white.opacity(0.14), lineWidth: 1)
                )
        } else {
            self
                .background(
                    RoundedRectangle(cornerRadius: cornerRadius, style: .continuous)
                        .fill(Color.snapvetTileBg.opacity(0.78))
                )
                .overlay(
                    RoundedRectangle(cornerRadius: cornerRadius, style: .continuous)
                        .stroke(Color.snapvetBorderSubtle, lineWidth: 1)
                )
        }
#else
        self
            .background(
                RoundedRectangle(cornerRadius: cornerRadius, style: .continuous)
                    .fill(Color.snapvetTileBg.opacity(0.78))
            )
            .overlay(
                RoundedRectangle(cornerRadius: cornerRadius, style: .continuous)
                    .stroke(Color.snapvetBorderSubtle, lineWidth: 1)
            )
#endif
    }
}
