package com.snapvet.design.component.parameter

import androidx.compose.foundation.background
import androidx.compose.foundation.border
import androidx.compose.foundation.clickable
import androidx.compose.foundation.interaction.MutableInteractionSource
import androidx.compose.foundation.layout.Arrangement
import androidx.compose.foundation.layout.Box
import androidx.compose.foundation.layout.Column
import androidx.compose.foundation.layout.Row
import androidx.compose.foundation.layout.fillMaxWidth
import androidx.compose.foundation.layout.padding
import androidx.compose.foundation.shape.RoundedCornerShape
import androidx.compose.material3.Text
import androidx.compose.material3.ripple
import androidx.compose.runtime.Composable
import androidx.compose.runtime.remember
import androidx.compose.ui.Alignment
import androidx.compose.ui.Modifier
import androidx.compose.ui.draw.clip
import androidx.compose.ui.draw.shadow
import androidx.compose.ui.graphics.Color
import androidx.compose.ui.text.font.FontWeight
import androidx.compose.ui.tooling.preview.Preview
import androidx.compose.ui.unit.dp
import androidx.compose.ui.unit.sp
import com.snapvet.design.theme.SnapVetColors
import com.snapvet.design.theme.SnapVetTheme
import com.snapvet.design.theme.SnapVetTypography

@Composable
fun ParameterTile(
    name: String,
    value: String,
    unit: String = "",
    status: ParameterStatus = ParameterStatus.NORMAL,
    previousValue: String? = null,
    modifier: Modifier = Modifier,
    onClick: () -> Unit = {}
) {
    val backgroundColor = SnapVetColors.TileBg
    val borderColor = when (status) {
        ParameterStatus.NORMAL -> SnapVetColors.BorderSubtle
        ParameterStatus.WARNING -> SnapVetColors.AccentWarning.copy(alpha = 0.6f)
        ParameterStatus.ALERT -> SnapVetColors.AccentAlert.copy(alpha = 0.6f)
    }

    val valueColor = when (status) {
        ParameterStatus.NORMAL -> SnapVetColors.TextPrimary
        ParameterStatus.WARNING -> SnapVetColors.AccentWarning
        ParameterStatus.ALERT -> SnapVetColors.AccentAlert
    }

    Box(
        modifier = modifier
            .shadow(
                elevation = 4.dp,
                shape = RoundedCornerShape(12.dp),
                clip = false
            )
            .clip(RoundedCornerShape(12.dp))
            .background(backgroundColor)
            .border(1.dp, borderColor, RoundedCornerShape(12.dp))
            .clickable(
                interactionSource = remember { MutableInteractionSource() },
                indication = ripple(bounded = true, color = Color.White.copy(alpha = 0.1f)),
                onClick = onClick
            )
            .padding(16.dp),
        contentAlignment = Alignment.Center
    ) {
        Column(
            modifier = Modifier.fillMaxWidth(),
            horizontalAlignment = Alignment.CenterHorizontally,
            verticalArrangement = Arrangement.spacedBy(8.dp)
        ) {
            // Parameter name + previous value
            Row(
                modifier = Modifier.fillMaxWidth(),
                horizontalArrangement = Arrangement.SpaceBetween,
                verticalAlignment = Alignment.CenterVertically
            ) {
                Text(
                    text = name,
                    style = SnapVetTypography.bodyMedium,
                    color = SnapVetColors.TextSecondary,
                    fontWeight = FontWeight.Medium
                )

                if (previousValue != null && previousValue != value) {
                    Text(
                        text = previousValue,
                        style = SnapVetTypography.bodySmall,
                        color = SnapVetColors.TextTertiary
                    )
                }
            }

            // Value
            Row(
                horizontalArrangement = Arrangement.Center,
                verticalAlignment = Alignment.Bottom
            ) {
                Text(
                    text = value,
                    style = SnapVetTypography.displayLarge.copy(fontSize = 40.sp),
                    color = valueColor,
                    fontWeight = FontWeight.Bold
                )

                if (unit.isNotEmpty()) {
                    Text(
                        text = unit,
                        style = SnapVetTypography.bodySmall,
                        color = SnapVetColors.TextSecondary,
                        modifier = Modifier.padding(start = 8.dp, bottom = 6.dp),
                        fontWeight = FontWeight.Medium
                    )
                }
            }
        }
    }
}

// region Previews

@Preview(name = "Parameter Tile - Normal", showBackground = true)
@Composable
private fun ParameterTileNormalPreview() {
    SnapVetTheme {
        ParameterTile(
            name = "Temperature",
            value = "101.5",
            unit = "°F",
            status = ParameterStatus.NORMAL
        )
    }
}

@Preview(name = "Parameter Tile - Warning", showBackground = true)
@Composable
private fun ParameterTileWarningPreview() {
    SnapVetTheme {
        ParameterTile(
            name = "Heart Rate",
            value = "140",
            unit = "bpm",
            status = ParameterStatus.WARNING
        )
    }
}

@Preview(name = "Parameter Tile - Alert", showBackground = true)
@Composable
private fun ParameterTileAlertPreview() {
    SnapVetTheme {
        ParameterTile(
            name = "Blood Pressure",
            value = "180",
            unit = "mmHg",
            status = ParameterStatus.ALERT
        )
    }
}

@Preview(name = "Parameter Tile - All States", showBackground = true)
@Composable
private fun ParameterTileAllStatesPreview() {
    SnapVetTheme {
        Column(
            modifier = Modifier.padding(16.dp),
            verticalArrangement = Arrangement.spacedBy(16.dp)
        ) {
            ParameterTile(
                name = "Temperature",
                value = "101.5",
                unit = "°F",
                status = ParameterStatus.NORMAL
            )
            ParameterTile(
                name = "Heart Rate",
                value = "140",
                unit = "bpm",
                status = ParameterStatus.WARNING
            )
            ParameterTile(
                name = "Blood Pressure",
                value = "180",
                unit = "mmHg",
                status = ParameterStatus.ALERT
            )
        }
    }
}

@Preview(name = "Parameter Tile - No Unit", showBackground = true)
@Composable
private fun ParameterTileNoUnitPreview() {
    SnapVetTheme {
        ParameterTile(
            name = "Weight",
            value = "25",
            status = ParameterStatus.NORMAL
        )
    }
}

@Preview(name = "Parameter Tile - With Previous Value", showBackground = true)
@Composable
private fun ParameterTileWithPreviousValuePreview() {
    SnapVetTheme {
        Column(
            modifier = Modifier.padding(16.dp),
            verticalArrangement = Arrangement.spacedBy(16.dp)
        ) {
            ParameterTile(
                name = "Heart Rate",
                value = "88",
                unit = "bpm",
                status = ParameterStatus.NORMAL,
                previousValue = "85"
            )
            ParameterTile(
                name = "Temp",
                value = "37.8",
                unit = "°C",
                status = ParameterStatus.WARNING,
                previousValue = "38.1"
            )
            // Same value — previous should NOT show
            ParameterTile(
                name = "SpO₂",
                value = "98",
                unit = "%",
                status = ParameterStatus.NORMAL,
                previousValue = "98"
            )
        }
    }
}

// endregion
