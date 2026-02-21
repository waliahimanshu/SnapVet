package org.waliahimanshu.snapvet.ui

import androidx.compose.foundation.ExperimentalFoundationApi
import androidx.compose.foundation.layout.Arrangement
import androidx.compose.foundation.layout.Box
import androidx.compose.foundation.layout.BoxWithConstraints
import androidx.compose.foundation.layout.Column
import androidx.compose.foundation.layout.Row
import androidx.compose.foundation.layout.Spacer
import androidx.compose.foundation.layout.fillMaxSize
import androidx.compose.foundation.layout.fillMaxWidth
import androidx.compose.foundation.layout.height
import androidx.compose.foundation.layout.padding
import androidx.compose.foundation.lazy.grid.GridCells
import androidx.compose.foundation.lazy.grid.LazyVerticalGrid
import androidx.compose.foundation.lazy.grid.items
import androidx.compose.foundation.text.KeyboardOptions
import androidx.compose.material3.Button
import androidx.compose.material3.OutlinedButton
import androidx.compose.material3.Text
import androidx.compose.material3.TextField
import androidx.compose.runtime.Composable
import androidx.compose.runtime.getValue
import androidx.compose.runtime.mutableStateOf
import androidx.compose.runtime.remember
import androidx.compose.runtime.setValue
import androidx.compose.runtime.collectAsState
import androidx.compose.ui.Alignment
import androidx.compose.ui.Modifier
import androidx.compose.ui.text.input.KeyboardType
import androidx.compose.ui.unit.dp
import androidx.compose.ui.window.Dialog
import com.snapvet.design.ChipOption
import com.snapvet.design.ChipSelector
import com.snapvet.design.component.input.NumericKeypad
import com.snapvet.design.component.parameter.ParameterStatus
import com.snapvet.design.component.parameter.ParameterTile
import com.snapvet.domain.model.CRTReading
import com.snapvet.domain.model.ECGReading
import com.snapvet.domain.model.MucousMembraneReading
import com.snapvet.domain.model.VitalsInput
import com.snapvet.viewmodel.MonitoringViewModel

private enum class VitalField(val label: String, val unit: String) {
    HR("HR", "bpm"),
    RR("RR", "bpm"),
    SPO2("SpO₂", "%"),
    ETCO2("EtCO₂", "mmHg"),
    TEMP("Temp", "°C"),
    SEVO("Iso/Sevo%", "%"),
    O2("O₂ Flow", "L/min"),
    BP("BP", ""),
    ECG("ECG", ""),
    CRT("CRT", ""),
    MM("MM", ""),
    NOTES("Notes", "")
}

private sealed class ActiveDialog {
    data class Numeric(val field: VitalField, val allowDecimal: Boolean) : ActiveDialog()
    data class BloodPressure(val sys: String, val dia: String, val map: String) : ActiveDialog()
    data class Chips(val field: VitalField) : ActiveDialog()
    data class Notes(val value: String) : ActiveDialog()
}

@OptIn(ExperimentalFoundationApi::class)
@Composable
fun MonitoringScreen(
    viewModel: MonitoringViewModel,
    onEndSession: () -> Unit
) {
    val state by viewModel.state.collectAsState()
    var activeDialog by remember { mutableStateOf<ActiveDialog?>(null) }

    BoxWithConstraints(modifier = Modifier.fillMaxSize().padding(16.dp)) {
        val columns = when {
            maxWidth < 600.dp -> 2
            maxWidth < 900.dp -> 3
            else -> 4
        }

        Column(verticalArrangement = Arrangement.spacedBy(12.dp)) {
            LazyVerticalGrid(
                columns = GridCells.Fixed(columns),
                verticalArrangement = Arrangement.spacedBy(12.dp),
                horizontalArrangement = Arrangement.spacedBy(12.dp),
                modifier = Modifier.weight(1f)
            ) {
                val tiles = buildTileItems(state.currentVitals, state.lastSaved)
                items(tiles) { item ->
                    ParameterTile(
                        name = item.label,
                        value = item.value,
                        unit = item.unit,
                        status = item.status,
                        previousValue = item.previousValue,
                        modifier = Modifier.fillMaxWidth()
                    ) {
                        activeDialog = when (item.field) {
                            VitalField.BP -> ActiveDialog.BloodPressure(
                                sys = state.currentVitals.bpSys?.toString().orEmpty(),
                                dia = state.currentVitals.bpDia?.toString().orEmpty(),
                                map = state.currentVitals.bpMap?.toString().orEmpty()
                            )
                            VitalField.ECG, VitalField.CRT, VitalField.MM -> ActiveDialog.Chips(item.field)
                            VitalField.NOTES -> ActiveDialog.Notes(state.currentVitals.notes.orEmpty())
                            VitalField.TEMP, VitalField.SEVO, VitalField.O2 -> ActiveDialog.Numeric(item.field, true)
                            else -> ActiveDialog.Numeric(item.field, false)
                        }
                    }
                }
            }

            Row(horizontalArrangement = Arrangement.spacedBy(12.dp)) {
                Button(onClick = { viewModel.save() }) {
                    Text("Save Entry")
                }
                OutlinedButton(onClick = onEndSession) {
                    Text("End Anesthesia")
                }
            }
        }
    }

    when (val dialog = activeDialog) {
        is ActiveDialog.Numeric -> NumericDialog(
            field = dialog.field,
            allowDecimal = dialog.allowDecimal,
            currentValue = valueForField(state.currentVitals, dialog.field),
            onDismiss = { activeDialog = null },
            onConfirm = { value ->
                val updated = applyNumeric(state.currentVitals, dialog.field, value)
                viewModel.updateVitals(updated)
                activeDialog = null
            }
        )
        is ActiveDialog.BloodPressure -> BloodPressureDialog(
            initialSys = dialog.sys,
            initialDia = dialog.dia,
            initialMap = dialog.map,
            onDismiss = { activeDialog = null },
            onConfirm = { sys, dia, map ->
                val updated = state.currentVitals.copy(
                    bpSys = sys.toIntOrNull(),
                    bpDia = dia.toIntOrNull(),
                    bpMap = map.toIntOrNull()
                )
                viewModel.updateVitals(updated)
                activeDialog = null
            }
        )
        is ActiveDialog.Chips -> ChipDialog(
            field = dialog.field,
            current = state.currentVitals,
            onDismiss = { activeDialog = null },
            onConfirm = { updated ->
                viewModel.updateVitals(updated)
                activeDialog = null
            }
        )
        is ActiveDialog.Notes -> NotesDialog(
            initialValue = dialog.value,
            onDismiss = { activeDialog = null },
            onConfirm = { value ->
                viewModel.updateVitals(state.currentVitals.copy(notes = value))
                activeDialog = null
            }
        )
        null -> Unit
    }
}

private data class TileItem(
    val field: VitalField,
    val label: String,
    val value: String,
    val unit: String,
    val status: ParameterStatus,
    val previousValue: String?
)

private fun buildTileItems(current: VitalsInput, last: com.snapvet.domain.model.VitalRecord?): List<TileItem> {
    val bpValue = listOf(current.bpSys, current.bpDia)
        .takeIf { it.any { value -> value != null } }
        ?.let { "${it[0] ?: "—"}/${it[1] ?: "—"}" }
        ?: "—/—"
    val bpMap = current.bpMap?.toString() ?: "—"
    return listOf(
        TileItem(VitalField.HR, "HR", current.hr?.toString() ?: "—", "bpm", ParameterStatus.NORMAL, last?.hr?.toString()),
        TileItem(VitalField.RR, "RR", current.rr?.toString() ?: "—", "bpm", ParameterStatus.NORMAL, last?.rr?.toString()),
        TileItem(VitalField.SPO2, "SpO₂", current.spo2?.toString() ?: "—", "%", ParameterStatus.NORMAL, last?.spo2?.toString()),
        TileItem(VitalField.BP, "BP", "$bpValue ($bpMap)", "", ParameterStatus.NORMAL, null),
        TileItem(VitalField.ETCO2, "EtCO₂", current.etco2?.toString() ?: "—", "mmHg", ParameterStatus.NORMAL, last?.etco2?.toString()),
        TileItem(VitalField.TEMP, "Temp", current.temp?.toString() ?: "—", "°C", ParameterStatus.NORMAL, last?.temp?.toString()),
        TileItem(VitalField.SEVO, "Iso/Sevo%", current.sevoIso?.toString() ?: "—", "%", ParameterStatus.NORMAL, last?.sevoIso?.toString()),
        TileItem(VitalField.O2, "O₂ Flow", current.o2Flow?.toString() ?: "—", "L/min", ParameterStatus.NORMAL, last?.o2Flow?.toString()),
        TileItem(VitalField.ECG, "ECG", current.ecg?.name ?: "—", "", ParameterStatus.NORMAL, last?.ecg?.name),
        TileItem(VitalField.CRT, "CRT", current.crt?.name ?: "—", "", ParameterStatus.NORMAL, last?.crt?.name),
        TileItem(VitalField.MM, "MM", current.mucousMembrane?.name ?: "—", "", ParameterStatus.NORMAL, last?.mucousMembrane?.name),
        TileItem(VitalField.NOTES, "Notes", current.notes?.takeIf { it.isNotBlank() } ?: "—", "", ParameterStatus.NORMAL, last?.notes)
    )
}

@Composable
private fun NumericDialog(
    field: VitalField,
    allowDecimal: Boolean,
    currentValue: String,
    onDismiss: () -> Unit,
    onConfirm: (String) -> Unit
) {
    var value by remember { mutableStateOf(currentValue) }
    Dialog(onDismissRequest = onDismiss) {
        Column(
            modifier = Modifier
                .fillMaxWidth()
                .padding(16.dp),
            verticalArrangement = Arrangement.spacedBy(12.dp)
        ) {
            Text(text = field.label)
            NumericKeypad(
                currentValue = value,
                onNumberClick = { value += it },
                onDecimalClick = { if (allowDecimal && !value.contains(".")) value += "." },
                onBackspaceClick = { if (value.isNotEmpty()) value = value.dropLast(1) },
                onConfirm = { onConfirm(value) },
                onCancel = onDismiss
            )
        }
    }
}

@Composable
private fun BloodPressureDialog(
    initialSys: String,
    initialDia: String,
    initialMap: String,
    onDismiss: () -> Unit,
    onConfirm: (String, String, String) -> Unit
) {
    var sys by remember { mutableStateOf(initialSys) }
    var dia by remember { mutableStateOf(initialDia) }
    var map by remember { mutableStateOf(initialMap) }

    Dialog(onDismissRequest = onDismiss) {
        Column(
            modifier = Modifier
                .fillMaxWidth()
                .padding(16.dp),
            verticalArrangement = Arrangement.spacedBy(12.dp)
        ) {
            Text(text = "Blood Pressure")
            TextField(
                value = sys,
                onValueChange = { sys = it },
                label = { Text("Systolic") },
                keyboardOptions = KeyboardOptions(keyboardType = KeyboardType.Number),
                modifier = Modifier.fillMaxWidth()
            )
            TextField(
                value = dia,
                onValueChange = { dia = it },
                label = { Text("Diastolic") },
                keyboardOptions = KeyboardOptions(keyboardType = KeyboardType.Number),
                modifier = Modifier.fillMaxWidth()
            )
            TextField(
                value = map,
                onValueChange = { map = it },
                label = { Text("MAP") },
                keyboardOptions = KeyboardOptions(keyboardType = KeyboardType.Number),
                modifier = Modifier.fillMaxWidth()
            )
            Row(horizontalArrangement = Arrangement.spacedBy(8.dp)) {
                Button(onClick = { onConfirm(sys, dia, map) }) { Text("Save") }
                OutlinedButton(onClick = onDismiss) { Text("Cancel") }
            }
        }
    }
}

@Composable
private fun ChipDialog(
    field: VitalField,
    current: VitalsInput,
    onDismiss: () -> Unit,
    onConfirm: (VitalsInput) -> Unit
) {
    val options = when (field) {
        VitalField.ECG -> listOf(
            ChipOption("NSR", "NSR"),
            ChipOption("SINUS_BRADY", "Sinus Brady"),
            ChipOption("SINUS_TACHY", "Sinus Tachy"),
            ChipOption("VPCS", "VPCs"),
            ChipOption("ATRIAL_FIB", "Atrial Fib")
        )
        VitalField.CRT -> listOf(
            ChipOption("LESS_THAN_2_SEC", "< 2 sec"),
            ChipOption("GREATER_THAN_2_SEC", "> 2 sec")
        )
        VitalField.MM -> listOf(
            ChipOption("PINK", "Pink"),
            ChipOption("PALE", "Pale"),
            ChipOption("BLUE", "Blue"),
            ChipOption("GREY", "Grey"),
            ChipOption("MUDDY", "Muddy")
        )
        else -> emptyList()
    }

    var selectedId by remember { mutableStateOf(currentSelectionId(current, field)) }

    Dialog(onDismissRequest = onDismiss) {
        Column(
            modifier = Modifier
                .fillMaxWidth()
                .padding(16.dp),
            verticalArrangement = Arrangement.spacedBy(12.dp)
        ) {
            Text(text = field.label)
            ChipSelector(
                options = options,
                selectedId = selectedId,
                onSelectionChange = { selectedId = it }
            )
            Row(horizontalArrangement = Arrangement.spacedBy(8.dp)) {
                Button(onClick = {
                    onConfirm(applyChipSelection(current, field, selectedId))
                }) {
                    Text("Save")
                }
                OutlinedButton(onClick = onDismiss) { Text("Cancel") }
            }
        }
    }
}

@Composable
private fun NotesDialog(
    initialValue: String,
    onDismiss: () -> Unit,
    onConfirm: (String) -> Unit
) {
    var value by remember { mutableStateOf(initialValue) }
    Dialog(onDismissRequest = onDismiss) {
        Column(
            modifier = Modifier
                .fillMaxWidth()
                .padding(16.dp),
            verticalArrangement = Arrangement.spacedBy(12.dp)
        ) {
            Text(text = "Notes")
            TextField(
                value = value,
                onValueChange = { value = it },
                modifier = Modifier.fillMaxWidth()
            )
            Row(horizontalArrangement = Arrangement.spacedBy(8.dp)) {
                Button(onClick = { onConfirm(value) }) { Text("Save") }
                OutlinedButton(onClick = onDismiss) { Text("Cancel") }
            }
        }
    }
}

private fun valueForField(current: VitalsInput, field: VitalField): String {
    return when (field) {
        VitalField.HR -> current.hr?.toString() ?: ""
        VitalField.RR -> current.rr?.toString() ?: ""
        VitalField.SPO2 -> current.spo2?.toString() ?: ""
        VitalField.ETCO2 -> current.etco2?.toString() ?: ""
        VitalField.TEMP -> current.temp?.toString() ?: ""
        VitalField.SEVO -> current.sevoIso?.toString() ?: ""
        VitalField.O2 -> current.o2Flow?.toString() ?: ""
        else -> ""
    }
}

private fun applyNumeric(current: VitalsInput, field: VitalField, value: String): VitalsInput {
    val intValue = value.toIntOrNull()
    val doubleValue = value.toDoubleOrNull()
    return when (field) {
        VitalField.HR -> current.copy(hr = intValue)
        VitalField.RR -> current.copy(rr = intValue)
        VitalField.SPO2 -> current.copy(spo2 = intValue)
        VitalField.ETCO2 -> current.copy(etco2 = intValue)
        VitalField.TEMP -> current.copy(temp = doubleValue)
        VitalField.SEVO -> current.copy(sevoIso = doubleValue)
        VitalField.O2 -> current.copy(o2Flow = doubleValue)
        else -> current
    }
}

private fun currentSelectionId(current: VitalsInput, field: VitalField): String? {
    return when (field) {
        VitalField.ECG -> current.ecg?.name
        VitalField.CRT -> current.crt?.name
        VitalField.MM -> current.mucousMembrane?.name
        else -> null
    }
}

private fun applyChipSelection(current: VitalsInput, field: VitalField, selectedId: String?): VitalsInput {
    return when (field) {
        VitalField.ECG -> current.copy(ecg = selectedId?.let { ECGReading.valueOf(it) })
        VitalField.CRT -> current.copy(crt = selectedId?.let { CRTReading.valueOf(it) })
        VitalField.MM -> current.copy(mucousMembrane = selectedId?.let { MucousMembraneReading.valueOf(it) })
        else -> current
    }
}
