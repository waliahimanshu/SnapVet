package com.snapvet.data.repository

import com.snapvet.domain.model.VitalRecord
import kotlinx.coroutines.flow.Flow

interface VitalRecordRepository {
    suspend fun insertRecord(record: VitalRecord)
    suspend fun getLatestRecord(caseId: String): VitalRecord?
    fun observeRecords(caseId: String): Flow<List<VitalRecord>>
}
