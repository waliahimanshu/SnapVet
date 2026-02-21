package com.snapvet.domain.usecase

import com.snapvet.data.repository.CaseRepository
import com.snapvet.domain.model.CaseStatus
import com.snapvet.domain.util.TimeProvider

class EndAnesthesiaUsecase(
    private val caseRepository: CaseRepository,
    private val timeProvider: TimeProvider
) {
    suspend operator fun invoke(caseId: String) {
        caseRepository.updateCaseStatus(
            id = caseId,
            status = CaseStatus.COMPLETED,
            endTime = timeProvider.now()
        )
    }
}
