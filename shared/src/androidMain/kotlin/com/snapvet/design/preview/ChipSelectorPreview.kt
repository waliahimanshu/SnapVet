package com.snapvet.design.preview

import androidx.compose.runtime.Composable
import androidx.compose.runtime.getValue
import androidx.compose.runtime.mutableStateOf
import androidx.compose.runtime.remember
import androidx.compose.runtime.setValue
import androidx.compose.ui.tooling.preview.Preview
import com.snapvet.design.ChipOption
import com.snapvet.design.ChipSelector
import com.snapvet.design.theme.SnapVetColors
import com.snapvet.design.theme.SnapVetTheme

@Preview(name = "Chip Selector - None Selected", showBackground = true)
@Composable
fun ChipSelectorPreview() {
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
fun ChipSelectorSelectedPreview() {
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
fun ChipSelectorInteractivePreview() {
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
