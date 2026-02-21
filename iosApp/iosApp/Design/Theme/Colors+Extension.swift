// SnapVet Design System - Colors
import SwiftUI
import UIKit

extension Color {
    private static func dynamic(
        light: UIColor,
        dark: UIColor
    ) -> Color {
        Color(
            UIColor { traitCollection in
                traitCollection.userInterfaceStyle == .dark ? dark : light
            }
        )
    }

    private static func rgb(
        _ red: CGFloat,
        _ green: CGFloat,
        _ blue: CGFloat,
        alpha: CGFloat = 1.0
    ) -> UIColor {
        UIColor(red: red / 255, green: green / 255, blue: blue / 255, alpha: alpha)
    }

    // MARK: - Primary Backgrounds
    static let snapvetPrimaryBg = dynamic(
        light: rgb(244, 248, 255), // #F4F8FF
        dark: rgb(18, 18, 18) // #121212
    )
    static let snapvetTileBg = dynamic(
        light: rgb(255, 255, 255), // #FFFFFF
        dark: rgb(30, 30, 30) // #1E1E1E
    )
    static let snapvetHeaderBg = dynamic(
        light: rgb(233, 241, 255), // #E9F1FF
        dark: rgb(24, 24, 24) // #181818
    )

    // MARK: - Accents
    static let snapvetAccentPrimary = dynamic(
        light: rgb(39, 174, 96), // #27AE60
        dark: rgb(39, 174, 96) // #27AE60
    )
    static let snapvetAccentAlert = dynamic(
        light: rgb(232, 33, 82), // #E82152
        dark: rgb(232, 33, 82) // #E82152
    )
    static let snapvetAccentWarning = dynamic(
        light: rgb(243, 157, 18), // #F39D12
        dark: rgb(243, 157, 18) // #F39D12
    )
    static let snapvetAccentSuccess = dynamic(
        light: rgb(4, 184, 74), // #04B84A
        dark: rgb(4, 184, 74) // #04B84A
    )
    static let snapvetAccentError = dynamic(
        light: rgb(186, 33, 66), // #BA2142
        dark: rgb(186, 33, 66) // #BA2142
    )

    // MARK: - Text
    static let snapvetTextPrimary = dynamic(
        light: rgb(16, 42, 76), // #102A4C
        dark: rgb(242, 242, 242) // #F2F2F2
    )
    static let snapvetTextSecondary = dynamic(
        light: rgb(61, 95, 141), // #3D5F8D
        dark: rgb(176, 176, 176) // #B0B0B0
    )
    static let snapvetTextTertiary = dynamic(
        light: rgb(101, 130, 168), // #6582A8
        dark: rgb(138, 138, 138) // #8A8A8A
    )

    // MARK: - Utility
    static let snapvetBorderSubtle = dynamic(
        light: rgb(196, 212, 238), // #C4D4EE
        dark: rgb(42, 42, 42) // #2A2A2A
    )
    static let snapvetDivider = dynamic(
        light: rgb(216, 227, 246), // #D8E3F6
        dark: rgb(36, 36, 36) // #242424
    )
    static let snapvetOverlay = dynamic(
        light: rgb(0, 0, 0, alpha: 0.35),
        dark: rgb(0, 0, 0, alpha: 0.55)
    )
}
