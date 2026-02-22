import SwiftUI
import Shared
import UIKit

struct RecordTableScreen: View {
    @ObservedObject var viewModel: RecordTableViewModelWrapper
    let caseInfo: Case
    var onDeleteCase: () -> Void = {}

    @State private var sharePayload: ShareSheetPayload?
    @State private var exportErrorMessage: String?
    @State private var showDeleteConfirm = false

    private struct IndexedRecord: Identifiable {
        let index: Int
        let record: VitalRecord
        var id: String { record.id }
    }

    private struct RowCell {
        let value: String
        let width: CGFloat
    }

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
        ("CRT", 112),
        ("Mucous Membrane", 148),
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
        .toolbar { toolbarContent }
        .sheet(item: $sharePayload) { payload in
            ShareSheet(activityItems: payload.activityItems)
        }
        .alert("Export Failed", isPresented: isExportErrorPresented) {
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

    private var isExportErrorPresented: Binding<Bool> {
        Binding(
            get: { exportErrorMessage != nil },
            set: { if !$0 { exportErrorMessage = nil } }
        )
    }

    @ToolbarContentBuilder
    private var toolbarContent: some ToolbarContent {
        ToolbarItem(placement: .topBarTrailing) {
            deleteButton
        }
        ToolbarItem(placement: .topBarTrailing) {
            exportButton
        }
    }

    private var deleteButton: some View {
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

    private var exportButton: some View {
        Button(action: exportPdf) {
            Image(systemName: "square.and.arrow.up")
                .font(SnapVetFont.titleMedium.weight(.bold))
                .foregroundColor(.white)
                .frame(width: 30, height: 30)
                .background(
                    Circle()
                        .fill(Color.snapvetAccentPrimary)
                )
        }
        .buttonStyle(.plain)
        .accessibilityLabel("Export PDF")
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
        .frame(maxWidth: .infinity, alignment: .leading)
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

                    ForEach(indexedRecords) { item in
                        tableRow(record: item.record, index: item.index)
                    }
                }
                .padding(.bottom, 4)
            }
        }
        .padding(16)
        .snapVetGlassCard(cornerRadius: 20)
    }

    private var indexedRecords: [IndexedRecord] {
        viewModel.state.records.enumerated().map { offset, record in
            IndexedRecord(index: offset, record: record)
        }
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
        let cells = rowCells(record: record, index: index)
        return HStack(spacing: 0) {
            ForEach(Array(cells.enumerated()), id: \.offset) { _, cell in
                tableCell(cell.value, width: cell.width)
            }
        }
        .frame(height: 42)
        .overlay(alignment: .bottom) {
            Rectangle()
                .fill(Color.snapvetDivider.opacity(0.7))
                .frame(height: 1)
        }
    }

    private func rowCells(record: VitalRecord, index: Int) -> [RowCell] {
        [
            RowCell(value: "\(viewModel.state.records.count - index)", width: 42),
            RowCell(value: formatTime(record.timestamp), width: 96),
            RowCell(value: record.hr?.intValue.description ?? "-", width: 58),
            RowCell(value: record.rr?.intValue.description ?? "-", width: 58),
            RowCell(value: record.spo2?.intValue.description ?? "-", width: 66),
            RowCell(value: record.etco2?.intValue.description ?? "-", width: 72),
            RowCell(value: record.bpSys?.intValue.description ?? "-", width: 62),
            RowCell(value: record.bpDia?.intValue.description ?? "-", width: 62),
            RowCell(value: formatDouble(record.temp?.doubleValue), width: 62),
            RowCell(value: formatDouble(record.sevoIso?.doubleValue), width: 54),
            RowCell(value: formatDouble(record.o2Flow?.doubleValue), width: 54),
            RowCell(value: displayEnum(record.ecg?.name), width: 94),
            RowCell(value: displayEnum(record.crt?.name), width: 112),
            RowCell(value: displayEnum(record.mucousMembrane?.name), width: 148),
            RowCell(value: record.notes ?? "-", width: 220)
        ]
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
            sharePayload = ShareSheetPayload(activityItems: [url])
        } catch {
            exportErrorMessage = error.localizedDescription
        }
    }

    private func buildPdfData() -> Data {
        let builder = RecordTablePdfBuilder(
            caseInfo: caseInfo,
            records: viewModel.state.records,
            durationText: durationText
        )
        return builder.build()
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

private struct ShareSheetPayload: Identifiable {
    let id = UUID()
    let activityItems: [Any]
}

private struct RecordTablePdfBuilder {
    let caseInfo: Case
    let records: [VitalRecord]
    let durationText: String

    private let pageRect = CGRect(x: 0, y: 0, width: 842, height: 595) // A4 landscape @ 72dpi
    private let margin: CGFloat = 20
    private let tableHeaderHeight: CGFloat = 22
    private let minimumRowHeight: CGFloat = 22
    private let cellPaddingX: CGFloat = 4
    private let cellPaddingY: CGFloat = 4

    private var contentWidth: CGFloat { pageRect.width - (margin * 2) }

    private var titleAttrs: [NSAttributedString.Key: Any] {
        [
            .font: UIFont.boldSystemFont(ofSize: 17),
            .foregroundColor: UIColor.black
        ]
    }

    private var headerAttrs: [NSAttributedString.Key: Any] {
        [
            .font: UIFont.systemFont(ofSize: 10, weight: .semibold),
            .foregroundColor: UIColor.darkGray
        ]
    }

    private var bodyAttrs: [NSAttributedString.Key: Any] {
        [
            .font: UIFont.systemFont(ofSize: 9, weight: .regular),
            .foregroundColor: UIColor.black
        ]
    }

    private var tableHeaderAttrs: [NSAttributedString.Key: Any] {
        [
            .font: UIFont.systemFont(ofSize: 9, weight: .semibold),
            .foregroundColor: UIColor.black
        ]
    }

    private var fixedColumns: [(title: String, width: CGFloat)] {
        [
            ("#", 26),
            ("Time", 72),
            ("HR", 32),
            ("RR", 32),
            ("SpO₂", 38),
            ("EtCO₂", 44),
            ("SBP", 36),
            ("DBP", 36),
            ("MAP", 36),
            ("Temp", 40),
            ("Iso", 34),
            ("O₂", 34),
            ("ECG", 64),
            ("CRT", 56),
            ("MM", 78)
        ]
    }

    private var notesWidth: CGFloat {
        let fixedTotal = fixedColumns.reduce(0) { $0 + $1.width }
        return max(120, contentWidth - fixedTotal)
    }

    private var columnTitles: [String] {
        fixedColumns.map { $0.title } + ["Notes"]
    }

    private var columnWidths: [CGFloat] {
        fixedColumns.map { $0.width } + [notesWidth]
    }

    func build() -> Data {
        let renderer = UIGraphicsPDFRenderer(bounds: pageRect)
        return renderer.pdfData { context in
            var y: CGFloat = 0

            func textHeight(_ text: String, width: CGFloat, attrs: [NSAttributedString.Key: Any]) -> CGFloat {
                let size = (text as NSString).boundingRect(
                    with: CGSize(width: width, height: .greatestFiniteMagnitude),
                    options: [.usesLineFragmentOrigin, .usesFontLeading],
                    attributes: attrs,
                    context: nil
                ).size
                return ceil(size.height)
            }

            func drawParagraph(_ text: String, attrs: [NSAttributedString.Key: Any], spacing: CGFloat = 4) {
                let rect = CGRect(x: margin, y: y, width: contentWidth, height: .greatestFiniteMagnitude)
                let size = textHeight(text, width: rect.width, attrs: attrs)
                (text as NSString).draw(
                    in: CGRect(x: rect.minX, y: rect.minY, width: rect.width, height: size),
                    withAttributes: attrs
                )
                y += size + spacing
            }

            func beginPage(showCaseHeader: Bool) {
                context.beginPage()
                y = margin
                drawParagraph("SnapVet Vital Records Export", attrs: titleAttrs, spacing: 8)
                if showCaseHeader {
                    drawParagraph("Patient: \(caseInfo.patientName)", attrs: headerAttrs)
                    drawParagraph("Species: \(displaySpecies(caseInfo.species))   Weight: \(displayWeight(caseInfo.weight))", attrs: headerAttrs)
                    drawParagraph("Procedure: \(caseInfo.procedure)", attrs: headerAttrs)
                    drawParagraph("Case Date: \(formatDate(caseInfo.startTime))   Duration: \(durationText)", attrs: headerAttrs)
                    drawParagraph("Generated: \(DateFormatter.snapvetExportDateTime.string(from: Date()))", attrs: headerAttrs, spacing: 10)
                } else {
                    drawParagraph("Continued", attrs: headerAttrs, spacing: 8)
                }
            }

            func drawTableHeaderRow() {
                var x = margin
                let titles = columnTitles
                let widths = columnWidths
                for index in titles.indices {
                    let width = widths[index]
                    let title = titles[index]
                    let cellRect = CGRect(x: x, y: y, width: width, height: tableHeaderHeight)
                    UIColor(white: 0.94, alpha: 1.0).setFill()
                    UIBezierPath(rect: cellRect).fill()
                    UIColor.darkGray.setStroke()
                    let border = UIBezierPath(rect: cellRect)
                    border.lineWidth = 0.6
                    border.stroke()

                    let paragraph = NSMutableParagraphStyle()
                    paragraph.alignment = .left
                    paragraph.lineBreakMode = .byTruncatingTail
                    var attrs = tableHeaderAttrs
                    attrs[.paragraphStyle] = paragraph
                    (title as NSString).draw(
                        in: cellRect.insetBy(dx: cellPaddingX, dy: cellPaddingY),
                        withAttributes: attrs
                    )
                    x += width
                }
                y += tableHeaderHeight
            }

            func rowValues(number: Int, record: VitalRecord) -> [String] {
                let notes = normalizedNotes(record.notes)
                return [
                    "\(number)",
                    formatTime(record.timestamp),
                    record.hr?.intValue.description ?? "-",
                    record.rr?.intValue.description ?? "-",
                    record.spo2?.intValue.description ?? "-",
                    record.etco2?.intValue.description ?? "-",
                    record.bpSys?.intValue.description ?? "-",
                    record.bpDia?.intValue.description ?? "-",
                    record.bpMap?.intValue.description ?? "-",
                    formatDouble(record.temp?.doubleValue),
                    formatDouble(record.sevoIso?.doubleValue),
                    formatDouble(record.o2Flow?.doubleValue),
                    displayEnum(record.ecg?.name),
                    displayEnum(record.crt?.name),
                    displayEnum(record.mucousMembrane?.name),
                    notes
                ]
            }

            func drawRecordRow(number: Int, record: VitalRecord) {
                let values = rowValues(number: number, record: record)
                let notes = values.last ?? "-"
                let notesTextWidth = notesWidth - (cellPaddingX * 2)
                let notesHeight = textHeight(notes, width: notesTextWidth, attrs: bodyAttrs)
                let rowHeight = max(minimumRowHeight, notesHeight + (cellPaddingY * 2))

                if y + rowHeight > pageRect.height - margin {
                    beginPage(showCaseHeader: false)
                    drawTableHeaderRow()
                }

                var x = margin
                let widths = columnWidths
                for index in values.indices {
                    let width = widths[index]
                    let value = values[index]
                    let cellRect = CGRect(x: x, y: y, width: width, height: rowHeight)
                    UIColor.darkGray.setStroke()
                    let border = UIBezierPath(rect: cellRect)
                    border.lineWidth = 0.4
                    border.stroke()

                    let paragraph = NSMutableParagraphStyle()
                    paragraph.alignment = .left
                    paragraph.lineBreakMode = index == values.count - 1 ? .byWordWrapping : .byTruncatingTail
                    var attrs = bodyAttrs
                    attrs[.paragraphStyle] = paragraph
                    (value as NSString).draw(
                        with: cellRect.insetBy(dx: cellPaddingX, dy: cellPaddingY),
                        options: [.usesLineFragmentOrigin, .usesFontLeading],
                        attributes: attrs,
                        context: nil
                    )
                    x += width
                }

                y += rowHeight
            }

            beginPage(showCaseHeader: true)

            if records.isEmpty {
                drawParagraph("No vital records saved.", attrs: bodyAttrs)
                return
            }

            drawTableHeaderRow()
            for index in records.indices {
                let number = records.count - index
                drawRecordRow(number: number, record: records[index])
            }
        }
    }

    private func normalizedNotes(_ notes: String?) -> String {
        guard let notes, !notes.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty else {
            return "-"
        }
        return notes
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

    private func formatDouble(_ value: Double?) -> String {
        guard let value else { return "-" }
        if value.rounded() == value {
            return "\(Int(value))"
        }
        return String(format: "%.1f", value)
    }

    private func formatTime(_ instant: KotlinInstant) -> String {
        let date = Date(timeIntervalSince1970: TimeInterval(instant.toEpochMilliseconds()) / 1000)
        return DateFormatter.snapvetRecordTime.string(from: date)
    }

    private func formatDate(_ instant: KotlinInstant) -> String {
        let date = Date(timeIntervalSince1970: TimeInterval(instant.toEpochMilliseconds()) / 1000)
        return DateFormatter.snapvetRecordDate.string(from: date)
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
