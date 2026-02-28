package com.snapvet.domain.model

import kotlin.time.Instant

enum class CatalogKind {
    PROCEDURE,
    PROTOCOL
}

enum class CatalogSource {
    SEEDED,
    CUSTOM
}

data class CatalogItem(
    val id: String,
    val kind: CatalogKind,
    val code: String,
    val displayName: String,
    val sortOrder: Int,
    val isActive: Boolean,
    val source: CatalogSource,
    val updatedAt: Instant
)
