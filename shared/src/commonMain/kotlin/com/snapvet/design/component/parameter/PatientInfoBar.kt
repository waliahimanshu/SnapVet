package com.snapvet.design.component.parameter

import androidx.compose.foundation.background
import androidx.compose.foundation.layout.Arrangement
import androidx.compose.foundation.layout.Column
import androidx.compose.foundation.layout.Row
import androidx.compose.foundation.layout.Spacer
import androidx.compose.foundation.layout.fillMaxWidth
import androidx.compose.foundation.layout.height
import androidx.compose.foundation.layout.padding
import androidx.compose.foundation.layout.width
import androidx.compose.foundation.shape.RoundedCornerShape
import androidx.compose.material3.Text
import androidx.compose.runtime.Composable
import androidx.compose.ui.Alignment
import androidx.compose.ui.Modifier
import androidx.compose.ui.draw.clip
import androidx.compose.ui.unit.dp
import com.snapvet.design.theme.SnapVetColors
import com.snapvet.design.theme.SnapVetTypography

@Composable
fun PatientInfoBar(
    patientName: String,
    weight: String,
    species: String,
    elapsedTime: String,
    batteryLevel: Int,
    showNudge: Boolean = false
) {
    Column(modifier = Modifier.fillMaxWidth()) {
        Row(
            modifier = Modifier
                .fillMaxWidth()
                .background(if (showNudge) SnapVetColors.AccentWarning.copy(alpha = 0.2f) else SnapVetColors.HeaderBg)
                .padding(12.dp),
            verticalAlignment = Alignment.CenterVertically
        ) {
            Column(verticalArrangement = Arrangement.spacedBy(4.dp)) {
                Text(text = patientName, style = SnapVetTypography.titleLarge, color = SnapVetColors.TextPrimary)
                Row(verticalAlignment = Alignment.CenterVertically) {
                    Text(text = "$weight kg", style = SnapVetTypography.bodySmall, color = SnapVetColors.TextSecondary)
                    Spacer(modifier = Modifier.width(8.dp))
                    Text(text = species, style = SnapVetTypography.bodySmall, color = SnapVetColors.TextSecondary)
                }
            }
            Spacer(modifier = Modifier.weight(1f))
            Column(horizontalAlignment = Alignment.End, verticalArrangement = Arrangement.spacedBy(4.dp)) {
                Text(text = elapsedTime, style = SnapVetTypography.titleMedium, color = SnapVetColors.AccentPrimary)
                BatteryIndicator(level = batteryLevel)
            }
        }
    }
}

@Composable
private fun BatteryIndicator(level: Int) {
    val color = when (level) {
        in 0..20 -> SnapVetColors.AccentAlert
        in 21..50 -> SnapVetColors.AccentWarning
        else -> SnapVetColors.AccentPrimary
    }
    Row(
        modifier = Modifier
            .clip(RoundedCornerShape(6.dp))
            .background(SnapVetColors.TileBg)
            .padding(horizontal = 8.dp, vertical = 4.dp),
        verticalAlignment = Alignment.CenterVertically,
        horizontalArrangement = Arrangement.spacedBy(4.dp)
    ) {
        Text(text = "$level%", style = SnapVetTypography.bodySmall, color = SnapVetColors.TextSecondary)
        Row(horizontalArrangement = Arrangement.spacedBy(2.dp)) {
            repeat(3) { index ->
                val alpha = when (index) {
                    0 -> 1f
                    1 -> 0.6f
                    else -> 0.3f
                }
                androidx.compose.foundation.layout.Box(
                    modifier = Modifier
                        .width(4.dp)
                        .height(10.dp)
                        .background(color.copy(alpha = alpha))
                )
            }
        }
    }
}
