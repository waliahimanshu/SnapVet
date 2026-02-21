package com.snapvet.domain.usecase

import com.snapvet.data.repository.VitalRecordRepository
import com.snapvet.domain.model.VitalRecord
import kotlinx.coroutines.flow.Flow

class ObserveVitalRecordsUsecase(
    private val vitalRecordRepository: VitalRecordRepository
) {
    operator fun invoke(caseId: String): Flow<List<VitalRecord>> {
        return vitalRecordRepository.observeRecords(caseId)
    }
}
