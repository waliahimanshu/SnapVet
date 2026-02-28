package com.snapvet.domain.usecase

import com.snapvet.data.repository.CatalogRepository
import com.snapvet.domain.model.CatalogItem
import com.snapvet.domain.model.CatalogKind
import com.snapvet.domain.model.CatalogSource
import com.snapvet.domain.util.TimeProvider
import kotlinx.coroutines.Dispatchers
import kotlinx.coroutines.withContext
import kotlinx.serialization.json.Json
import kotlinx.serialization.json.jsonArray
import kotlinx.serialization.json.jsonObject
import kotlinx.serialization.json.jsonPrimitive

class SyncCatalogFromSeedUsecase(
    private val catalogRepository: CatalogRepository,
    private val timeProvider: TimeProvider
) {
    suspend operator fun invoke(seedJson: String): Int {
        val parsed = withContext(Dispatchers.Default) {
            parseSeedItems(seedJson)
        }
        return invoke(parsed)
    }

    suspend operator fun invoke(seedItems: List<CatalogSeedInput>): Int {
        val now = timeProvider.now()
        val normalized = withContext(Dispatchers.Default) {
            seedItems
                .mapNotNull { input ->
                    val displayName = input.displayName.trim()
                    val code = input.code.trim().lowercase()
                    if (displayName.isBlank()) return@mapNotNull null
                    if (code.isBlank()) return@mapNotNull null
                    CatalogItem(
                        id = input.id.trim().ifBlank { code },
                        kind = input.kind,
                        code = code,
                        displayName = displayName,
                        sortOrder = input.sortOrder,
                        isActive = true,
                        source = CatalogSource.SEEDED,
                        updatedAt = now
                    )
                }
                .distinctBy { it.code }
        }

        catalogRepository.upsertSeeded(normalized)
        catalogRepository.deactivateMissingSeeded(
            codes = normalized.mapTo(mutableSetOf()) { it.code },
            updatedAt = now
        )

        return normalized.size
    }

    private fun parseSeedItems(seedJson: String): List<CatalogSeedInput> {
        val root = Json.parseToJsonElement(seedJson).jsonObject
        val items = root["items"]?.jsonArray ?: return emptyList()
        return items.mapNotNull { node ->
            val json = node.jsonObject
            val kindRaw = json["kind"]?.jsonPrimitive?.content?.trim()?.uppercase() ?: return@mapNotNull null
            val kind = runCatching { CatalogKind.valueOf(kindRaw) }.getOrNull() ?: return@mapNotNull null

            val code = json["code"]?.jsonPrimitive?.content?.trim().orEmpty()
            val displayName = json["displayName"]?.jsonPrimitive?.content?.trim().orEmpty()
            if (code.isBlank() || displayName.isBlank()) return@mapNotNull null

            val id = json["id"]?.jsonPrimitive?.content?.trim().orEmpty().ifBlank { code }
            val sortOrder = json["sortOrder"]?.jsonPrimitive?.content?.toIntOrNull() ?: 0

            CatalogSeedInput(
                id = id,
                kind = kind,
                code = code,
                displayName = displayName,
                sortOrder = sortOrder
            )
        }
    }
}

data class CatalogSeedInput(
    val id: String,
    val kind: CatalogKind,
    val code: String,
    val displayName: String,
    val sortOrder: Int = 0
)
