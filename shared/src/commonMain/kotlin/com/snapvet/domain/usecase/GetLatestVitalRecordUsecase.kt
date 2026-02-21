package com.snapvet.domain.usecase

import com.snapvet.data.repository.VitalRecordRepository
import com.snapvet.domain.model.VitalRecord

class GetLatestVitalRecordUsecase(
    private val vitalRecordRepository: VitalRecordRepository
) {
    suspend operator fun invoke(caseId: String): VitalRecord? {
        return vitalRecordRepository.getLatestRecord(caseId)
    }
}
