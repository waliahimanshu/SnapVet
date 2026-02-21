package com.snapvet.data.repository

import com.snapvet.domain.model.Case
import com.snapvet.domain.model.CaseStatus
import kotlinx.coroutines.flow.Flow
import kotlinx.coroutines.flow.MutableStateFlow
import kotlinx.coroutines.flow.map
import kotlin.time.Instant

class InMemoryCaseRepository : CaseRepository {
    private val cases = MutableStateFlow<List<Case>>(emptyList())

    override suspend fun insertCase(case: Case) {
        cases.value = cases.value.filterNot { it.id == case.id } + case
    }

    override suspend fun getCaseById(id: String): Case? {
        return cases.value.firstOrNull { it.id == id }
    }

    override fun observeCases(status: CaseStatus?): Flow<List<Case>> {
        return cases.map { list ->
            when (status) {
                null -> list.sortedByDescending { it.startTime }
                else -> list.filter { it.status == status }.sortedByDescending { it.startTime }
            }
        }
    }

    override suspend fun updateCaseStatus(id: String, status: CaseStatus, endTime: Instant?) {
        cases.value = cases.value.map { existing ->
            if (existing.id == id) {
                existing.copy(status = status, endTime = endTime)
            } else {
                existing
            }
        }
    }

    override suspend fun deleteCase(id: String) {
        cases.value = cases.value.filterNot { it.id == id }
    }
}
