package com.snapvet.data.repository

class InMemoryRepositoryProvider : RepositoryProvider {
    private val caseRepository = InMemoryCaseRepository()
    private val vitalRecordRepository = InMemoryVitalRecordRepository()
    private val catalogRepository = InMemoryCatalogRepository()

    override fun caseRepository(): CaseRepository = caseRepository

    override fun vitalRecordRepository(): VitalRecordRepository = vitalRecordRepository

    override fun catalogRepository(): CatalogRepository = catalogRepository
}
