package com.snapvet.data.repository

import app.cash.sqldelight.coroutines.asFlow
import app.cash.sqldelight.coroutines.mapToList
import com.snapvet.data.local.toDomain
import com.snapvet.db.SnapVetDatabase
import com.snapvet.domain.model.CatalogItem
import com.snapvet.domain.model.CatalogKind
import kotlinx.coroutines.CoroutineDispatcher
import kotlinx.coroutines.Dispatchers
import kotlinx.coroutines.flow.Flow
import kotlinx.coroutines.flow.map
import kotlinx.coroutines.withContext
import kotlin.time.Instant

class CatalogRepositoryImpl(
    private val database: SnapVetDatabase,
    private val dispatcher: CoroutineDispatcher = Dispatchers.Default
) : CatalogRepository {
    private val queries = database.snapVetQueries

    override suspend fun upsertSeeded(items: List<CatalogItem>) {
        withContext(dispatcher) {
            items.forEach { item ->
                upsert(item)
            }
        }
    }

    override suspend fun upsertCustom(item: CatalogItem) {
        withContext(dispatcher) {
            upsert(item)
        }
    }

    override suspend fun deactivateMissingSeeded(codes: Set<String>, updatedAt: Instant) {
        withContext(dispatcher) {
            if (codes.isEmpty()) {
                queries.deactivateAllSeededCatalogItems(updated_at = updatedAt.toEpochMilliseconds())
                return@withContext
            }
            queries.deactivateMissingSeededCatalogItems(
                updated_at = updatedAt.toEpochMilliseconds(),
                code = codes.toList()
            )
        }
    }

    override fun observeActive(kind: CatalogKind, query: String): Flow<List<CatalogItem>> {
        val normalizedQuery = normalizeSearchText(query)
        val sqlQuery = if (normalizedQuery.isBlank()) {
            queries.selectActiveCatalogItems(kind = kind.name)
        } else {
            queries.selectActiveCatalogItemsBySearch(kind = kind.name, value_ = normalizedQuery)
        }
        return sqlQuery
            .asFlow()
            .mapToList(dispatcher)
            .map { rows -> rows.map { it.toDomain() } }
    }

    private fun normalizeSearchText(value: String): String {
        return value.trim()
            .lowercase()
            .replace("\\s+".toRegex(), " ")
    }

    private fun upsert(item: CatalogItem) {
        queries.upsertCatalogItem(
            id = item.id,
            kind = item.kind.name,
            code = item.code,
            display_name = item.displayName,
            search_text = normalizeSearchText(item.displayName),
            sort_order = item.sortOrder.toLong(),
            is_active = if (item.isActive) 1 else 0,
            source = item.source.name,
            updated_at = item.updatedAt.toEpochMilliseconds()
        )
    }
}
