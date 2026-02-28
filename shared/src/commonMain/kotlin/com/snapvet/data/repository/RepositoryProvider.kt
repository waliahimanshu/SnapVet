package com.snapvet.data.repository

interface RepositoryProvider {
    fun caseRepository(): CaseRepository
    fun vitalRecordRepository(): VitalRecordRepository
    fun catalogRepository(): CatalogRepository
}
