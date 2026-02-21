package com.snapvet.domain.usecase

import com.snapvet.data.repository.CaseRepository
import com.snapvet.domain.model.Case
import com.snapvet.domain.model.CaseStatus
import kotlinx.coroutines.flow.Flow

class ObserveCaseListUsecase(
    private val caseRepository: CaseRepository
) {
    operator fun invoke(status: CaseStatus? = null): Flow<List<Case>> {
        return caseRepository.observeCases(status)
    }
}
