package com.snapvet.design.preview

import androidx.compose.foundation.layout.Arrangement
import androidx.compose.foundation.layout.Column
import androidx.compose.foundation.layout.padding
import androidx.compose.runtime.Composable
import androidx.compose.ui.Modifier
import androidx.compose.ui.tooling.preview.Preview
import androidx.compose.ui.unit.dp
import com.snapvet.design.component.parameter.ParameterStatus
import com.snapvet.design.component.parameter.ParameterTile
import com.snapvet.design.theme.SnapVetTheme

@Preview(name = "Parameter Tile - Normal", showBackground = true)
@Composable
fun ParameterTileNormalPreview() {
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
fun ParameterTileWarningPreview() {
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
fun ParameterTileAlertPreview() {
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
fun ParameterTileAllStatesPreview() {
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
fun ParameterTileNoUnitPreview() {
    SnapVetTheme {
        ParameterTile(
            name = "Weight",
            value = "25",
            status = ParameterStatus.NORMAL
        )
    }
}
