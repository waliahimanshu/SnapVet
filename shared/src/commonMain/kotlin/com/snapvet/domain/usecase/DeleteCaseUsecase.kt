package com.snapvet.domain.usecase

import com.snapvet.data.repository.CaseRepository
import com.snapvet.data.repository.VitalRecordRepository

class DeleteCaseUsecase(
    private val caseRepository: CaseRepository,
    private val vitalRecordRepository: VitalRecordRepository
) {
    suspend operator fun invoke(caseId: String) {
        vitalRecordRepository.deleteRecordsForCase(caseId)
        caseRepository.deleteCase(caseId)
    }
}
