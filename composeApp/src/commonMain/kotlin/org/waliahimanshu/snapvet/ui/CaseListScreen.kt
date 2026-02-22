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
import com.snapvet.domain.model.Case
import com.snapvet.domain.model.Species
import com.snapvet.viewmodel.CaseListViewModel
import kotlinx.datetime.Instant
import kotlinx.datetime.TimeZone
import kotlinx.datetime.toLocalDateTime

@Composable
fun CaseListScreen(viewModel: CaseListViewModel) {
    val state by viewModel.state.collectAsState()

    LazyColumn(
        modifier = Modifier.fillMaxSize(),
        contentPadding = PaddingValues(16.dp),
        verticalArrangement = Arrangement.spacedBy(12.dp)
    ) {
        items(state.cases) { item ->
            Column(modifier = Modifier.padding(8.dp)) {
                Text(text = item.patientName)
                Text(text = "${displaySpecies(item.species)} • ${displayWeight(item.weight)} • ${item.procedure}")
                Text(text = formatDateTime(item))
            }
        }
    }
}

private fun displaySpecies(species: Species): String {
    return if (species == Species.DOG) "Dog" else "Cat"
}

private fun displayWeight(value: Double): String {
    return if (value % 1.0 == 0.0) {
        "${value.toInt()} kg"
    } else {
        String.format("%.1f kg", value)
    }
}

private fun formatDateTime(caseInfo: Case): String {
    val timestamp = Instant.fromEpochMilliseconds(caseInfo.startTime.toEpochMilliseconds())
    val dateTime = timestamp.toLocalDateTime(TimeZone.currentSystemDefault())
    val month = dateTime.month.name.lowercase().replaceFirstChar { it.uppercase() }
    return "${month} ${dateTime.dayOfMonth}, ${dateTime.year} ${dateTime.hour.toString().padStart(2, '0')}:${dateTime.minute.toString().padStart(2, '0')}"
}
