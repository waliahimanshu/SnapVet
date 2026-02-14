// SnapVet Design System - Typography
import SwiftUI

enum SnapVetFont {
    // MARK: - Display Styles
    static let displayLarge = Font.system(size: 48, weight: .bold, design: .default)
    static let displayMedium = Font.system(size: 40, weight: .bold, design: .default)
    static let displaySmall = Font.system(size: 32, weight: .bold, design: .default)

    // MARK: - Headline Styles
    static let headlineLarge = Font.system(size: 24, weight: .bold, design: .default)
    static let headlineMedium = Font.system(size: 20, weight: .semibold, design: .default)

    // MARK: - Title Styles
    static let titleLarge = Font.system(size: 18, weight: .semibold, design: .default)
    static let titleMedium = Font.system(size: 16, weight: .medium, design: .default)

    // MARK: - Body Styles
    static let bodyLarge = Font.system(size: 16, weight: .regular, design: .default)
    static let bodyMedium = Font.system(size: 14, weight: .regular, design: .default)
    static let bodySmall = Font.system(size: 12, weight: .regular, design: .default)

    // MARK: - Label Styles
    static let labelLarge = Font.system(size: 14, weight: .medium, design: .default)
    static let labelMedium = Font.system(size: 12, weight: .medium, design: .default)
    static let labelSmall = Font.system(size: 11, weight: .medium, design: .default)

    // MARK: - Monospace (for tables)
    static let monospace = Font.system(size: 14, weight: .regular, design: .monospaced)
}
