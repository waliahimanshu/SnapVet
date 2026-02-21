package com.snapvet.viewmodel

import com.snapvet.domain.model.VitalRecord
import com.snapvet.domain.model.VitalsInput
import com.snapvet.domain.usecase.GetLatestVitalRecordUsecase
import com.snapvet.domain.usecase.SaveVitalsUsecase
import com.snapvet.domain.util.TimeProvider
import kotlinx.coroutines.CoroutineScope
import kotlinx.coroutines.delay
import kotlinx.coroutines.flow.MutableStateFlow
import kotlinx.coroutines.flow.StateFlow
import kotlinx.coroutines.flow.asStateFlow
import kotlinx.coroutines.launch
import kotlin.time.Duration.Companion.minutes

class MonitoringViewModel(
    private val caseId: String,
    private val caseStartTimeMillis: Long,
    private val saveVitalsUsecase: SaveVitalsUsecase,
    private val getLatestVitalRecordUsecase: GetLatestVitalRecordUsecase,
    private val timeProvider: TimeProvider,
    scope: CoroutineScope? = null
) : BaseViewModel(scope) {

    private val _state = MutableStateFlow(MonitoringState())
    val state: StateFlow<MonitoringState> = _state.asStateFlow()

    init {
        refreshLatest()
        startTicker()
    }

    fun updateVitals(input: VitalsInput) {
        _state.value = _state.value.copy(currentVitals = input)
    }

    fun save() {
        val current = _state.value
        _state.value = current.copy(isSaving = true, errorMessage = null)

        scope.launch {
            runCatching {
                saveVitalsUsecase(caseId, current.currentVitals)
            }.onSuccess { saved ->
                _state.value = current.copy(
                    isSaving = false,
                    lastSaved = saved,
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

    fun refreshLatest() {
        scope.launch {
            val latest = getLatestVitalRecordUsecase(caseId)
            _state.value = _state.value.copy(lastSaved = latest)
        }
    }

    private fun startTicker() {
        scope.launch {
            while (true) {
                val now = timeProvider.now().toEpochMilliseconds()
                val elapsedSeconds = ((now - caseStartTimeMillis).coerceAtLeast(0L)) / 1000L
                val lastSavedMillis = _state.value.lastSaved?.timestamp?.toEpochMilliseconds()
                val sinceLastSave = lastSavedMillis?.let { (now - it).coerceAtLeast(0L) / 1000L }
                _state.value = _state.value.copy(
                    elapsedSeconds = elapsedSeconds,
                    secondsSinceLastSave = sinceLastSave
                )
                delay(1_000)
            }
        }
    }
}

data class MonitoringState(
    val currentVitals: VitalsInput = VitalsInput(
        hr = null,
        rr = null,
        spo2 = null,
        etco2 = null,
        bpSys = null,
        bpDia = null,
        bpMap = null,
        temp = null,
        sevoIso = null,
        o2Flow = null,
        ecg = null,
        crt = null,
        mucousMembrane = null,
        notes = null
    ),
    val lastSaved: VitalRecord? = null,
    val isSaving: Boolean = false,
    val errorMessage: String? = null,
    val elapsedSeconds: Long = 0L,
    val secondsSinceLastSave: Long? = null
) {
    val shouldNudgeSave: Boolean
        get() = secondsSinceLastSave != null && secondsSinceLastSave >= 5.minutes.inWholeSeconds
}
