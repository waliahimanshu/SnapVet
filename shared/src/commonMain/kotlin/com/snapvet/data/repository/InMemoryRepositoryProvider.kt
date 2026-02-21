package com.snapvet.data.repository

class InMemoryRepositoryProvider : RepositoryProvider {
    private val caseRepository = InMemoryCaseRepository()
    private val vitalRecordRepository = InMemoryVitalRecordRepository()

    override fun caseRepository(): CaseRepository = caseRepository

    override fun vitalRecordRepository(): VitalRecordRepository = vitalRecordRepository
}
