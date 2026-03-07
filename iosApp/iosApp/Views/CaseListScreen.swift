import SwiftUI
import Shared
import UIKit

struct CaseListScreen: View {
    @ObservedObject var viewModel: CaseListViewModelWrapper
    let sharedTransitionNamespace: Namespace.ID
    var onOpenSettings: () -> Void = {}
    var onNewCase: () -> Void = {}
    var onCaseSelected: (Case) -> Void = { _ in }
    @AppStorage("snapvet_weight_unit") private var weightUnitRawValue = WeightUnit.lb.rawValue

    var body: some View {
        ZStack(alignment: .bottomTrailing) {
            LinearGradient(
                colors: [Color.snapvetHeaderBg, Color.snapvetPrimaryBg],
                startPoint: .top,
                endPoint: .bottom
            )
            .ignoresSafeArea()

            ScrollView {
                VStack(alignment: .leading, spacing: 18) {
                    topBar
                    header

                    caseHistoryHeader

                    if viewModel.state.cases.isEmpty {
                        emptyState
                    } else {
                        LazyVStack(spacing: 12) {
                            ForEach(viewModel.state.cases, id: \.id) { item in
                                caseCard(for: item)
                            }
                        }
                    }
                }
                .padding(.horizontal, 16)
                .padding(.top, 20)
                .padding(.bottom, 88)
            }

            FloatingNewCaseButton(action: onNewCase)
                .padding(.trailing, 20)
                .padding(.bottom, 18)
        }
    }

    private var topBar: some View {
        HStack {
            Spacer()
            Button {
                SnapVetHaptics.selection()
                onOpenSettings()
            } label: {
                Image(systemName: "gearshape")
                    .font(.system(size: 18, weight: .semibold))
                    .foregroundColor(.snapvetTextPrimary)
                    .padding(10)
                    .background(
                        Circle()
                            .fill(Color.snapvetHeaderBg.opacity(0.65))
                    )
            }
            .buttonStyle(.plain)
            .accessibilityLabel("Settings")
        }
        .frame(maxWidth: .infinity, alignment: .trailing)
    }

    private var header: some View {
        VStack(alignment: .leading, spacing: 4) {
            Text("SnapVet")
                .font(.system(size: 48, weight: .bold, design: .rounded))
                .foregroundColor(.snapvetTextPrimary)

            Text("Anesthesia Monitoring")
                .font(SnapVetFont.titleLarge)
                .foregroundColor(.snapvetTextSecondary)
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .padding(.horizontal, 4)
        .padding(.top, 4)
    }

    private var caseHistoryHeader: some View {
        VStack(alignment: .leading, spacing: 2) {
            Text("Case History")
                .font(SnapVetFont.headlineMedium.weight(.semibold))
                .foregroundColor(.snapvetTextPrimary)
        }
    }

    private func caseCard(for item: Case) -> some View {
        Button(action: {
            SnapVetHaptics.lightTap()
            onCaseSelected(item)
        }) {
            VStack(alignment: .leading, spacing: 10) {
                HStack(alignment: .center, spacing: 10) {
                    speciesSymbol(for: item.species)
                        .matchedTransitionSource(id: caseHistoryTransitionId(for: item, field: .speciesIcon), in: sharedTransitionNamespace)

                    Text(item.patientName)
                        .font(SnapVetFont.titleLarge)
                        .foregroundColor(.snapvetTextPrimary)
                        .matchedTransitionSource(id: caseHistoryTransitionId(for: item, field: .patientName), in: sharedTransitionNamespace)

                    Spacer()
                }

                HStack(spacing: 6) {
                    Text(displaySpecies(item.species))
                    Text("•")
                    Text(displayWeight(item.weight))
                    Text("•")
                    Text(item.procedure)
                }
                    .font(SnapVetFont.bodyMedium)
                    .foregroundColor(.snapvetTextSecondary)
                    .lineLimit(1)

                HStack(spacing: 14) {
                    Label(formatDate(item.startTime), systemImage: "calendar")
                    Label(durationText(for: item), systemImage: "clock")
                }
                .font(SnapVetFont.bodySmall)
                .foregroundColor(.snapvetTextSecondary)
            }
            .frame(maxWidth: .infinity, alignment: .leading)
            .padding(14)
            .snapVetGlassCard(cornerRadius: 18)
        }
        .buttonStyle(.plain)
    }

    private var emptyState: some View {
        VStack(spacing: 10) {
            Image(systemName: "list.bullet.clipboard")
                .font(.system(size: 34, weight: .medium))
                .foregroundColor(.snapvetTextSecondary)

            Text("No cases yet")
                .font(SnapVetFont.titleMedium)
                .foregroundColor(.snapvetTextPrimary)

            Text("Use the + button to start your first anesthesia case.")
                .font(SnapVetFont.bodySmall)
                .foregroundColor(.snapvetTextSecondary)
                .multilineTextAlignment(.center)
        }
        .frame(maxWidth: .infinity)
        .padding(20)
        .snapVetGlassCard(cornerRadius: 18)
    }


    private func speciesSymbol(for species: Species) -> some View {
        Image(systemName: species == .dog ? "dog.fill" : "cat.fill")
            .font(.system(size: 18, weight: .semibold))
            .foregroundColor(.snapvetAccentPrimary)
            .frame(width: 30, height: 30)
            .background(
                Circle()
                    .fill(Color.snapvetHeaderBg.opacity(0.6))
            )
    }

    private enum CaseHistoryTransitionField: String {
        case patientName
        case speciesIcon
    }

    private func caseHistoryTransitionId(for item: Case, field: CaseHistoryTransitionField) -> String {
        "case-history-\(item.id)-\(field.rawValue)"
    }

    private func displaySpecies(_ species: Species) -> String {
        species == .dog ? "Canine" : "Feline"
    }

    private func displayWeight(_ value: Double) -> String {
        let unit = WeightUnit(rawValue: weightUnitRawValue) ?? .lb
        let displayed = unit == .kg ? (value / 2.20462) : value
        if displayed.rounded() == displayed {
            return "\(Int(displayed)) \(unit.title)"
        }
        return String(format: "%.1f %@", displayed, unit.title)
    }

    private func formatDate(_ instant: KotlinInstant) -> String {
        let date = Date(timeIntervalSince1970: TimeInterval(instant.toEpochMilliseconds()) / 1000)
        return DateFormatter.snapvetCaseDate.string(from: date)
    }

    private func durationText(for caseInfo: Case) -> String {
        let endMillis = caseInfo.endTime?.toEpochMilliseconds() ?? Int64(Date().timeIntervalSince1970 * 1000)
        let seconds = max(0, (endMillis - caseInfo.startTime.toEpochMilliseconds()) / 1000)
        let minutes = seconds / 60
        if minutes >= 60 {
            return "\(minutes / 60)h \(minutes % 60)m"
        }
        return "\(max(1, minutes))m"
    }
}

private struct FloatingNewCaseButton: View {
    let action: () -> Void
    private var isPad: Bool { UIDevice.current.userInterfaceIdiom == .pad }
    private var iconSize: CGFloat { isPad ? 24 : 20 }
    private var fallbackButtonSize: CGFloat { isPad ? 72 : 56 }

    var body: some View {
        floatingButton
            .accessibilityLabel("New Case")
    }

    @ViewBuilder
    private var floatingButton: some View {
#if swift(>=6.2)
        if #available(iOS 26.0, *) {
            Button(action: {
                SnapVetHaptics.primaryAction()
                action()
            }) {
                Image(systemName: "plus")
                    .font(.system(size: iconSize, weight: .bold))
                    .padding(isPad ? 16 : 12)
            }
            .buttonStyle(.glassProminent)
            .buttonBorderShape(.circle)
            .tint(.snapvetAccentPrimary)
        } else {
            fallbackButton
        }
#else
        fallbackButton
#endif
    }

    private var fallbackButton: some View {
        Button(action: {
            SnapVetHaptics.primaryAction()
            action()
        }) {
            Image(systemName: "plus")
                .font(.system(size: iconSize, weight: .bold))
                .frame(width: fallbackButtonSize, height: fallbackButtonSize)
        }
        .buttonStyle(.borderedProminent)
        .buttonBorderShape(.circle)
        .tint(.snapvetAccentPrimary)
    }
}

private extension DateFormatter {
    static let snapvetCaseDate: DateFormatter = {
        let formatter = DateFormatter()
        formatter.dateStyle = .medium
        formatter.timeStyle = .short
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
