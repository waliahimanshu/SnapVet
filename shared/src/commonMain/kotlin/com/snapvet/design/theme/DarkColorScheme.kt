package com.snapvet.design.theme

import androidx.compose.material3.darkColorScheme
import androidx.compose.ui.graphics.Color

internal val DarkColorScheme = darkColorScheme(
    primary = SnapVetColors.AccentPrimary,
    onPrimary = Color.White,
    primaryContainer = SnapVetColors.AccentSuccess,
    onPrimaryContainer = Color.White,

    secondary = SnapVetColors.AccentWarning,
    onSecondary = Color.Black,
    secondaryContainer = SnapVetColors.TileBg,
    onSecondaryContainer = Color.White,

    tertiary = SnapVetColors.AccentAlert,
    onTertiary = Color.White,
    tertiaryContainer = SnapVetColors.AccentError,
    onTertiaryContainer = Color.White,

    error = SnapVetColors.AccentAlert,
    onError = Color.White,
    errorContainer = SnapVetColors.AccentError,
    onErrorContainer = Color.White,

    background = SnapVetColors.PrimaryBg,
    onBackground = SnapVetColors.TextPrimary,

    surface = SnapVetColors.TileBg,
    onSurface = SnapVetColors.TextPrimary,

    outline = SnapVetColors.BorderSubtle,
    outlineVariant = SnapVetColors.Divider
)