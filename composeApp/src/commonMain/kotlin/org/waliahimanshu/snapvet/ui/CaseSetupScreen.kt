package org.waliahimanshu.snapvet.ui

import androidx.compose.foundation.layout.Arrangement
import androidx.compose.foundation.layout.Column
import androidx.compose.foundation.layout.Row
import androidx.compose.foundation.layout.Spacer
import androidx.compose.foundation.layout.fillMaxWidth
import androidx.compose.foundation.layout.height
import androidx.compose.foundation.layout.padding
import androidx.compose.material3.Button
import androidx.compose.material3.OutlinedButton
import androidx.compose.material3.Text
import androidx.compose.material3.TextField
import androidx.compose.runtime.Composable
import androidx.compose.runtime.LaunchedEffect
import androidx.compose.runtime.collectAsState
import androidx.compose.runtime.getValue
import androidx.compose.ui.Modifier
import androidx.compose.ui.text.input.KeyboardType
import androidx.compose.ui.unit.dp
import androidx.compose.ui.text.input.KeyboardOptions
import com.snapvet.domain.model.Case
import com.snapvet.domain.model.Species
import com.snapvet.viewmodel.CaseSetupViewModel

@Composable
fun CaseSetupScreen(
    viewModel: CaseSetupViewModel,
    onCaseCreated: (Case) -> Unit
) {
    val state by viewModel.state.collectAsState()

    LaunchedEffect(state.createdCase?.id) {
        state.createdCase?.let(onCaseCreated)
    }

    Column(
        modifier = Modifier
            .fillMaxWidth()
            .padding(16.dp),
        verticalArrangement = Arrangement.spacedBy(12.dp)
    ) {
        TextField(
            value = state.patientName,
            onValueChange = viewModel::updatePatientName,
            label = { Text("Patient Name") },
            modifier = Modifier.fillMaxWidth()
        )

        Row(horizontalArrangement = Arrangement.spacedBy(8.dp)) {
            val selectedSpecies = state.species
            if (selectedSpecies == Species.DOG) {
                Button(onClick = { viewModel.updateSpecies(Species.DOG) }) { Text("Dog") }
            } else {
                OutlinedButton(onClick = { viewModel.updateSpecies(Species.DOG) }) { Text("Dog") }
            }
            if (selectedSpecies == Species.CAT) {
                Button(onClick = { viewModel.updateSpecies(Species.CAT) }) { Text("Cat") }
            } else {
                OutlinedButton(onClick = { viewModel.updateSpecies(Species.CAT) }) { Text("Cat") }
            }
        }

        TextField(
            value = state.weight?.toString().orEmpty(),
            onValueChange = { value ->
                viewModel.updateWeight(value.toDoubleOrNull())
            },
            label = { Text("Weight (lb)") },
            keyboardOptions = KeyboardOptions(keyboardType = KeyboardType.Number),
            modifier = Modifier.fillMaxWidth()
        )

        TextField(
            value = state.procedure,
            onValueChange = viewModel::updateProcedure,
            label = { Text("Procedure") },
            modifier = Modifier.fillMaxWidth()
        )

        TextField(
            value = state.anestheticProtocol,
            onValueChange = viewModel::updateAnestheticProtocol,
            label = { Text("Anesthetic Protocol") },
            modifier = Modifier.fillMaxWidth()
        )

        Button(
            onClick = { viewModel.startCase() },
            enabled = state.patientName.isNotBlank() &&
                state.species != null &&
                state.weight != null &&
                state.procedure.isNotBlank()
        ) {
            Text("Start Anesthesia")
        }

        state.errorMessage?.let { message ->
            Text(text = message)
        }

        Spacer(modifier = Modifier.height(12.dp))
    }
}
