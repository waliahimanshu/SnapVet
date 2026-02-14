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
import androidx.compose.material.ripple.rememberRipple
import androidx.compose.material3.Text
import androidx.compose.runtime.Composable
import androidx.compose.ui.Alignment
import androidx.compose.ui.Modifier
import androidx.compose.ui.draw.clip
import androidx.compose.ui.draw.shadow
import androidx.compose.ui.graphics.Color
import androidx.compose.ui.text.font.FontWeight
import androidx.compose.ui.unit.dp
import androidx.compose.ui.unit.sp
import com.snapvet.design.theme.SnapVetColors
import com.snapvet.design.theme.SnapVetTypography

@Composable
fun ParameterTile(
    name: String,
    value: String,
    unit: String = "",
    status: ParameterStatus = ParameterStatus.NORMAL,
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
                interactionSource = MutableInteractionSource(),
                indication = rememberRipple(bounded = true, color = Color.White.copy(alpha = 0.1f)),
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
            // Parameter name
            Text(
                text = name,
                style = SnapVetTypography.bodyMedium,
                color = SnapVetColors.TextSecondary,
                fontWeight = FontWeight.Medium
            )

            // Value
            Row(
                horizontalArrangement = Arrangement.Center,
                verticalAlignment = Alignment.Baseline
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
                        modifier = Modifier.padding(start = 8.dp),
                        fontWeight = FontWeight.Medium
                    )
                }
            }
        }
    }
}
