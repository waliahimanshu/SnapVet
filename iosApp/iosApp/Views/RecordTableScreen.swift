import SwiftUI
import Shared
import UIKit
import CoreText

struct RecordTableScreen: View {
    @ObservedObject var viewModel: RecordTableViewModelWrapper
    let caseInfo: Case
    let sharedTransitionNamespace: Namespace.ID
    var onBack: () -> Void = {}
    var onDeleteCase: () -> Void = {}

    @State private var sharePayload: ShareSheetPayload?
    @State private var exportErrorMessage: String?
    @State private var showDeleteConfirm = false
    @AppStorage("snapvet_weight_unit") private var weightUnitRawValue = WeightUnit.lb.rawValue
    @AppStorage("snapvet_temperature_unit") private var temperatureUnitRawValue = TemperatureUnit.celsius.rawValue

    private struct IndexedRecord: Identifiable {
        let index: Int
        let record: VitalRecord
        var id: String { record.id }
    }

    private struct RowCell {
        let value: String
        let width: CGFloat
    }

    private var columns: [(String, CGFloat)] {
        [
            ("#", 42),
            ("Time", 96),
            ("HR", 58),
            ("RR", 58),
            ("SpO₂", 66),
            ("EtCO₂", 72),
            ("BP", 94),
            ("Temp \(temperatureUnit.title)", 80),
            ("Iso", 54),
            ("O₂", 54),
            ("Fluids", 70),
            ("ECG", 94),
            ("CRT", 112),
            ("Pulse", 90),
            ("Mucous Membrane", 148),
            ("Notes", 220)
        ]
    }

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
                SnapVetHaptics.warning()
                onDeleteCase()
            }
        } message: {
            Text("This permanently removes the case and all vital records.")
        }
        .navigationBarBackButtonHidden(true)
    }

    private var isExportErrorPresented: Binding<Bool> {
        Binding(
            get: { exportErrorMessage != nil },
            set: { if !$0 { exportErrorMessage = nil } }
        )
    }

    @ToolbarContentBuilder
    private var toolbarContent: some ToolbarContent {
        ToolbarItem(placement: .topBarLeading) {
            backButton
        }
        ToolbarItem(placement: .topBarTrailing) {
            deleteButton
        }
        ToolbarItem(placement: .topBarTrailing) {
            exportButton
        }
    }

    private var backButton: some View {
        Button(action: {
            SnapVetHaptics.lightTap()
            onBack()
        }) {
            Image(systemName: "chevron.backward")
                .font(.system(size: 17, weight: .semibold))
                .foregroundStyle(.primary)
                .frame(width: 44, height: 44)
                .contentShape(Rectangle())
        }
        .buttonStyle(.plain)
        .accessibilityLabel("Back")
    }

    private var deleteButton: some View {
        Button(action: {
            SnapVetHaptics.lightTap()
            showDeleteConfirm = true
        }) {
            Image(systemName: "trash")
                .font(SnapVetFont.titleMedium.weight(.bold))
                .foregroundStyle(.primary)
                .frame(width: 44, height: 44)
                .contentShape(Rectangle())
        }
        .buttonStyle(.plain)
        .accessibilityLabel("Delete case")
    }

    private var exportButton: some View {
        Button(action: {
            SnapVetHaptics.lightTap()
            exportPdf()
        }) {
            Image(systemName: "square.and.arrow.up")
                .font(SnapVetFont.titleMedium.weight(.bold))
                .foregroundStyle(.primary)
                .frame(width: 44, height: 44)
                .contentShape(Rectangle())
        }
        .buttonStyle(.plain)
        .accessibilityLabel("Share PDF")
    }

    private var header: some View {
        VStack(alignment: .leading, spacing: 10) {
            HStack(spacing: 10) {
                speciesSymbol(for: caseInfo.species)
                    .navigationTransition(.zoom(sourceID: caseHistoryTransitionId(field: .speciesIcon), in: sharedTransitionNamespace))

                Text(caseInfo.patientName)
                    .font(SnapVetFont.headlineLarge)
                    .foregroundColor(.snapvetTextPrimary)
                    .navigationTransition(.zoom(sourceID: caseHistoryTransitionId(field: .patientName), in: sharedTransitionNamespace))

                Spacer(minLength: 0)
            }

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
        return HStack(alignment: .top, spacing: 0) {
            ForEach(Array(cells.enumerated()), id: \.offset) { _, cell in
                tableCell(cell.value, width: cell.width)
            }
        }
        .frame(minHeight: 42, alignment: .topLeading)
        .overlay(alignment: .bottom) {
            Rectangle()
                .fill(Color.snapvetDivider.opacity(0.7))
                .frame(height: 1)
        }
    }

    private func rowCells(record: VitalRecord, index: Int) -> [RowCell] {
        [
            RowCell(value: "\(index + 1)", width: 42),
            RowCell(value: formatTime(record.timestamp), width: 96),
            RowCell(value: record.hr?.intValue.description ?? "-", width: 58),
            RowCell(value: record.rr?.intValue.description ?? "-", width: 58),
            RowCell(value: record.spo2?.intValue.description ?? "-", width: 66),
            RowCell(value: record.etco2?.intValue.description ?? "-", width: 72),
            RowCell(value: formatBloodPressure(sys: record.bpSys?.intValue, dia: record.bpDia?.intValue, map: record.bpMap?.intValue), width: 94),
            RowCell(value: formatTemperature(record.temp?.doubleValue), width: 80),
            RowCell(value: formatDouble(record.sevoIso?.doubleValue), width: 54),
            RowCell(value: formatDouble(record.o2Flow?.doubleValue), width: 54),
            RowCell(value: formatDouble(record.fluids?.doubleValue), width: 70),
            RowCell(value: formatEcg(record), width: 94),
            RowCell(value: displayEnum(record.crt?.name), width: 112),
            RowCell(value: displayEnum(record.pulseQuality?.name), width: 90),
            RowCell(value: displayEnum(record.mucousMembrane?.name), width: 148),
            RowCell(value: record.notes ?? "-", width: 220)
        ]
    }

    private func tableCell(_ value: String, width: CGFloat) -> some View {
        Text(value)
            .font(SnapVetFont.bodyMedium)
            .foregroundColor(.snapvetTextPrimary)
            .lineLimit(nil)
            .multilineTextAlignment(.leading)
            .fixedSize(horizontal: false, vertical: true)
            .frame(width: width, alignment: .topLeading)
            .padding(.vertical, 8)
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


    private func speciesSymbol(for species: Species) -> some View {
        Image(systemName: species == .dog ? "dog.fill" : "cat.fill")
            .font(.system(size: 22, weight: .semibold))
            .foregroundColor(.snapvetAccentPrimary)
            .frame(width: 36, height: 36)
            .background(
                Circle()
                    .fill(Color.snapvetHeaderBg.opacity(0.6))
            )
    }

    private enum CaseHistoryTransitionField: String {
        case patientName
        case speciesIcon
    }

    private func caseHistoryTransitionId(field: CaseHistoryTransitionField) -> String {
        "case-history-\(caseInfo.id)-\(field.rawValue)"
    }

    private func displaySpecies(_ value: Species) -> String {
        value == .dog ? "Canine" : "Feline"
    }

    private func displayWeight(_ value: Double) -> String {
        let displayed = weightUnit == .kg ? (value / 2.20462) : value
        if displayed.rounded() == displayed {
            return "\(Int(displayed)) \(weightUnit.title)"
        }
        return String(format: "%.1f %@", displayed, weightUnit.title)
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

    private func formatTemperature(_ value: Double?) -> String {
        guard let value else { return "-" }
        if temperatureUnit == .fahrenheit {
            return formatDouble((value * 9.0 / 5.0) + 32.0)
        }
        return formatDouble(value)
    }

    private var weightUnit: WeightUnit {
        WeightUnit(rawValue: weightUnitRawValue) ?? .lb
    }

    private var temperatureUnit: TemperatureUnit {
        TemperatureUnit(rawValue: temperatureUnitRawValue) ?? .celsius
    }

    private func formatBloodPressure(sys: Int?, dia: Int?, map: Int?) -> String {
        if let sys, let dia, let map {
            return "\(sys)/\(dia) (\(map))"
        }
        if let sys, let dia {
            return "\(sys)/\(dia)"
        }
        if let map {
            return "MAP \(map)"
        }
        return "-"
    }

    private func formatEcg(_ record: VitalRecord) -> String {
        if record.ecg?.name == "OTHER" {
            let custom = record.ecgOtherText?.trimmingCharacters(in: .whitespacesAndNewlines) ?? ""
            return custom.isEmpty ? "Other" : custom
        }
        return displayEnum(record.ecg?.name)
    }

    private func exportPdf() {
        do {
            let data = buildPdfData()
            let humanDate = DateFormatter.snapvetExportReadable.string(from: Date())
            let fileName = "\(sanitizedFileName(caseInfo.patientName))-\(sanitizedFileName(humanDate)).pdf"
            let url = FileManager.default.temporaryDirectory.appendingPathComponent(fileName)
            try data.write(to: url, options: .atomic)
            sharePayload = ShareSheetPayload(activityItems: [url])
            SnapVetHaptics.prominentCommit()
        } catch {
            exportErrorMessage = error.localizedDescription
            SnapVetHaptics.error()
        }
    }

    private func buildPdfData() -> Data {
        let chronologicalRecords = viewModel.state.records.sorted {
            $0.timestamp.toEpochMilliseconds() < $1.timestamp.toEpochMilliseconds()
        }
        let builder = RecordTablePdfBuilder(
            caseInfo: caseInfo,
            records: chronologicalRecords,
            durationText: durationText,
            weightUnit: weightUnit,
            temperatureUnit: temperatureUnit
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
    let weightUnit: WeightUnit
    let temperatureUnit: TemperatureUnit

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
            ("BP", 92),
            ("Temp \(temperatureUnit.title)", 58),
            ("Iso", 34),
            ("O₂", 34),
            ("Fluids", 44),
            ("ECG", 64),
            ("CRT", 56),
            ("Pulse", 52),
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
                if let logo = UIImage(named: "BrandLogoInApp") {
                    let logoSize: CGFloat = 26
                    let logoRect = CGRect(
                        x: pageRect.width - margin - logoSize,
                        y: y,
                        width: logoSize,
                        height: logoSize
                    )
                    logo.draw(in: logoRect)
                }
                drawParagraph("SurgiVitals Records Export", attrs: titleAttrs, spacing: 8)
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

            var rowParagraphStyle: NSMutableParagraphStyle {
                let paragraph = NSMutableParagraphStyle()
                paragraph.alignment = .left
                paragraph.lineBreakMode = .byWordWrapping
                return paragraph
            }

            var rowCellAttrs: [NSAttributedString.Key: Any] {
                var attrs = bodyAttrs
                attrs[.paragraphStyle] = rowParagraphStyle
                return attrs
            }

            func visibleCharacterCount(
                for text: String,
                width: CGFloat,
                maxHeight: CGFloat,
                attrs: [NSAttributedString.Key: Any]
            ) -> Int {
                guard !text.isEmpty else { return 0 }
                let attributed = NSAttributedString(string: text, attributes: attrs)
                let framesetter = CTFramesetterCreateWithAttributedString(attributed)
                let path = CGPath(rect: CGRect(x: 0, y: 0, width: width, height: maxHeight), transform: nil)
                let frame = CTFramesetterCreateFrame(
                    framesetter,
                    CFRange(location: 0, length: attributed.length),
                    path,
                    nil
                )
                let visibleRange = CTFrameGetVisibleStringRange(frame)
                return max(0, visibleRange.length)
            }

            func splitText(_ text: String, visibleUTF16Count: Int) -> (visible: String, remaining: String) {
                guard !text.isEmpty else { return ("", "") }
                let nsText = text as NSString
                let length = nsText.length
                let count = min(max(0, visibleUTF16Count), length)
                if count >= length {
                    return (text, "")
                }
                let visible = nsText.substring(to: count)
                let remainder = nsText.substring(from: count).trimmingCharacters(in: .whitespacesAndNewlines)
                return (visible, remainder)
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
                    formatBloodPressure(sys: record.bpSys?.intValue, dia: record.bpDia?.intValue, map: record.bpMap?.intValue),
                    formatTemperature(record.temp?.doubleValue),
                    formatDouble(record.sevoIso?.doubleValue),
                    formatDouble(record.o2Flow?.doubleValue),
                    formatDouble(record.fluids?.doubleValue),
                    formatEcg(record),
                    displayEnum(record.crt?.name),
                    displayEnum(record.pulseQuality?.name),
                    displayEnum(record.mucousMembrane?.name),
                    notes
                ]
            }

            func drawRecordRow(number: Int, record: VitalRecord) {
                let widths = columnWidths
                var remainingValues = rowValues(number: number, record: record)

                while true {
                    if y + minimumRowHeight > pageRect.height - margin {
                        beginPage(showCaseHeader: false)
                        drawTableHeaderRow()
                    }

                    let availableHeight = pageRect.height - margin - y
                    let maxTextHeight = max(1, availableHeight - (cellPaddingY * 2))
                    var fragmentValues = Array(repeating: "", count: remainingValues.count)
                    var nextRemainingValues = Array(repeating: "", count: remainingValues.count)
                    var fragmentContentHeight: CGFloat = 0
                    var canDrawFragment = true

                    for index in remainingValues.indices {
                        let width = widths[index]
                        let textWidth = max(1, width - (cellPaddingX * 2))
                        let currentText = remainingValues[index]

                        if currentText.isEmpty {
                            continue
                        }

                        let visibleCount = visibleCharacterCount(
                            for: currentText,
                            width: textWidth,
                            maxHeight: maxTextHeight,
                            attrs: rowCellAttrs
                        )

                        if visibleCount == 0 {
                            canDrawFragment = false
                            break
                        }

                        let split = splitText(currentText, visibleUTF16Count: visibleCount)
                        fragmentValues[index] = split.visible
                        nextRemainingValues[index] = split.remaining

                        let visibleHeight = textHeight(split.visible, width: textWidth, attrs: rowCellAttrs)
                        fragmentContentHeight = max(fragmentContentHeight, visibleHeight)
                    }

                    if !canDrawFragment {
                        beginPage(showCaseHeader: false)
                        drawTableHeaderRow()
                        continue
                    }

                    let fragmentHeight = max(minimumRowHeight, fragmentContentHeight + (cellPaddingY * 2))
                    if fragmentHeight > availableHeight {
                        beginPage(showCaseHeader: false)
                        drawTableHeaderRow()
                        continue
                    }

                    var x = margin
                    for index in fragmentValues.indices {
                        let width = widths[index]
                        let value = fragmentValues[index]
                        let cellRect = CGRect(x: x, y: y, width: width, height: fragmentHeight)
                        UIColor.darkGray.setStroke()
                        let border = UIBezierPath(rect: cellRect)
                        border.lineWidth = 0.4
                        border.stroke()

                        (value as NSString).draw(
                            with: cellRect.insetBy(dx: cellPaddingX, dy: cellPaddingY),
                            options: [.usesLineFragmentOrigin, .usesFontLeading],
                            attributes: rowCellAttrs,
                            context: nil
                        )
                        x += width
                    }

                    y += fragmentHeight

                    if nextRemainingValues.allSatisfy({ $0.isEmpty }) {
                        break
                    }

                    remainingValues = nextRemainingValues
                    beginPage(showCaseHeader: false)
                    drawTableHeaderRow()
                }
            }

            beginPage(showCaseHeader: true)

            if records.isEmpty {
                drawParagraph("No vital records saved.", attrs: bodyAttrs)
                return
            }

            drawTableHeaderRow()
            for index in records.indices {
                let number = index + 1
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
        value == .dog ? "Canine" : "Feline"
    }

    private func displayWeight(_ value: Double) -> String {
        let displayed = weightUnit == .kg ? (value / 2.20462) : value
        if displayed.rounded() == displayed {
            return "\(Int(displayed)) \(weightUnit.title)"
        }
        return String(format: "%.1f %@", displayed, weightUnit.title)
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

    private func formatTemperature(_ value: Double?) -> String {
        guard let value else { return "-" }
        if temperatureUnit == .fahrenheit {
            return formatDouble((value * 9.0 / 5.0) + 32.0)
        }
        return formatDouble(value)
    }

    private func formatTime(_ instant: KotlinInstant) -> String {
        let date = Date(timeIntervalSince1970: TimeInterval(instant.toEpochMilliseconds()) / 1000)
        return DateFormatter.snapvetRecordTime.string(from: date)
    }

    private func formatDate(_ instant: KotlinInstant) -> String {
        let date = Date(timeIntervalSince1970: TimeInterval(instant.toEpochMilliseconds()) / 1000)
        return DateFormatter.snapvetRecordDate.string(from: date)
    }

    private func formatBloodPressure(sys: Int?, dia: Int?, map: Int?) -> String {
        if let sys, let dia, let map {
            return "\(sys)/\(dia) (\(map))"
        }
        if let sys, let dia {
            return "\(sys)/\(dia)"
        }
        if let map {
            return "MAP \(map)"
        }
        return "-"
    }

    private func formatEcg(_ record: VitalRecord) -> String {
        if record.ecg?.name == "OTHER" {
            let custom = record.ecgOtherText?.trimmingCharacters(in: .whitespacesAndNewlines) ?? ""
            return custom.isEmpty ? "Other" : custom
        }
        return displayEnum(record.ecg?.name)
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

    static let snapvetExportReadable: DateFormatter = {
        let formatter = DateFormatter()
        formatter.dateFormat = "MMM d yyyy h.mm a"
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
