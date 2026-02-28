package com.snapvet.data.repository

import com.snapvet.domain.model.CatalogItem
import com.snapvet.domain.model.CatalogKind
import kotlinx.coroutines.flow.Flow
import kotlin.time.Instant

interface CatalogRepository {
    suspend fun upsertSeeded(items: List<CatalogItem>)
    suspend fun deactivateMissingSeeded(codes: Set<String>, updatedAt: Instant)
    fun observeActive(kind: CatalogKind, query: String): Flow<List<CatalogItem>>
}
