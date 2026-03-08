package com.snapvet.viewmodel

import com.snapvet.domain.model.VitalRecord
import com.snapvet.domain.usecase.ObserveVitalRecordsUsecase
import kotlinx.coroutines.CoroutineScope
import kotlinx.coroutines.flow.MutableStateFlow
import kotlinx.coroutines.flow.StateFlow
import kotlinx.coroutines.flow.asStateFlow
import kotlinx.coroutines.launch

class RecordTableViewModel(
    private val caseId: String,
    private val observeVitalRecordsUsecase: ObserveVitalRecordsUsecase,
    scope: CoroutineScope? = null
) : BaseViewModel(scope) {

    private val _state = MutableStateFlow(RecordTableState())
    val state: StateFlow<RecordTableState> = _state.asStateFlow()

    fun observe() {
        _state.value = _state.value.copy(isLoading = true)
        scope.launch {
            observeVitalRecordsUsecase(caseId).collect { records ->
                _state.value = _state.value.copy(
                    records = records.sortedBy { it.timestamp },
                    isLoading = false
                )
            }
        }
    }
}

data class RecordTableState(
    val records: List<VitalRecord> = emptyList(),
    val isLoading: Boolean = true
)
