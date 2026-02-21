import SwiftUI
import Shared

struct CaseListScreen: View {
    @ObservedObject var viewModel: CaseListViewModelWrapper
    var onNewCase: () -> Void = {}
    var onCaseSelected: (Case) -> Void = { _ in }

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
                    header

                    Text("Case History")
                        .font(SnapVetFont.headlineLarge)
                        .foregroundColor(.snapvetTextPrimary)

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

    private var header: some View {
        VStack(alignment: .leading, spacing: 6) {
            Text("SnapVet")
                .font(.system(size: 48, weight: .bold, design: .rounded))
                .foregroundColor(.snapvetTextPrimary)

            Text("Anesthesia Monitoring")
                .font(SnapVetFont.headlineMedium)
                .foregroundColor(.snapvetTextSecondary)
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .padding(16)
        .snapVetGlassCard(cornerRadius: 22)
    }

    private func caseCard(for item: Case) -> some View {
        Button(action: { onCaseSelected(item) }) {
            VStack(alignment: .leading, spacing: 10) {
                HStack(alignment: .center) {
                    Text(item.patientName)
                        .font(SnapVetFont.titleLarge)
                        .foregroundColor(.snapvetTextPrimary)

                    Spacer()

                    statusChip(status: item.status)
                }

                Text("\(displaySpecies(item.species))   \(displayWeight(item.weight))   \(item.procedure)")
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

    private func statusChip(status: CaseStatus) -> some View {
        let isCompleted = status.name == "COMPLETED"
        return Text(isCompleted ? "completed" : "active")
            .font(SnapVetFont.labelMedium.weight(.semibold))
            .foregroundColor(isCompleted ? .snapvetTextPrimary : .snapvetPrimaryBg)
            .padding(.horizontal, 10)
            .padding(.vertical, 5)
            .background(
                Capsule()
                    .fill(isCompleted ? Color.snapvetTextTertiary.opacity(0.35) : Color.snapvetAccentPrimary)
            )
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

    private func displaySpecies(_ species: Species) -> String {
        species == .dog ? "Dog" : "Cat"
    }

    private func displayWeight(_ value: Double) -> String {
        if value.rounded() == value {
            return "\(Int(value)) lb"
        }
        return String(format: "%.1f lb", value)
    }

    private func formatDate(_ instant: KotlinTimeInstant) -> String {
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

    var body: some View {
        Button(action: action) {
            Image(systemName: "plus")
                .font(.system(size: 21, weight: .bold))
                .frame(width: 58, height: 58)
                .foregroundColor(.white)
                .background(
                    Circle()
                        .fill(Color.snapvetAccentPrimary)
                )
                .overlay(
                    Circle()
                        .stroke(Color.white.opacity(0.25), lineWidth: 1)
                )
                .shadow(color: .black.opacity(0.35), radius: 10, x: 0, y: 6)
        }
        .accessibilityLabel("New Case")
    }
}

private extension DateFormatter {
    static let snapvetCaseDate: DateFormatter = {
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
