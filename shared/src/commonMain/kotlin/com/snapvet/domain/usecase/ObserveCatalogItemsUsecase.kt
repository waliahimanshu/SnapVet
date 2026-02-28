package com.snapvet.domain.usecase

import com.snapvet.data.repository.CatalogRepository
import com.snapvet.domain.model.CatalogItem
import com.snapvet.domain.model.CatalogKind
import kotlinx.coroutines.flow.Flow

class ObserveCatalogItemsUsecase(
    private val catalogRepository: CatalogRepository
) {
    operator fun invoke(kind: CatalogKind, query: String): Flow<List<CatalogItem>> {
        return catalogRepository.observeActive(kind = kind, query = query)
    }
}
