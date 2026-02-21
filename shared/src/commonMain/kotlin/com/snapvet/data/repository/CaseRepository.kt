package com.snapvet.data.repository

import com.snapvet.domain.model.Case
import com.snapvet.domain.model.CaseStatus
import kotlinx.coroutines.flow.Flow
import kotlin.time.Instant

interface CaseRepository {
    suspend fun insertCase(case: Case)
    suspend fun getCaseById(id: String): Case?
    fun observeCases(status: CaseStatus? = null): Flow<List<Case>>
    suspend fun updateCaseStatus(id: String, status: CaseStatus, endTime: Instant?)
    suspend fun deleteCase(id: String)
}
