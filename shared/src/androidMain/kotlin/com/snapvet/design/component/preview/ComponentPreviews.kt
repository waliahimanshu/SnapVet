package com.snapvet.design.component.preview

import androidx.compose.foundation.background
import androidx.compose.foundation.layout.Arrangement
import androidx.compose.foundation.layout.Box
import androidx.compose.foundation.layout.Column
import androidx.compose.foundation.layout.Row
import androidx.compose.foundation.layout.Spacer
import androidx.compose.foundation.layout.fillMaxSize
import androidx.compose.foundation.layout.fillMaxWidth
import androidx.compose.foundation.layout.height
import androidx.compose.foundation.layout.padding
import androidx.compose.foundation.rememberScrollState
import androidx.compose.foundation.shape.RoundedCornerShape
import androidx.compose.foundation.verticalScroll
import androidx.compose.material3.Surface
import androidx.compose.material3.Text
import androidx.compose.runtime.Composable
import androidx.compose.runtime.getValue
import androidx.compose.runtime.mutableStateOf
import androidx.compose.runtime.remember
import androidx.compose.runtime.setValue
import androidx.compose.ui.Alignment
import androidx.compose.ui.Modifier
import androidx.compose.ui.draw.clip
import androidx.compose.ui.graphics.Color
import androidx.compose.ui.text.font.FontWeight
import androidx.compose.ui.tooling.preview.Preview
import androidx.compose.ui.unit.dp
import androidx.compose.ui.unit.sp
import com.snapvet.design.ChipOption
import com.snapvet.design.component.input.NumericKeypad
import com.snapvet.design.component.parameter.ParameterStatus
import com.snapvet.design.component.parameter.ParameterTile
import com.snapvet.design.theme.SnapVetColors
import com.snapvet.design.theme.SnapVetTheme
import com.snapvet.design.theme.SnapVetTypography

@Preview(
    name = "Dark Theme",
    showBackground = true,
    backgroundColor = 0xFF2C3E50,
    widthDp = 1024,
    heightDp = 768
)
@Composable
fun SnapVetThemePreview() {
    SnapVetTheme {
        Surface(color = SnapVetColors.PrimaryBg) {
            Column(
                modifier = Modifier
                    .fillMaxSize()
                    .verticalScroll(rememberScrollState())
                    .padding(24.dp),
                verticalArrangement = Arrangement.spacedBy(32.dp)
            ) {
                // Color palette section
                Text(
                    text = "Color Palette",
                    style = SnapVetTypography.headlineLarge,
                    color = SnapVetColors.TextPrimary,
                    modifier = Modifier.padding(top = 16.dp)
                )

                ColorSwatchRow("Primary Bg", SnapVetColors.PrimaryBg)
                ColorSwatchRow("Tile Bg", SnapVetColors.TileBg)
                ColorSwatchRow("Header Bg", SnapVetColors.HeaderBg)
                ColorSwatchRow("Accent Primary", SnapVetColors.AccentPrimary)
                ColorSwatchRow("Accent Alert", SnapVetColors.AccentAlert)
                ColorSwatchRow("Accent Warning", SnapVetColors.AccentWarning)

                Spacer(modifier = Modifier.height(24.dp))

                // Typography section
                Text(
                    text = "Typography",
                    style = SnapVetTypography.headlineLarge,
                    color = SnapVetColors.TextPrimary
                )

                Text("Display Large (48sp)", style = SnapVetTypography.displayLarge)
                Text("Display Medium (40sp)", style = SnapVetTypography.displayMedium)
                Text("Headline Large (24sp)", style = SnapVetTypography.headlineLarge)
                Text("Body Large (16sp)", style = SnapVetTypography.bodyLarge)
                Text("Body Small (12sp)", style = SnapVetTypography.bodySmall)
            }
        }
    }
}

@Preview(
    name = "Parameter Tiles",
    showBackground = true,
    backgroundColor = 0xFF2C3E50,
    widthDp = 1024,
    heightDp = 400
)
@Composable
fun ParameterTilePreview() {
    SnapVetTheme {
        Surface(color = SnapVetColors.PrimaryBg) {
            Column(
                modifier = Modifier
                    .fillMaxSize()
                    .padding(24.dp),
                verticalArrangement = Arrangement.spacedBy(16.dp)
            ) {
                Text(
                    text = "Parameter Tiles - All States",
                    style = SnapVetTypography.headlineLarge,
                    color = SnapVetColors.TextPrimary
                )

                Row(
                    modifier = Modifier
                        .fillMaxWidth()
                        .height(180.dp),
                    horizontalArrangement = Arrangement.spacedBy(16.dp)
                ) {
                    ParameterTile(
                        name = "Heart Rate",
                        value = "125",
                        unit = "bpm",
                        status = ParameterStatus.NORMAL,
                        modifier = Modifier.weight(1f)
                    )

                    ParameterTile(
                        name = "SpO2",
                        value = "94",
                        unit = "%",
                        status = ParameterStatus.WARNING,
                        modifier = Modifier.weight(1f)
                    )

                    ParameterTile(
                        name = "BP Systolic",
                        value = "75",
                        unit = "mmHg",
                        status = ParameterStatus.ALERT,
                        modifier = Modifier.weight(1f)
                    )
                }
            }
        }
    }
}

@Preview(
    name = "Numeric Keypad",
    showBackground = true,
    backgroundColor = 0xFF2C3E50,
    widthDp = 500,
    heightDp = 700
)
@Composable
fun NumericKeypadPreview() {
    SnapVetTheme {
        Surface(color = SnapVetColors.PrimaryBg) {
            var value by remember { mutableStateOf("125") }

            Column(
                modifier = Modifier
                    .fillMaxSize()
                    .padding(16.dp),
                verticalArrangement = Arrangement.spacedBy(16.dp)
            ) {
                Text(
                    text = "Numeric Keypad",
                    style = SnapVetTypography.headlineLarge,
                    color = SnapVetColors.TextPrimary
                )

                NumericKeypad(
                    currentValue = value,
                    onNumberClick = { value += it },
                    onBackspaceClick = { if (value.isNotEmpty()) value = value.dropLast(1) },
                    onConfirm = { /* Save */ },
                    onCancel = { value = "" }
                )
            }
        }
    }
}

@Composable
private fun ColorSwatchRow(label: String, color: Color) {
    Row(
        modifier = Modifier
            .fillMaxWidth()
            .height(48.dp),
        horizontalArrangement = Arrangement.spacedBy(16.dp),
        verticalAlignment = Alignment.CenterVertically
    ) {
        Box(
            modifier = Modifier
                .height(48.dp)
                .clip(RoundedCornerShape(4.dp))
                .background(color)
                .padding(horizontal = 48.dp)
        )

        Text(
            text = label,
            style = SnapVetTypography.bodyLarge,
            color = SnapVetColors.TextPrimary
        )
    }
}
