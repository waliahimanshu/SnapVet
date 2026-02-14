package com.snapvet.design.preview

import androidx.compose.runtime.Composable
import androidx.compose.ui.tooling.preview.Preview
import com.snapvet.design.component.input.NumericKeypad
import com.snapvet.design.component.input.NumericKeypadButton
import com.snapvet.design.theme.SnapVetTheme

@Preview(name = "Numeric Keypad Button - Default", showBackground = true)
@Composable
fun NumericKeypadButtonPreview() {
    SnapVetTheme {
        NumericKeypadButton(
            label = "5",
            onClick = {}
        )
    }
}

@Preview(name = "Numeric Keypad Button - Accent", showBackground = true)
@Composable
fun NumericKeypadButtonAccentPreview() {
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
fun NumericKeypadPreview() {
    SnapVetTheme {
        NumericKeypad(
            currentValue = "98.6"
        )
    }
}

@Preview(name = "Numeric Keypad - Empty", showBackground = true)
@Composable
fun NumericKeypadEmptyPreview() {
    SnapVetTheme {
        NumericKeypad(
            currentValue = ""
        )
    }
}
