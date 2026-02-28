import UIKit

enum SnapVetHaptics {
    static func selection() {
        let generator = UISelectionFeedbackGenerator()
        generator.selectionChanged()
    }

    static func lightTap() {
        impact(style: .light, intensity: 0.75)
    }

    static func primaryAction() {
        impact(style: .medium, intensity: 1.0)
    }

    static func majorSave() {
        impact(style: .heavy, intensity: 1.0)
    }

    static func prominentCommit() {
        let generator = UINotificationFeedbackGenerator()
        generator.notificationOccurred(.success)
    }

    static func warning() {
        let generator = UINotificationFeedbackGenerator()
        generator.notificationOccurred(.warning)
    }

    static func error() {
        let generator = UINotificationFeedbackGenerator()
        generator.notificationOccurred(.error)
    }

    private static func impact(style: UIImpactFeedbackGenerator.FeedbackStyle, intensity: CGFloat) {
        let generator = UIImpactFeedbackGenerator(style: style)
        generator.impactOccurred(intensity: intensity)
    }
}
