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
import androidx.compose.foundation.layout.heightIn
import androidx.compose.foundation.layout.padding
import androidx.compose.foundation.shape.RoundedCornerShape
import androidx.compose.material3.Text
import androidx.compose.material3.ripple
import androidx.compose.runtime.Composable
import androidx.compose.runtime.remember
import androidx.compose.ui.Alignment
import androidx.compose.ui.Modifier
import androidx.compose.ui.draw.clip
import androidx.compose.ui.graphics.Color
import androidx.compose.ui.text.font.FontWeight
import androidx.compose.ui.tooling.preview.Preview
import androidx.compose.ui.unit.dp
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
    val borderColor = when (status) {
        ParameterStatus.NORMAL -> SnapVetColors.BorderSubtle
        ParameterStatus.WARNING -> SnapVetColors.AccentWarning.copy(alpha = 0.8f)
        ParameterStatus.ALERT -> SnapVetColors.AccentAlert.copy(alpha = 0.8f)
    }

    val valueColor = when (status) {
        ParameterStatus.NORMAL -> SnapVetColors.TextPrimary
        ParameterStatus.WARNING -> SnapVetColors.AccentWarning
        ParameterStatus.ALERT -> SnapVetColors.AccentAlert
    }

    Box(
        modifier = modifier
            .fillMaxWidth()
            .heightIn(min = 140.dp)
            .clip(RoundedCornerShape(14.dp))
            .background(SnapVetColors.TileBg.copy(alpha = 0.72f))
            .border(1.dp, borderColor, RoundedCornerShape(14.dp))
            .clickable(
                interactionSource = remember { MutableInteractionSource() },
                indication = ripple(bounded = true, color = Color.White.copy(alpha = 0.1f)),
                onClick = onClick
            )
            .padding(14.dp)
    ) {
        Column(
            modifier = Modifier.fillMaxWidth(),
            verticalArrangement = Arrangement.spacedBy(12.dp)
        ) {
            Row(
                modifier = Modifier.fillMaxWidth(),
                horizontalArrangement = Arrangement.SpaceBetween,
                verticalAlignment = Alignment.CenterVertically
            ) {
                Text(
                    text = name,
                    style = SnapVetTypography.titleMedium,
                    color = SnapVetColors.TextSecondary
                )

                if (previousValue != null && previousValue != value) {
                    Text(
                        text = previousValue,
                        style = SnapVetTypography.bodySmall,
                        color = SnapVetColors.TextTertiary
                    )
                }
            }

            Row(
                modifier = Modifier.fillMaxWidth(),
                horizontalArrangement = Arrangement.spacedBy(10.dp),
                verticalAlignment = Alignment.Bottom
            ) {
                Text(
                    text = value,
                    style = SnapVetTypography.displayMedium,
                    color = valueColor,
                    fontWeight = FontWeight.Bold,
                    modifier = Modifier
                        .weight(1f)
                        .clip(RoundedCornerShape(10.dp))
                        .background(SnapVetColors.HeaderBg.copy(alpha = 0.45f))
                        .border(1.dp, SnapVetColors.BorderSubtle, RoundedCornerShape(10.dp))
                        .padding(horizontal = 14.dp, vertical = 12.dp)
                )

                if (unit.isNotEmpty()) {
                    Text(
                        text = unit,
                        style = SnapVetTypography.titleMedium,
                        color = SnapVetColors.TextSecondary,
                        modifier = Modifier.padding(bottom = 12.dp)
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
        ParameterTile(name = "HR", value = "120", unit = "bpm")
    }
}

@Preview(name = "Parameter Tile - Warning", showBackground = true)
@Composable
private fun ParameterTileWarningPreview() {
    SnapVetTheme {
        ParameterTile(name = "SpO₂", value = "92", unit = "%", status = ParameterStatus.WARNING)
    }
}

@Preview(name = "Parameter Tile - Alert", showBackground = true)
@Composable
private fun ParameterTileAlertPreview() {
    SnapVetTheme {
        ParameterTile(name = "Systolic BP", value = "70", unit = "mmHg", status = ParameterStatus.ALERT)
    }
}

// endregion
