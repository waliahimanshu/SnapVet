package org.waliahimanshu.snapvet

import com.snapvet.data.local.DatabaseDriverFactory
import com.snapvet.data.local.DatabaseFactory
import com.snapvet.data.repository.RepositoryProvider
import com.snapvet.data.repository.SqlDelightRepositoryProvider
import com.snapvet.domain.usecase.EndAnesthesiaUsecase
import com.snapvet.domain.usecase.GetLatestVitalRecordUsecase
import com.snapvet.domain.usecase.ObserveCaseListUsecase
import com.snapvet.domain.usecase.ObserveVitalRecordsUsecase
import com.snapvet.domain.usecase.SaveVitalsUsecase
import com.snapvet.domain.usecase.StartCaseUsecase
import com.snapvet.domain.util.IdGenerator
import com.snapvet.domain.util.RandomIdGenerator
import com.snapvet.domain.util.SystemTimeProvider
import com.snapvet.domain.util.TimeProvider
import org.koin.androidx.viewmodel.dsl.viewModel
import org.koin.dsl.module

val appModule = module {
    single { DatabaseDriverFactory(get()) }
    single { DatabaseFactory(get()).create() }
    single<RepositoryProvider> { SqlDelightRepositoryProvider(get()) }

    single<IdGenerator> { RandomIdGenerator() }
    single<TimeProvider> { SystemTimeProvider() }

    factory { ObserveCaseListUsecase(get<RepositoryProvider>().caseRepository()) }
    factory { StartCaseUsecase(get<RepositoryProvider>().caseRepository(), get(), get()) }
    factory { SaveVitalsUsecase(get<RepositoryProvider>().vitalRecordRepository(), get(), get()) }
    factory { GetLatestVitalRecordUsecase(get<RepositoryProvider>().vitalRecordRepository()) }
    factory { ObserveVitalRecordsUsecase(get<RepositoryProvider>().vitalRecordRepository()) }
    factory { EndAnesthesiaUsecase(get<RepositoryProvider>().caseRepository(), get()) }

    viewModel {
        AppStateViewModel(
            observeCaseListUsecase = get(),
            startCaseUsecase = get(),
            saveVitalsUsecase = get(),
            getLatestVitalRecordUsecase = get(),
            observeVitalRecordsUsecase = get(),
            endAnesthesiaUsecase = get(),
            timeProvider = get()
        )
    }
}
