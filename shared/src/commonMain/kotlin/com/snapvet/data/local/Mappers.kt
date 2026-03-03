package com.snapvet.data.local

import com.snapvet.db.Cases
import com.snapvet.db.Catalog_items
import com.snapvet.db.Vital_records
import com.snapvet.domain.model.CRTReading
import com.snapvet.domain.model.CatalogItem
import com.snapvet.domain.model.CatalogKind
import com.snapvet.domain.model.CatalogSource
import com.snapvet.domain.model.Case
import com.snapvet.domain.model.CaseStatus
import com.snapvet.domain.model.ECGReading
import com.snapvet.domain.model.MucousMembraneReading
import com.snapvet.domain.model.PulseQuality
import com.snapvet.domain.model.Species
import com.snapvet.domain.model.VitalRecord
import kotlin.time.Instant

internal fun Cases.toDomain(): Case {
    return Case(
        id = id,
        patientName = patient_name,
        species = Species.valueOf(species),
        weight = weight,
        procedure = procedure,
        anestheticProtocol = anesthetic_protocol,
        startTime = Instant.fromEpochMilliseconds(start_time),
        endTime = end_time?.let { Instant.fromEpochMilliseconds(it) },
        status = CaseStatus.valueOf(status)
    )
}

internal fun Vital_records.toDomain(): VitalRecord {
    return VitalRecord(
        id = id,
        caseId = case_id,
        timestamp = Instant.fromEpochMilliseconds(timestamp),
        hr = hr?.toInt(),
        rr = rr?.toInt(),
        spo2 = spo2?.toInt(),
        etco2 = etco2?.toInt(),
        bpSys = bp_sys?.toInt(),
        bpDia = bp_dia?.toInt(),
        bpMap = bp_map?.toInt(),
        temp = temp,
        sevoIso = sevo_iso,
        o2Flow = o2_flow,
        fluids = fluids,
        ecg = ecg?.let { runCatching { ECGReading.valueOf(it) }.getOrNull() },
        ecgOtherText = ecg_other_text,
        crt = crt?.let { runCatching { CRTReading.valueOf(it) }.getOrNull() },
        pulseQuality = pulse_quality?.let { runCatching { PulseQuality.valueOf(it) }.getOrNull() },
        mucousMembrane = mucous_membrane?.let { runCatching { MucousMembraneReading.valueOf(it) }.getOrNull() },
        notes = notes
    )
}

internal fun Catalog_items.toDomain(): CatalogItem {
    return CatalogItem(
        id = id,
        kind = CatalogKind.valueOf(kind),
        code = code,
        displayName = display_name,
        sortOrder = sort_order.toInt(),
        isActive = is_active != 0L,
        source = CatalogSource.valueOf(source),
        updatedAt = Instant.fromEpochMilliseconds(updated_at)
    )
}
