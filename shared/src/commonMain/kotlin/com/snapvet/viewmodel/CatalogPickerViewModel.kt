package com.snapvet.viewmodel

import com.snapvet.domain.model.CatalogItem
import com.snapvet.domain.model.CatalogKind
import com.snapvet.domain.usecase.ObserveCatalogItemsUsecase
import kotlinx.coroutines.CoroutineScope
import kotlinx.coroutines.Job
import kotlinx.coroutines.flow.MutableStateFlow
import kotlinx.coroutines.flow.StateFlow
import kotlinx.coroutines.flow.asStateFlow
import kotlinx.coroutines.flow.catch
import kotlinx.coroutines.flow.collectLatest
import kotlinx.coroutines.launch

class CatalogPickerViewModel(
    private val kind: CatalogKind,
    private val observeCatalogItemsUsecase: ObserveCatalogItemsUsecase,
    scope: CoroutineScope? = null
) : BaseViewModel(scope) {

    private val _state = MutableStateFlow(CatalogPickerState(kind = kind))
    val state: StateFlow<CatalogPickerState> = _state.asStateFlow()

    private var observeJob: Job? = null

    init {
        observe(query = "")
    }

    fun updateQuery(value: String) {
        _state.value = _state.value.copy(query = value)
        observe(query = value)
    }

    private fun observe(query: String) {
        observeJob?.cancel()
        observeJob = scope.launch {
            observeCatalogItemsUsecase(kind = kind, query = query)
                .catch { error ->
                    _state.value = _state.value.copy(errorMessage = error.message)
                }
                .collectLatest { items ->
                    _state.value = _state.value.copy(
                        items = items,
                        errorMessage = null
                    )
                }
        }
    }
}

data class CatalogPickerState(
    val kind: CatalogKind,
    val query: String = "",
    val items: List<CatalogItem> = emptyList(),
    val errorMessage: String? = null
)
