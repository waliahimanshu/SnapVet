import SwiftUI
import Shared
import UIKit

struct RecordTableScreen: View {
    @ObservedObject var viewModel: RecordTableViewModelWrapper
    let caseInfo: Case
    var onDeleteCase: () -> Void = {}

    @State private var showShareSheet = false
    @State private var shareItems: [Any] = []
    @State private var exportErrorMessage: String?
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
        ("MM", 98),
        ("Notes", 220)
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
        .toolbar {
            ToolbarItem(placement: .topBarTrailing) {
                Button(action: { showDeleteConfirm = true }) {
                    Image(systemName: "trash")
                        .font(SnapVetFont.titleMedium.weight(.bold))
                        .foregroundColor(.white)
                        .frame(width: 30, height: 30)
                        .background(
                            Circle()
                                .fill(Color.snapvetAccentAlert)
                        )
                }
                .buttonStyle(.plain)
                .padding(.leading, 8)
            }

            ToolbarItem(placement: .topBarTrailing) {
                Button(action: exportPdf) {
                    HStack(spacing: 6) {
                        Image(systemName: "doc")
                        Text("Export")
                    }
                    .font(SnapVetFont.titleMedium.weight(.semibold))
                    .foregroundColor(.white)
                    .padding(.horizontal, 10)
                    .padding(.vertical, 6)
                    .background(
                        Capsule()
                            .fill(Color.snapvetAccentPrimary)
                    )
                }
                .buttonStyle(.plain)
            }
        }
        .sheet(isPresented: $showShareSheet) {
            ShareSheet(activityItems: shareItems)
        }
        .alert("Export Failed", isPresented: Binding(
            get: { exportErrorMessage != nil },
            set: { if !$0 { exportErrorMessage = nil } }
        )) {
            Button("OK", role: .cancel) {}
        } message: {
            Text(exportErrorMessage ?? "Could not generate PDF.")
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
            tableCell(record.notes ?? "-", width: 220)
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

    private func exportPdf() {
        do {
            let data = buildPdfData()
            let fileName = "SnapVet-\(sanitizedFileName(caseInfo.patientName))-\(DateFormatter.snapvetExportStamp.string(from: Date())).pdf"
            let url = FileManager.default.temporaryDirectory.appendingPathComponent(fileName)
            try data.write(to: url, options: .atomic)
            shareItems = [url]
            showShareSheet = true
        } catch {
            exportErrorMessage = error.localizedDescription
        }
    }

    private func buildPdfData() -> Data {
        let pageRect = CGRect(x: 0, y: 0, width: 595, height: 842) // A4 @ 72dpi
        let renderer = UIGraphicsPDFRenderer(bounds: pageRect)
        let margin: CGFloat = 32
        let contentWidth = pageRect.width - (margin * 2)
        let titleAttrs: [NSAttributedString.Key: Any] = [
            .font: UIFont.boldSystemFont(ofSize: 20),
            .foregroundColor: UIColor.black
        ]
        let headerAttrs: [NSAttributedString.Key: Any] = [
            .font: UIFont.systemFont(ofSize: 11, weight: .semibold),
            .foregroundColor: UIColor.darkGray
        ]
        let bodyAttrs: [NSAttributedString.Key: Any] = [
            .font: UIFont.systemFont(ofSize: 11, weight: .regular),
            .foregroundColor: UIColor.black
        ]

        return renderer.pdfData { context in
            var y: CGFloat = 0

            func drawLine(_ text: String, attrs: [NSAttributedString.Key: Any], spacing: CGFloat = 4) {
                let rect = CGRect(x: margin, y: y, width: contentWidth, height: .greatestFiniteMagnitude)
                let size = (text as NSString).boundingRect(
                    with: CGSize(width: rect.width, height: .greatestFiniteMagnitude),
                    options: [.usesLineFragmentOrigin, .usesFontLeading],
                    attributes: attrs,
                    context: nil
                ).size
                (text as NSString).draw(
                    in: CGRect(x: rect.minX, y: rect.minY, width: rect.width, height: ceil(size.height)),
                    withAttributes: attrs
                )
                y += ceil(size.height) + spacing
            }

            func beginPage(showCaseHeader: Bool) {
                context.beginPage()
                y = margin
                drawLine("SnapVet Vital Records Export", attrs: titleAttrs, spacing: 10)
                if showCaseHeader {
                    drawLine("Patient: \(caseInfo.patientName)", attrs: headerAttrs)
                    drawLine("Species: \(displaySpecies(caseInfo.species))   Weight: \(displayWeight(caseInfo.weight))", attrs: headerAttrs)
                    drawLine("Procedure: \(caseInfo.procedure)", attrs: headerAttrs)
                    drawLine("Case Date: \(formatDate(caseInfo.startTime))   Duration: \(durationText)", attrs: headerAttrs)
                    drawLine("Generated: \(DateFormatter.snapvetExportDateTime.string(from: Date()))", attrs: headerAttrs, spacing: 10)
                } else {
                    drawLine("Continued", attrs: headerAttrs, spacing: 10)
                }
            }

            beginPage(showCaseHeader: true)

            if viewModel.state.records.isEmpty {
                drawLine("No vital records saved.", attrs: bodyAttrs)
                return
            }

            for (index, record) in viewModel.state.records.enumerated() {
                let recordNumber = viewModel.state.records.count - index
                let notes = (record.notes?.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty == false) ? (record.notes ?? "-") : "-"
                let lines = [
                    "#\(recordNumber)  \(formatTime(record.timestamp))",
                    "HR \(record.hr?.intValue.description ?? "-")   RR \(record.rr?.intValue.description ?? "-")   SpO₂ \(record.spo2?.intValue.description ?? "-")   EtCO₂ \(record.etco2?.intValue.description ?? "-")",
                    "BP \(record.bpSys?.intValue.description ?? "-")/\(record.bpDia?.intValue.description ?? "-")/\(record.bpMap?.intValue.description ?? "-")   Temp \(formatDouble(record.temp?.doubleValue))   Iso \(formatDouble(record.sevoIso?.doubleValue))   O₂ \(formatDouble(record.o2Flow?.doubleValue))",
                    "ECG \(displayEnum(record.ecg?.name))   CRT \(displayEnum(record.crt?.name))   MM \(displayEnum(record.mucousMembrane?.name))",
                    "Notes: \(notes)"
                ]

                var estimatedHeight: CGFloat = 0
                for line in lines {
                    let size = (line as NSString).boundingRect(
                        with: CGSize(width: contentWidth, height: .greatestFiniteMagnitude),
                        options: [.usesLineFragmentOrigin, .usesFontLeading],
                        attributes: bodyAttrs,
                        context: nil
                    ).size
                    estimatedHeight += ceil(size.height) + 4
                }
                estimatedHeight += 8

                if y + estimatedHeight > pageRect.height - margin {
                    beginPage(showCaseHeader: false)
                }

                for line in lines {
                    drawLine(line, attrs: bodyAttrs)
                }

                let separatorY = y + 2
                let separator = UIBezierPath()
                separator.move(to: CGPoint(x: margin, y: separatorY))
                separator.addLine(to: CGPoint(x: pageRect.width - margin, y: separatorY))
                UIColor.lightGray.setStroke()
                separator.lineWidth = 0.5
                separator.stroke()
                y += 8
            }
        }
    }

    private func sanitizedFileName(_ value: String) -> String {
        let allowed = CharacterSet.alphanumerics.union(CharacterSet(charactersIn: "-_"))
        let compact = value
            .trimmingCharacters(in: .whitespacesAndNewlines)
            .replacingOccurrences(of: " ", with: "_")
        let cleaned = compact.unicodeScalars.map { allowed.contains($0) ? Character($0) : "_" }
        let result = String(cleaned)
        return result.isEmpty ? "Case" : result
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

    static let snapvetExportDateTime: DateFormatter = {
        let formatter = DateFormatter()
        formatter.dateStyle = .medium
        formatter.timeStyle = .medium
        return formatter
    }()

    static let snapvetExportStamp: DateFormatter = {
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyyMMdd-HHmmss"
        return formatter
    }()
}

private struct ShareSheet: UIViewControllerRepresentable {
    let activityItems: [Any]

    func makeUIViewController(context: Context) -> UIActivityViewController {
        UIActivityViewController(activityItems: activityItems, applicationActivities: nil)
    }

    func updateUIViewController(_ uiViewController: UIActivityViewController, context: Context) {}
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
