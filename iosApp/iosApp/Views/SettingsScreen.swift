import SwiftUI

struct SettingsScreen: View {
    @AppStorage("snapvet_appearance_mode") private var appearanceModeRawValue = AppAppearance.dark.rawValue
    @AppStorage("snapvet_weight_unit") private var weightUnitRawValue = WeightUnit.lb.rawValue
    @AppStorage("snapvet_temperature_unit") private var temperatureUnitRawValue = TemperatureUnit.celsius.rawValue
    @AppStorage("snapvet_save_nudge_interval_minutes") private var saveNudgeIntervalMinutes = 5
    @AppStorage("snapvet_enable_vital_warnings") private var enableVitalWarnings = true
    @State private var showWarningRules = false

    var body: some View {
        Form {
            Section("Appearance") {
                Picker("Theme", selection: $appearanceModeRawValue) {
                    ForEach(AppAppearance.allCases) { mode in
                        Text(mode.title).tag(mode.rawValue)
                    }
                }
            }

            Section("Units") {
                Picker("Weight", selection: $weightUnitRawValue) {
                    ForEach(WeightUnit.allCases) { unit in
                        Text(unit.title).tag(unit.rawValue)
                    }
                }

                Picker("Temperature", selection: $temperatureUnitRawValue) {
                    ForEach(TemperatureUnit.allCases) { unit in
                        Text(unit.title).tag(unit.rawValue)
                    }
                }
            }

            Section("Monitoring") {
                Stepper(value: $saveNudgeIntervalMinutes, in: 1...30) {
                    Text("Save Nudge Interval: \(saveNudgeIntervalMinutes) min")
                }

                Toggle("Enable Tile Warning Colors", isOn: $enableVitalWarnings)

                Button("View Warning Rules") {
                    showWarningRules = true
                }
            }

            Section("About") {
                LabeledContent("App Version", value: appVersion)
                if let websiteURL {
                    HStack(alignment: .center, spacing: 12) {
                        Image("BrandLogoInApp")
                            .resizable()
                            .scaledToFit()
                            .frame(width: 64, height: 64)

                        VStack(alignment: .leading, spacing: 2) {
                            Text("Built with ❤️ for every pet")
                            Link("LifeCare Pet Hospital", destination: websiteURL)
                        }
                        .font(.footnote)
                        .frame(maxWidth: .infinity, alignment: .leading)
                    }
                }
            }
        }
        .navigationTitle("Settings")
        .sheet(isPresented: $showWarningRules) {
            NavigationStack {
                WarningRulesView()
            }
        }
    }

    private var appVersion: String {
        let version = Bundle.main.object(forInfoDictionaryKey: "CFBundleShortVersionString") as? String ?? "—"
        let build = Bundle.main.object(forInfoDictionaryKey: "CFBundleVersion") as? String ?? "—"
        return "\(version) (\(build))"
    }

    private var websiteURL: URL? {
        URL(string: "https://www.lifecarepethospital.com/")
    }
}

#Preview {
    NavigationStack {
        SettingsScreen()
    }
}
