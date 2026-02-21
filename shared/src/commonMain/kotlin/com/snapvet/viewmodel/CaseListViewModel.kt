package com.snapvet.viewmodel

import com.snapvet.domain.model.Case
import com.snapvet.domain.model.CaseStatus
import com.snapvet.domain.usecase.ObserveCaseListUsecase
import kotlinx.coroutines.CoroutineScope
import kotlinx.coroutines.flow.MutableStateFlow
import kotlinx.coroutines.flow.StateFlow
import kotlinx.coroutines.flow.asStateFlow
import kotlinx.coroutines.launch

class CaseListViewModel(
    private val observeCaseListUsecase: ObserveCaseListUsecase,
    scope: CoroutineScope? = null
) : BaseViewModel(scope) {

    private val _state = MutableStateFlow(CaseListState())
    val state: StateFlow<CaseListState> = _state.asStateFlow()

    fun observe(status: CaseStatus? = null) {
        _state.value = _state.value.copy(isLoading = true, errorMessage = null)
        scope.launch {
            observeCaseListUsecase(status).collect { cases ->
                _state.value = _state.value.copy(
                    cases = cases,
                    isLoading = false,
                    errorMessage = null
                )
            }
        }
    }
}

data class CaseListState(
    val cases: List<Case> = emptyList(),
    val isLoading: Boolean = true,
    val errorMessage: String? = null
)
