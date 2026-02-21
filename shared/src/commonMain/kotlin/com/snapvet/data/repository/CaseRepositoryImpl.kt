package com.snapvet.data.repository

import com.snapvet.data.local.toDomain
import com.snapvet.db.SnapVetDatabase
import com.snapvet.domain.model.Case
import com.snapvet.domain.model.CaseStatus
import kotlinx.coroutines.CoroutineDispatcher
import kotlinx.coroutines.Dispatchers
import kotlinx.coroutines.flow.Flow
import kotlinx.coroutines.flow.map
import kotlin.time.Instant
import app.cash.sqldelight.coroutines.asFlow
import app.cash.sqldelight.coroutines.mapToList

class CaseRepositoryImpl(
    private val database: SnapVetDatabase,
    private val dispatcher: CoroutineDispatcher = Dispatchers.Default
) : CaseRepository {
    private val queries = database.snapVetQueries

    override suspend fun insertCase(case: Case) {
        queries.insertCase(
            id = case.id,
            patient_name = case.patientName,
            species = case.species.name,
            weight = case.weight,
            procedure = case.procedure,
            anesthetic_protocol = case.anestheticProtocol,
            start_time = case.startTime.toEpochMilliseconds(),
            end_time = case.endTime?.toEpochMilliseconds(),
            status = case.status.name
        )
    }

    override suspend fun getCaseById(id: String): Case? {
        return queries.selectCaseById(id).executeAsOneOrNull()?.toDomain()
    }

    override fun observeCases(status: CaseStatus?): Flow<List<Case>> {
        val query = if (status == null) {
            queries.selectAllCases()
        } else {
            queries.selectCasesByStatus(status.name)
        }
        return query
            .asFlow()
            .mapToList(dispatcher)
            .map { rows -> rows.map { it.toDomain() } }
    }

    override suspend fun updateCaseStatus(id: String, status: CaseStatus, endTime: Instant?) {
        queries.updateCaseStatus(status = status.name, end_time = endTime?.toEpochMilliseconds(), id = id)
    }
}
