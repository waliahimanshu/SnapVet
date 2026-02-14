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
import androidx.compose.material3.Text
import androidx.compose.material3.ripple
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
import com.snapvet.design.theme.SnapVetColors
import com.snapvet.design.theme.SnapVetTheme
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
                        interactionSource = remember { MutableInteractionSource() },
                        indication = ripple(color = Color.White.copy(alpha = 0.1f)),
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

// region Previews

@Preview(name = "Chip Selector - None Selected", showBackground = true)
@Composable
private fun ChipSelectorPreview() {
    SnapVetTheme {
        ChipSelector(
            options = listOf(
                ChipOption("normal", "Normal", SnapVetColors.AccentSuccess),
                ChipOption("warning", "Warning", SnapVetColors.AccentWarning),
                ChipOption("alert", "Alert", SnapVetColors.AccentAlert)
            ),
            selectedId = null
        )
    }
}

@Preview(name = "Chip Selector - Selected", showBackground = true)
@Composable
private fun ChipSelectorSelectedPreview() {
    SnapVetTheme {
        ChipSelector(
            options = listOf(
                ChipOption("normal", "Normal", SnapVetColors.AccentSuccess),
                ChipOption("warning", "Warning", SnapVetColors.AccentWarning),
                ChipOption("alert", "Alert", SnapVetColors.AccentAlert)
            ),
            selectedId = "warning"
        )
    }
}

@Preview(name = "Chip Selector - Interactive", showBackground = true)
@Composable
private fun ChipSelectorInteractivePreview() {
    SnapVetTheme {
        var selectedId by remember { mutableStateOf<String?>(null) }
        ChipSelector(
            options = listOf(
                ChipOption("dog", "Dog"),
                ChipOption("cat", "Cat"),
                ChipOption("bird", "Bird"),
                ChipOption("other", "Other")
            ),
            selectedId = selectedId,
            onSelectionChange = { selectedId = it }
        )
    }
}

// endregion
