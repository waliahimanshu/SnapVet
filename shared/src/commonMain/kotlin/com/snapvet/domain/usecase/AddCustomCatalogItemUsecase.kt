package com.snapvet.domain.usecase

import com.snapvet.data.repository.CatalogRepository
import com.snapvet.domain.model.CatalogItem
import com.snapvet.domain.model.CatalogKind
import com.snapvet.domain.model.CatalogSource
import com.snapvet.domain.util.IdGenerator
import com.snapvet.domain.util.TimeProvider

class AddCustomCatalogItemUsecase(
    private val catalogRepository: CatalogRepository,
    private val idGenerator: IdGenerator,
    private val timeProvider: TimeProvider
) {
    suspend operator fun invoke(kind: CatalogKind, displayName: String): CatalogItem {
        val normalizedName = displayName.trim().replace("\\s+".toRegex(), " ")
        val item = CatalogItem(
            id = "custom-${idGenerator.nextId()}",
            kind = kind,
            code = "custom-${idGenerator.nextId()}",
            displayName = normalizedName,
            sortOrder = 9_999,
            isActive = true,
            source = CatalogSource.CUSTOM,
            updatedAt = timeProvider.now()
        )
        catalogRepository.upsertCustom(item)
        return item
    }
}
