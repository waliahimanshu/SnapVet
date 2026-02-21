package com.snapvet.data.repository

import com.snapvet.domain.model.VitalRecord
import kotlinx.coroutines.flow.Flow
import kotlinx.coroutines.flow.MutableStateFlow
import kotlinx.coroutines.flow.map

class InMemoryVitalRecordRepository : VitalRecordRepository {
    private val records = MutableStateFlow<List<VitalRecord>>(emptyList())

    override suspend fun insertRecord(record: VitalRecord) {
        records.value = records.value + record
    }

    override suspend fun getLatestRecord(caseId: String): VitalRecord? {
        return records.value
            .filter { it.caseId == caseId }
            .maxByOrNull { it.timestamp }
    }

    override fun observeRecords(caseId: String): Flow<List<VitalRecord>> {
        return records.map { list ->
            list.filter { it.caseId == caseId }.sortedByDescending { it.timestamp }
        }
    }
}
