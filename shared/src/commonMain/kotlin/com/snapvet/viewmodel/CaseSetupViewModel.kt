package com.snapvet.viewmodel

import com.snapvet.domain.model.Case
import com.snapvet.domain.model.Species
import com.snapvet.domain.usecase.StartCaseInput
import com.snapvet.domain.usecase.StartCaseUsecase
import kotlinx.coroutines.CoroutineScope
import kotlinx.coroutines.flow.MutableStateFlow
import kotlinx.coroutines.flow.StateFlow
import kotlinx.coroutines.flow.asStateFlow
import kotlinx.coroutines.launch

class CaseSetupViewModel(
    private val startCaseUsecase: StartCaseUsecase,
    scope: CoroutineScope? = null
) : BaseViewModel(scope) {

    private val _state = MutableStateFlow(CaseSetupState())
    val state: StateFlow<CaseSetupState> = _state.asStateFlow()

    fun updatePatientName(value: String) {
        _state.value = _state.value.copy(patientName = value)
    }

    fun updateSpecies(value: Species) {
        _state.value = _state.value.copy(species = value)
    }

    fun updateWeight(value: Double?) {
        _state.value = _state.value.copy(weight = value)
    }

    fun updateProcedure(value: String) {
        _state.value = _state.value.copy(procedure = value)
    }

    fun updateAnestheticProtocol(value: String) {
        _state.value = _state.value.copy(anestheticProtocol = value)
    }

    fun startCase() {
        val current = _state.value
        if (current.patientName.isBlank() || current.species == null || current.weight == null) {
            _state.value = current.copy(errorMessage = "Missing required fields")
            return
        }

        _state.value = current.copy(isSaving = true, errorMessage = null)

        scope.launch {
            runCatching {
                startCaseUsecase(
                    StartCaseInput(
                        patientName = current.patientName,
                        species = current.species,
                        weight = current.weight,
                        procedure = current.procedure,
                        anestheticProtocol = current.anestheticProtocol
                    )
                )
            }.onSuccess { created ->
                _state.value = current.copy(
                    isSaving = false,
                    createdCase = created,
                    errorMessage = null
                )
            }.onFailure { error ->
                _state.value = current.copy(
                    isSaving = false,
                    errorMessage = error.message
                )
            }
        }
    }
}

data class CaseSetupState(
    val patientName: String = "",
    val species: Species? = null,
    val weight: Double? = null,
    val procedure: String = "",
    val anestheticProtocol: String = "",
    val isSaving: Boolean = false,
    val createdCase: Case? = null,
    val errorMessage: String? = null
)
