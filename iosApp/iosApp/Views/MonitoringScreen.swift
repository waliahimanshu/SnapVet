import SwiftUI
import Shared

private enum VitalField: String, CaseIterable {
    case hr = "HR"
    case rr = "RR"
    case spo2 = "SpO₂"
    case etco2 = "EtCO₂"
    case bpSys = "BP Sys"
    case bpDia = "BP Dia"
    case bpMap = "BP MAP"
    case temp = "Temp"
    case sevoIso = "Sevo/Iso"
    case o2Flow = "O₂ Flow"
    case ecg = "ECG"
    case crt = "CRT"
    case mm = "MM"
    case notes = "Notes"

    var unit: String {
        switch self {
        case .hr, .rr: return "bpm"
        case .spo2: return "%"
        case .etco2: return "mmHg"
        case .bpSys, .bpDia, .bpMap: return "mmHg"
        case .temp: return "°C"
        case .sevoIso: return "%"
        case .o2Flow: return "L/min"
        default: return ""
        }
    }
}

struct MonitoringScreen: View {
    @ObservedObject var viewModel: MonitoringViewModelWrapper
    var onEndSession: () -> Void = {}
    @State private var selectedField: VitalField? = nil
    @State private var keypadValue: String = ""
    @Environment(\.horizontalSizeClass) private var horizontalSizeClass

    private var current: VitalsInput { viewModel.state.currentVitals }
    private var last: VitalRecord? { viewModel.state.lastSaved }

    var body: some View {
        GeometryReader { proxy in
            let isCompact = isCompactLayout(width: proxy.size.width, sizeClass: horizontalSizeClass)
            let columns = monitoringGridColumns(for: proxy.size.width, sizeClass: horizontalSizeClass)

            ScrollView {
                VStack(spacing: 12) {
                    LazyVGrid(columns: columns, spacing: 12) {
                        tile(.hr, value: current.hr?.intValue.description, previous: last?.hr?.intValue.description)
                        tile(.rr, value: current.rr?.intValue.description, previous: last?.rr?.intValue.description)
                        tile(.spo2, value: current.spo2?.intValue.description, previous: last?.spo2?.intValue.description)
                        tile(.etco2, value: current.etco2?.intValue.description, previous: last?.etco2?.intValue.description)
                        tile(.bpSys, value: current.bpSys?.intValue.description, previous: last?.bpSys?.intValue.description)
                        tile(.bpDia, value: current.bpDia?.intValue.description, previous: last?.bpDia?.intValue.description)
                        tile(.bpMap, value: current.bpMap?.intValue.description, previous: last?.bpMap?.intValue.description)
                        tile(.temp, value: current.temp?.doubleValue.description, previous: last?.temp?.doubleValue.description)
                        tile(.sevoIso, value: current.sevoIso?.doubleValue.description, previous: last?.sevoIso?.doubleValue.description)
                        tile(.o2Flow, value: current.o2Flow?.doubleValue.description, previous: last?.o2Flow?.doubleValue.description)
                        tile(.ecg, value: current.ecg?.name, previous: last?.ecg?.name)
                        tile(.crt, value: current.crt?.name, previous: last?.crt?.name)
                        tile(.mm, value: current.mucousMembrane?.name, previous: last?.mucousMembrane?.name)
                        tile(.notes, value: current.notes, previous: last?.notes)
                    }

                    Group {
                        if isCompact {
                            VStack(spacing: 8) {
                                Button("Save Vitals") { viewModel.save() }
                                    .buttonStyle(.borderedProminent)
                                Button("End Session") { onEndSession() }
                                    .buttonStyle(.bordered)
                            }
                        } else {
                            HStack(spacing: 12) {
                                Button("Save Vitals") { viewModel.save() }
                                    .buttonStyle(.borderedProminent)
                                Button("End Session") { onEndSession() }
                                    .buttonStyle(.bordered)
                            }
                        }
                    }
                    .padding(.top, 8)
                }
                .padding(16)
            }
        }
        .sheet(item: $selectedField) { field in
            NumericKeypadView(
                currentValue: keypadValue,
                onNumberTap: { keypadValue.append($0) },
                onDecimalTap: { if !keypadValue.contains(".") { keypadValue.append(".") } },
                onBackspaceTap: { if !keypadValue.isEmpty { keypadValue.removeLast() } },
                onConfirm: {
                    applyNumeric(field: field, value: keypadValue)
                    selectedField = nil
                },
                onCancel: { selectedField = nil }
            )
            .padding(16)
            .background(Color.snapvetPrimaryBg)
        }
        .navigationTitle("Monitoring")
    }

    private func tile(_ field: VitalField, value: String?, previous: String?) -> some View {
        ParameterTileView(
            name: field.rawValue,
            value: value ?? "—",
            unit: field.unit,
            status: .normal,
            previousValue: previous
        ) {
            switch field {
            case .hr, .rr, .spo2, .etco2, .bpSys, .bpDia, .bpMap, .temp, .sevoIso, .o2Flow:
                keypadValue = value ?? ""
                selectedField = field
            default:
                break
            }
        }
    }

    private func applyNumeric(field: VitalField, value: String) {
        let updated = VitalsInput(
            hr: field == .hr ? kotlinInt(value) : current.hr,
            rr: field == .rr ? kotlinInt(value) : current.rr,
            spo2: field == .spo2 ? kotlinInt(value) : current.spo2,
            etco2: field == .etco2 ? kotlinInt(value) : current.etco2,
            bpSys: field == .bpSys ? kotlinInt(value) : current.bpSys,
            bpDia: field == .bpDia ? kotlinInt(value) : current.bpDia,
            bpMap: field == .bpMap ? kotlinInt(value) : current.bpMap,
            temp: field == .temp ? kotlinDouble(value) : current.temp,
            sevoIso: field == .sevoIso ? kotlinDouble(value) : current.sevoIso,
            o2Flow: field == .o2Flow ? kotlinDouble(value) : current.o2Flow,
            ecg: current.ecg,
            crt: current.crt,
            mucousMembrane: current.mucousMembrane,
            notes: current.notes
        )
        viewModel.updateVitals(updated)
    }

    private func isCompactLayout(width: CGFloat, sizeClass: UserInterfaceSizeClass?) -> Bool {
        if sizeClass == .compact { return true }
        return width < 700
    }

    private func monitoringGridColumns(for width: CGFloat, sizeClass: UserInterfaceSizeClass?) -> [GridItem] {
        let count: Int
        if sizeClass == .compact || width < 700 {
            count = 2
        } else if width < 900 {
            count = 3
        } else {
            count = 4
        }
        return Array(repeating: GridItem(.flexible(), spacing: 12), count: count)
    }
}

private func kotlinInt(_ value: String) -> KotlinInt? {
    guard let intValue = Int32(value) else { return nil }
    return KotlinInt(int: intValue)
}

private func kotlinDouble(_ value: String) -> KotlinDouble? {
    guard let doubleValue = Double(value) else { return nil }
    return KotlinDouble(double: doubleValue)
}

extension VitalField: Identifiable {
    var id: String { rawValue }
}
