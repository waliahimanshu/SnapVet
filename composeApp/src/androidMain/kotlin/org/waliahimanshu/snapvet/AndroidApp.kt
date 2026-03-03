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
import androidx.compose.ui.Modifier
import org.koin.androidx.compose.koinViewModel
import com.snapvet.design.theme.SnapVetColors
import com.snapvet.design.theme.SnapVetTheme
import org.waliahimanshu.snapvet.ui.CaseListScreen
import org.waliahimanshu.snapvet.ui.CaseSetupScreen
import org.waliahimanshu.snapvet.ui.MonitoringScreen
import org.waliahimanshu.snapvet.ui.RecordTableScreen

@Composable
fun AndroidApp() {
    val appState: AppStateViewModel = koinViewModel()

    SnapVetTheme {
        Scaffold(
            containerColor = SnapVetColors.PrimaryBg,
            bottomBar = {
                NavigationBar(containerColor = SnapVetColors.HeaderBg) {
                    AppTab.entries.forEach { tab ->
                        NavigationBarItem(
                            selected = appState.selectedTab == tab,
                            onClick = { appState.selectTab(tab) },
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
                when (appState.selectedTab) {
                    AppTab.Cases -> CaseListScreen(viewModel = appState.caseListViewModel)
                    AppTab.Setup -> CaseSetupScreen(
                        viewModel = appState.caseSetupViewModel,
                        onCaseCreated = { case -> appState.startSession(case) }
                    )
                    AppTab.Monitoring -> appState.monitoringViewModel?.let { viewModel ->
                        val caseInfo = appState.activeCase
                        MonitoringScreen(
                            viewModel = viewModel,
                            patientName = caseInfo?.patientName.orEmpty(),
                            species = caseInfo?.species?.let { if (it == com.snapvet.domain.model.Species.DOG) "Canine" else "Feline" }.orEmpty(),
                            weight = caseInfo?.weight?.toString().orEmpty(),
                            onEndSession = appState::endSession
                        )
                    }
                    AppTab.Records -> appState.recordTableViewModel?.let { viewModel ->
                        RecordTableScreen(viewModel = viewModel)
                    }
                }
            }
        }
    }
}
