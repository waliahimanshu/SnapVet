package org.waliahimanshu.snapvet

import androidx.compose.foundation.background
import androidx.compose.foundation.layout.Box
import androidx.compose.foundation.layout.fillMaxSize
import androidx.compose.foundation.layout.padding
import androidx.compose.material3.NavigationBar
import androidx.compose.material3.NavigationBarItem
import androidx.compose.material3.Scaffold
import androidx.compose.material3.Text
import androidx.compose.runtime.Composable
import androidx.compose.runtime.LaunchedEffect
import androidx.compose.runtime.getValue
import androidx.compose.runtime.mutableStateOf
import androidx.compose.runtime.remember
import androidx.compose.runtime.setValue
import androidx.compose.ui.Modifier
import androidx.compose.ui.tooling.preview.Preview
import com.snapvet.data.repository.RepositoryProvider
import com.snapvet.design.theme.SnapVetColors
import com.snapvet.design.theme.SnapVetTheme
import com.snapvet.viewmodel.CaseListViewModel
import com.snapvet.viewmodel.CaseSetupViewModel
import com.snapvet.viewmodel.MonitoringViewModel
import com.snapvet.viewmodel.RecordTableViewModel
import org.waliahimanshu.snapvet.ui.CaseListScreen
import org.waliahimanshu.snapvet.ui.CaseSetupScreen
import org.waliahimanshu.snapvet.ui.MonitoringScreen
import org.waliahimanshu.snapvet.ui.RecordTableScreen

@Composable
fun App(provider: RepositoryProvider) {
    SnapVetTheme {
        val caseListViewModel = remember(provider) {
            CaseListViewModel(
                observeCaseListUsecase = provider.observeCaseListUsecase(),
                scope = null
            )
        }
        val caseSetupViewModel = remember(provider) {
            CaseSetupViewModel(
                startCaseUsecase = provider.startCaseUsecase(),
                scope = null
            )
        }

        var activeCaseId by remember { mutableStateOf<String?>(null) }
        var selectedTab by remember { mutableStateOf(AppTab.Setup) }

        val monitoringViewModel = remember(activeCaseId, provider) {
            activeCaseId?.let {
                MonitoringViewModel(
                    caseId = it,
                    saveVitalsUsecase = provider.saveVitalsUsecase(),
                    getLatestVitalRecordUsecase = provider.getLatestVitalRecordUsecase(),
                    scope = null
                )
            }
        }

        val recordTableViewModel = remember(activeCaseId, provider) {
            activeCaseId?.let {
                RecordTableViewModel(
                    caseId = it,
                    observeVitalRecordsUsecase = provider.observeVitalRecordsUsecase(),
                    scope = null
                )
            }
        }

        LaunchedEffect(caseListViewModel) {
            caseListViewModel.observe(status = null)
        }

        LaunchedEffect(recordTableViewModel) {
            recordTableViewModel?.observe()
        }

        Scaffold(
            containerColor = SnapVetColors.PrimaryBg,
            bottomBar = {
                NavigationBar(containerColor = SnapVetColors.HeaderBg) {
                    AppTab.entries.forEach { tab ->
                        NavigationBarItem(
                            selected = selectedTab == tab,
                            onClick = { selectedTab = tab },
                            label = { Text(tab.title) },
                            icon = {}
                        )
                    }
                }
            }
        ) { padding ->
            Box(
                modifier = Modifier
                    .fillMaxSize()
                    .background(SnapVetColors.PrimaryBg)
                    .padding(padding)
            ) {
                when (selectedTab) {
                    AppTab.Cases -> CaseListScreen(viewModel = caseListViewModel)
                    AppTab.Setup -> CaseSetupScreen(
                        viewModel = caseSetupViewModel,
                        onCaseCreated = { caseId ->
                            activeCaseId = caseId
                            selectedTab = AppTab.Monitoring
                        }
                    )
                    AppTab.Monitoring -> monitoringViewModel?.let { viewModel ->
                        MonitoringScreen(
                            viewModel = viewModel,
                            onEndSession = { selectedTab = AppTab.Records }
                        )
                    }
                    AppTab.Records -> recordTableViewModel?.let { viewModel ->
                        RecordTableScreen(viewModel = viewModel)
                    }
                }
            }
        }
    }
}

enum class AppTab(val title: String) {
    Cases("Cases"),
    Setup("Setup"),
    Monitoring("Monitor"),
    Records("Records")
}

private fun RepositoryProvider.observeCaseListUsecase() =
    com.snapvet.domain.usecase.ObserveCaseListUsecase(caseRepository())

private fun RepositoryProvider.startCaseUsecase() =
    com.snapvet.domain.usecase.StartCaseUsecase(
        caseRepository = caseRepository(),
        idGenerator = com.snapvet.domain.util.RandomIdGenerator(),
        timeProvider = com.snapvet.domain.util.SystemTimeProvider()
    )

private fun RepositoryProvider.saveVitalsUsecase() =
    com.snapvet.domain.usecase.SaveVitalsUsecase(
        vitalRecordRepository = vitalRecordRepository(),
        idGenerator = com.snapvet.domain.util.RandomIdGenerator(),
        timeProvider = com.snapvet.domain.util.SystemTimeProvider()
    )

private fun RepositoryProvider.getLatestVitalRecordUsecase() =
    com.snapvet.domain.usecase.GetLatestVitalRecordUsecase(vitalRecordRepository())

private fun RepositoryProvider.observeVitalRecordsUsecase() =
    com.snapvet.domain.usecase.ObserveVitalRecordsUsecase(vitalRecordRepository())

@Preview
@Composable
private fun AppPreview() {
    App(provider = com.snapvet.data.repository.InMemoryRepositoryProvider())
}
