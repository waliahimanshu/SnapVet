package com.snapvet.domain.model

import kotlin.time.Instant

data class VitalRecord(
    val id: String,
    val caseId: String,
    val timestamp: Instant,
    val hr: Int?,
    val rr: Int?,
    val spo2: Int?,
    val etco2: Int?,
    val bpSys: Int?,
    val bpDia: Int?,
    val bpMap: Int?,
    val temp: Double?,
    val sevoIso: Double?,
    val o2Flow: Double?,
    val fluids: Double?,
    val ecg: ECGReading?,
    val ecgOtherText: String?,
    val crt: CRTReading?,
    val pulseQuality: PulseQuality?,
    val mucousMembrane: MucousMembraneReading?,
    val notes: String?
)

// Input for SaveVitals use case (id/timestamp are generated).
data class VitalsInput(
    val hr: Int?,
    val rr: Int?,
    val spo2: Int?,
    val etco2: Int?,
    val bpSys: Int?,
    val bpDia: Int?,
    val bpMap: Int?,
    val temp: Double?,
    val sevoIso: Double?,
    val o2Flow: Double?,
    val fluids: Double?,
    val ecg: ECGReading?,
    val ecgOtherText: String?,
    val crt: CRTReading?,
    val pulseQuality: PulseQuality?,
    val mucousMembrane: MucousMembraneReading?,
    val notes: String?
)
