package com.snapvet.data.repository

import app.cash.sqldelight.coroutines.asFlow
import app.cash.sqldelight.coroutines.mapToList
import com.snapvet.data.local.toDomain
import com.snapvet.db.SnapVetDatabase
import com.snapvet.domain.model.VitalRecord
import kotlinx.coroutines.CoroutineDispatcher
import kotlinx.coroutines.Dispatchers
import kotlinx.coroutines.flow.Flow
import kotlinx.coroutines.flow.map

class VitalRecordRepositoryImpl(
    private val database: SnapVetDatabase,
    private val dispatcher: CoroutineDispatcher = Dispatchers.Default
) : VitalRecordRepository {
    private val queries = database.snapVetQueries

    override suspend fun insertRecord(record: VitalRecord) {
        queries.insertVitalRecord(
            id = record.id,
            case_id = record.caseId,
            timestamp = record.timestamp.toEpochMilliseconds(),
            hr = record.hr?.toLong(),
            rr = record.rr?.toLong(),
            spo2 = record.spo2?.toLong(),
            etco2 = record.etco2?.toLong(),
            bp_sys = record.bpSys?.toLong(),
            bp_dia = record.bpDia?.toLong(),
            bp_map = record.bpMap?.toLong(),
            temp = record.temp,
            sevo_iso = record.sevoIso,
            o2_flow = record.o2Flow,
            ecg = record.ecg?.name,
            crt = record.crt?.name,
            mucous_membrane = record.mucousMembrane?.name,
            notes = record.notes
        )
    }

    override suspend fun getLatestRecord(caseId: String): VitalRecord? {
        return queries.selectLatestVitalRecordForCase(caseId).executeAsOneOrNull()?.toDomain()
    }

    override fun observeRecords(caseId: String): Flow<List<VitalRecord>> {
        return queries.selectVitalRecordsForCase(caseId)
            .asFlow()
            .mapToList(dispatcher)
            .map { rows -> rows.map { it.toDomain() } }
    }
}
