package com.snapvet.design.component.input

import androidx.compose.foundation.background
import androidx.compose.foundation.clickable
import androidx.compose.foundation.interaction.MutableInteractionSource
import androidx.compose.foundation.layout.Arrangement
import androidx.compose.foundation.layout.Box
import androidx.compose.foundation.layout.Column
import androidx.compose.foundation.layout.Row
import androidx.compose.foundation.layout.Spacer
import androidx.compose.foundation.layout.aspectRatio
import androidx.compose.foundation.layout.fillMaxHeight
import androidx.compose.foundation.layout.fillMaxWidth
import androidx.compose.foundation.layout.height
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
import androidx.compose.ui.unit.sp
import com.snapvet.design.theme.SnapVetColors
import com.snapvet.design.theme.SnapVetTheme
import com.snapvet.design.theme.SnapVetTypography

@Composable
fun NumericKeypadButton(
    label: String,
    onClick: () -> Unit,
    modifier: Modifier = Modifier,
    isAccent: Boolean = false
) {
    val bgColor = if (isAccent) SnapVetColors.AccentPrimary else SnapVetColors.TileBg
    val textColor = if (isAccent) Color.White else SnapVetColors.TextPrimary

    Box(
        modifier = modifier
            .clip(RoundedCornerShape(8.dp))
            .background(bgColor)
            .clickable(
                interactionSource = remember { MutableInteractionSource() },
                indication = ripple(color = Color.White.copy(alpha = 0.2f)),
                onClick = onClick
            )
            .aspectRatio(1f),
        contentAlignment = Alignment.Center
    ) {
        Text(
            text = label,
            style = SnapVetTypography.headlineMedium,
            color = textColor,
            fontWeight = FontWeight.Bold,
            fontSize = 24.sp
        )
    }
}

@Composable
fun NumericKeypad(
    currentValue: String = "",
    onNumberClick: (String) -> Unit = {},
    onDecimalClick: () -> Unit = {},
    onBackspaceClick: () -> Unit = {},
    onConfirm: () -> Unit = {},
    onCancel: () -> Unit = {}
) {
    Column(
        modifier = Modifier
            .fillMaxWidth()
            .background(SnapVetColors.HeaderBg)
            .padding(16.dp),
        verticalArrangement = Arrangement.spacedBy(8.dp)
    ) {
        // Current value display
        Box(
            modifier = Modifier
                .fillMaxWidth()
                .background(SnapVetColors.TileBg, RoundedCornerShape(8.dp))
                .padding(16.dp)
        ) {
            Text(
                text = currentValue.ifEmpty { "0" },
                style = SnapVetTypography.displayLarge.copy(fontSize = 60.sp),
                color = SnapVetColors.AccentPrimary,
                fontWeight = FontWeight.Bold
            )
        }

        Spacer(modifier = Modifier.height(12.dp))

        // Number buttons grid
        repeat(3) { row ->
            Row(
                modifier = Modifier
                    .fillMaxWidth()
                    .height(60.dp),
                horizontalArrangement = Arrangement.spacedBy(8.dp)
            ) {
                repeat(3) { col ->
                    val number = (1 + row * 3 + col).toString()
                    NumericKeypadButton(
                        label = number,
                        onClick = { onNumberClick(number) },
                        modifier = Modifier.weight(1f)
                    )
                }
            }
        }

        // Bottom row (0, decimal, backspace)
        Row(
            modifier = Modifier
                .fillMaxWidth()
                .height(60.dp),
            horizontalArrangement = Arrangement.spacedBy(8.dp)
        ) {
            NumericKeypadButton(
                label = "0",
                onClick = { onNumberClick("0") },
                modifier = Modifier.weight(1f)
            )
            NumericKeypadButton(
                label = ".",
                onClick = onDecimalClick,
                modifier = Modifier.weight(1f)
            )
            NumericKeypadButton(
                label = "⌫",
                onClick = onBackspaceClick,
                modifier = Modifier.weight(1f)
            )
        }

        Spacer(modifier = Modifier.height(8.dp))

        // Action buttons
        Row(
            modifier = Modifier
                .fillMaxWidth()
                .height(52.dp),
            horizontalArrangement = Arrangement.spacedBy(8.dp)
        ) {
            Box(
                modifier = Modifier
                    .weight(1f)
                    .fillMaxHeight()
                    .clip(RoundedCornerShape(8.dp))
                    .background(SnapVetColors.TileBg)
                    .clickable(
                        interactionSource = remember { MutableInteractionSource() },
                        indication = ripple(color = Color.White.copy(alpha = 0.1f)),
                        onClick = onCancel
                    ),
                contentAlignment = Alignment.Center
            ) {
                Text(
                    text = "Cancel",
                    color = SnapVetColors.TextSecondary,
                    fontWeight = FontWeight.SemiBold
                )
            }

            Box(
                modifier = Modifier
                    .weight(1f)
                    .fillMaxHeight()
                    .clip(RoundedCornerShape(8.dp))
                    .background(SnapVetColors.AccentPrimary)
                    .clickable(
                        interactionSource = remember { MutableInteractionSource() },
                        indication = ripple(color = Color.White.copy(alpha = 0.2f)),
                        onClick = onConfirm
                    ),
                contentAlignment = Alignment.Center
            ) {
                Text(
                    text = "Save",
                    color = Color.White,
                    fontWeight = FontWeight.Bold
                )
            }
        }
    }
}

// region Previews

@Preview(name = "Numeric Keypad Button - Default", showBackground = true)
@Composable
private fun NumericKeypadButtonPreview() {
    SnapVetTheme {
        NumericKeypadButton(
            label = "5",
            onClick = {}
        )
    }
}

@Preview(name = "Numeric Keypad Button - Accent", showBackground = true)
@Composable
private fun NumericKeypadButtonAccentPreview() {
    SnapVetTheme {
        NumericKeypadButton(
            label = "OK",
            onClick = {},
            isAccent = true
        )
    }
}

@Preview(name = "Numeric Keypad", showBackground = true)
@Composable
private fun NumericKeypadPreview() {
    SnapVetTheme {
        NumericKeypad(
            currentValue = "98.6"
        )
    }
}

@Preview(name = "Numeric Keypad - Empty", showBackground = true)
@Composable
private fun NumericKeypadEmptyPreview() {
    SnapVetTheme {
        NumericKeypad(
            currentValue = ""
        )
    }
}

// endregion
