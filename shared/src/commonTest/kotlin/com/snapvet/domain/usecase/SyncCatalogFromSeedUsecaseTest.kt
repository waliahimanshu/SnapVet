package com.snapvet.domain.usecase

import com.snapvet.data.repository.InMemoryCatalogRepository
import com.snapvet.domain.model.CatalogKind
import com.snapvet.domain.util.TimeProvider
import kotlinx.coroutines.flow.first
import kotlinx.coroutines.runBlocking
import kotlin.test.Test
import kotlin.test.assertEquals
import kotlin.time.Instant

class SyncCatalogFromSeedUsecaseTest {

    @Test
    fun syncCatalogFromSeed_insertsProcedureItems() = runBlocking {
        val repository = InMemoryCatalogRepository()
        val usecase = SyncCatalogFromSeedUsecase(
            catalogRepository = repository,
            timeProvider = FakeTimeProvider()
        )

        val inserted = usecase(
            """
            {
              "items": [
                { "id": "proc_spay", "kind": "PROCEDURE", "code": "spay", "displayName": "Spay", "sortOrder": 20 },
                { "id": "proc_dental", "kind": "PROCEDURE", "code": "dental", "displayName": "Dental", "sortOrder": 10 }
              ]
            }
            """.trimIndent()
        )

        val procedures = repository.observeActive(CatalogKind.PROCEDURE, query = "").first()

        assertEquals(2, inserted)
        assertEquals(listOf("Dental", "Spay"), procedures.map { it.displayName })
    }

    @Test
    fun syncCatalogFromSeed_deactivatesMissingSeededItems() = runBlocking {
        val repository = InMemoryCatalogRepository()
        val usecase = SyncCatalogFromSeedUsecase(
            catalogRepository = repository,
            timeProvider = FakeTimeProvider()
        )

        usecase(
            """
            {
              "items": [
                { "id": "proc_spay", "kind": "PROCEDURE", "code": "spay", "displayName": "Spay", "sortOrder": 10 },
                { "id": "proc_dental", "kind": "PROCEDURE", "code": "dental", "displayName": "Dental", "sortOrder": 20 }
              ]
            }
            """.trimIndent()
        )
        usecase(
            """
            {
              "items": [
                { "id": "proc_spay", "kind": "PROCEDURE", "code": "spay", "displayName": "Spay", "sortOrder": 10 }
              ]
            }
            """.trimIndent()
        )

        val procedures = repository.observeActive(CatalogKind.PROCEDURE, query = "").first()
        assertEquals(listOf("Spay"), procedures.map { it.displayName })
    }

    @Test
    fun observeCatalogItems_filtersByQueryCaseInsensitively() = runBlocking {
        val repository = InMemoryCatalogRepository()
        val syncUsecase = SyncCatalogFromSeedUsecase(
            catalogRepository = repository,
            timeProvider = FakeTimeProvider()
        )
        val observeUsecase = ObserveCatalogItemsUsecase(repository)

        syncUsecase(
            """
            {
              "items": [
                { "id": "proc_iso", "kind": "PROCEDURE", "code": "isoflurane", "displayName": "Isoflurane", "sortOrder": 10 },
                { "id": "proc_sevo", "kind": "PROCEDURE", "code": "sevoflurane", "displayName": "Sevoflurane", "sortOrder": 20 }
              ]
            }
            """.trimIndent()
        )

        val filtered = observeUsecase(CatalogKind.PROCEDURE, "SEVO").first()
        assertEquals(listOf("Sevoflurane"), filtered.map { it.displayName })
    }
}

private class FakeTimeProvider : TimeProvider {
    override fun now(): Instant = Instant.fromEpochMilliseconds(1_700_000_000_000)
}
