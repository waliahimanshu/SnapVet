package org.waliahimanshu.snapvet.ui

import androidx.compose.foundation.layout.Arrangement
import androidx.compose.foundation.layout.Column
import androidx.compose.foundation.layout.PaddingValues
import androidx.compose.foundation.layout.fillMaxSize
import androidx.compose.foundation.layout.padding
import androidx.compose.foundation.lazy.LazyColumn
import androidx.compose.foundation.lazy.items
import androidx.compose.material3.Text
import androidx.compose.runtime.Composable
import androidx.compose.runtime.collectAsState
import androidx.compose.runtime.getValue
import androidx.compose.ui.Modifier
import androidx.compose.ui.unit.dp
import com.snapvet.viewmodel.RecordTableViewModel

@Composable
fun RecordTableScreen(viewModel: RecordTableViewModel) {
    val state by viewModel.state.collectAsState()

    LazyColumn(
        modifier = Modifier.fillMaxSize(),
        contentPadding = PaddingValues(16.dp),
        verticalArrangement = Arrangement.spacedBy(12.dp)
    ) {
        items(state.records) { record ->
            Column(modifier = Modifier.padding(8.dp)) {
                Text(text = "${record.timestamp}")
                Text(text = "HR: ${record.hr ?: "—"}  RR: ${record.rr ?: "—"}  SpO₂: ${record.spo2 ?: "—"}")
                Text(text = "BP: ${record.bpSys ?: "—"}/${record.bpDia ?: "—"} (${record.bpMap ?: "—"})")
                Text(text = "Temp: ${record.temp ?: "—"}  EtCO₂: ${record.etco2 ?: "—"}")
                Text(text = "ECG: ${record.ecg?.name ?: "—"}  CRT: ${record.crt?.name ?: "—"}  MM: ${record.mucousMembrane?.name ?: "—"}")
                record.notes?.let { Text(text = "Notes: $it") }
            }
        }
    }
}
