package org.waliahimanshu.snapvet

import androidx.compose.runtime.getValue
import androidx.compose.runtime.mutableStateOf
import androidx.compose.runtime.setValue
import androidx.lifecycle.ViewModel
import androidx.lifecycle.viewModelScope
import com.snapvet.domain.model.Case
import com.snapvet.domain.usecase.EndAnesthesiaUsecase
import com.snapvet.domain.usecase.GetLatestVitalRecordUsecase
import com.snapvet.domain.usecase.ObserveCaseListUsecase
import com.snapvet.domain.usecase.ObserveVitalRecordsUsecase
import com.snapvet.domain.usecase.SaveVitalsUsecase
import com.snapvet.domain.usecase.StartCaseUsecase
import com.snapvet.domain.util.TimeProvider
import com.snapvet.viewmodel.CaseListViewModel
import com.snapvet.viewmodel.CaseSetupViewModel
import com.snapvet.viewmodel.MonitoringViewModel
import com.snapvet.viewmodel.RecordTableViewModel
import kotlinx.coroutines.launch

class AppStateViewModel(
    private val observeCaseListUsecase: ObserveCaseListUsecase,
    private val startCaseUsecase: StartCaseUsecase,
    private val saveVitalsUsecase: SaveVitalsUsecase,
    private val getLatestVitalRecordUsecase: GetLatestVitalRecordUsecase,
    private val observeVitalRecordsUsecase: ObserveVitalRecordsUsecase,
    private val endAnesthesiaUsecase: EndAnesthesiaUsecase,
    private val timeProvider: TimeProvider
) : ViewModel() {

    val caseListViewModel = CaseListViewModel(observeCaseListUsecase, viewModelScope)
    val caseSetupViewModel = CaseSetupViewModel(startCaseUsecase, viewModelScope)

    var monitoringViewModel by mutableStateOf<MonitoringViewModel?>(null)
        private set
    var recordTableViewModel by mutableStateOf<RecordTableViewModel?>(null)
        private set

    var selectedTab by mutableStateOf(AppTab.Setup)
        private set

    private var activeCaseId: String? = null
    var activeCase by mutableStateOf<Case?>(null)
        private set

    init {
        caseListViewModel.observe(status = null)
    }

    fun startSession(case: Case) {
        activeCaseId = case.id
        activeCase = case
        monitoringViewModel = MonitoringViewModel(
            caseId = case.id,
            caseStartTimeMillis = case.startTime.toEpochMilliseconds(),
            saveVitalsUsecase = saveVitalsUsecase,
            getLatestVitalRecordUsecase = getLatestVitalRecordUsecase,
            timeProvider = timeProvider,
            scope = viewModelScope
        )
        recordTableViewModel = RecordTableViewModel(
            caseId = case.id,
            observeVitalRecordsUsecase = observeVitalRecordsUsecase,
            scope = viewModelScope
        ).also { it.observe() }
        selectedTab = AppTab.Monitoring
    }

    fun endSession() {
        val caseId = activeCaseId ?: return
        viewModelScope.launch {
            endAnesthesiaUsecase(caseId)
        }
        selectedTab = AppTab.Records
    }

    fun selectTab(tab: AppTab) {
        selectedTab = tab
    }
}
