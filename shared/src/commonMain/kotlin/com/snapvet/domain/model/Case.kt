package com.snapvet.domain.model

import kotlin.time.Instant

data class Case(
    val id: String,
    val patientName: String,
    val species: Species,
    val weight: Double,
    val procedure: String,
    val anestheticProtocol: String,
    val startTime: Instant,
    val endTime: Instant?,
    val status: CaseStatus
)
