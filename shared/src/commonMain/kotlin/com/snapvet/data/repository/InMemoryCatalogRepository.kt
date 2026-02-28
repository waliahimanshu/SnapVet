package com.snapvet.data.repository

import com.snapvet.domain.model.CatalogItem
import com.snapvet.domain.model.CatalogKind
import com.snapvet.domain.model.CatalogSource
import kotlinx.coroutines.flow.Flow
import kotlinx.coroutines.flow.MutableStateFlow
import kotlinx.coroutines.flow.map
import kotlin.time.Instant

class InMemoryCatalogRepository : CatalogRepository {
    private val items = MutableStateFlow<List<CatalogItem>>(emptyList())

    override suspend fun upsertSeeded(items: List<CatalogItem>) {
        val byCode = this.items.value.associateBy { it.code }.toMutableMap()
        items.forEach { item ->
            byCode[item.code] = item
        }
        this.items.value = byCode.values.toList()
    }

    override suspend fun deactivateMissingSeeded(codes: Set<String>, updatedAt: Instant) {
        val codeSet = codes.toSet()
        items.value = items.value.map { item ->
            if (item.source == CatalogSource.SEEDED && item.code !in codeSet) {
                item.copy(isActive = false, updatedAt = updatedAt)
            } else {
                item
            }
        }
    }

    override fun observeActive(kind: CatalogKind, query: String): Flow<List<CatalogItem>> {
        val normalizedQuery = normalizeSearchText(query)
        return items.map { source ->
            source
                .asSequence()
                .filter { it.kind == kind && it.isActive }
                .filter {
                    normalizedQuery.isBlank() ||
                        normalizeSearchText(it.displayName).contains(normalizedQuery)
                }
                .sortedWith(compareBy<CatalogItem> { it.sortOrder }.thenBy { it.displayName.lowercase() })
                .toList()
        }
    }

    private fun normalizeSearchText(value: String): String {
        return value.trim()
            .lowercase()
            .replace("\\s+".toRegex(), " ")
    }
}
