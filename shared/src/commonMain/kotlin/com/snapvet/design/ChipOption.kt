package com.snapvet.design

import androidx.compose.foundation.background
import androidx.compose.foundation.border
import androidx.compose.foundation.clickable
import androidx.compose.foundation.interaction.MutableInteractionSource
import androidx.compose.foundation.layout.Arrangement
import androidx.compose.foundation.layout.Box
import androidx.compose.foundation.layout.Column
import androidx.compose.foundation.layout.fillMaxWidth
import androidx.compose.foundation.layout.height
import androidx.compose.foundation.layout.padding
import androidx.compose.foundation.shape.RoundedCornerShape
import androidx.compose.material.ripple.rememberRipple
import androidx.compose.material3.Text
import androidx.compose.runtime.Composable
import androidx.compose.ui.Alignment
import androidx.compose.ui.Modifier
import androidx.compose.ui.draw.clip
import androidx.compose.ui.graphics.Color
import androidx.compose.ui.text.font.FontWeight
import androidx.compose.ui.unit.dp
import com.snapvet.design.theme.SnapVetColors
import com.snapvet.design.theme.SnapVetTypography

data class ChipOption(
    val id: String,
    val label: String,
    val color: Color = SnapVetColors.TileBg
)

@Composable
fun ChipSelector(
    options: List<ChipOption>,
    selectedId: String? = null,
    onSelectionChange: (String) -> Unit = {},
    modifier: Modifier = Modifier
) {
    Column(
        modifier = modifier.fillMaxWidth(),
        verticalArrangement = Arrangement.spacedBy(8.dp)
    ) {
        options.forEach { option ->
            val isSelected = option.id == selectedId
            val bgColor = if (isSelected) option.color else SnapVetColors.TileBg
            val borderColor = if (isSelected) SnapVetColors.AccentPrimary else SnapVetColors.BorderSubtle
            val borderWidth = if (isSelected) 2.dp else 1.dp

            Box(
                modifier = Modifier
                    .fillMaxWidth()
                    .height(48.dp)
                    .clip(RoundedCornerShape(8.dp))
                    .background(bgColor)
                    .border(borderWidth, borderColor, RoundedCornerShape(8.dp))
                    .clickable(
                        interactionSource = MutableInteractionSource(),
                        indication = rememberRipple(color = Color.White.copy(alpha = 0.1f)),
                        onClick = { onSelectionChange(option.id) }
                    )
                    .padding(12.dp),
                contentAlignment = Alignment.CenterStart
            ) {
                Text(
                    text = option.label,
                    style = SnapVetTypography.bodyLarge,
                    color = if (isSelected) SnapVetColors.AccentPrimary else SnapVetColors.TextPrimary,
                    fontWeight = if (isSelected) FontWeight.Bold else FontWeight.Normal
                )
            }
        }
    }
}
