package com.snapvet.domain.model

enum class Species { DOG, CAT }

enum class CaseStatus { ACTIVE, COMPLETED }

enum class ECGReading {
    NSR,
    SINUS_BRADY,
    SINUS_TACHY,
    VPCS,
    ATRIAL_FIB,
    ASYSTOLE,
    OTHER
}

enum class CRTReading {
    LESS_THAN_1_SEC,
    BETWEEN_1_AND_2_SEC,
    BETWEEN_2_AND_3_SEC,
    GREATER_THAN_3_SEC
}

enum class MucousMembraneReading {
    PINK,
    PALE,
    BLUE,
    INJECTED,
    ICTERIC
}

enum class PulseQuality {
    STRONG,
    MODERATE,
    WEAK,
    ABSENT
}
