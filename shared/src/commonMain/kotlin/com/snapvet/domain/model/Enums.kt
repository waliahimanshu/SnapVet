package com.snapvet.domain.model

enum class Species { DOG, CAT }

enum class CaseStatus { ACTIVE, COMPLETED }

enum class ECGReading {
    NSR,
    SINUS_BRADY,
    SINUS_TACHY,
    VPCS,
    ATRIAL_FIB
}

enum class CRTReading {
    LESS_THAN_2_SEC,
    GREATER_THAN_2_SEC
}

enum class MucousMembraneReading {
    PINK,
    PALE,
    BLUE,
    GREY,
    MUDDY
}
