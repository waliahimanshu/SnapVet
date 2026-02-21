package com.snapvet.data.repository

import com.snapvet.db.SnapVetDatabase

class SqlDelightRepositoryProvider(
    private val database: SnapVetDatabase
) : RepositoryProvider {
    private val caseRepository by lazy { CaseRepositoryImpl(database) }
    private val vitalRecordRepository by lazy { VitalRecordRepositoryImpl(database) }

    override fun caseRepository(): CaseRepository = caseRepository

    override fun vitalRecordRepository(): VitalRecordRepository = vitalRecordRepository
}
