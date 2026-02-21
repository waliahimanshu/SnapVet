package com.snapvet.domain.usecase

import com.snapvet.data.repository.CaseRepository
import com.snapvet.domain.model.Case
import com.snapvet.domain.model.CaseStatus
import com.snapvet.domain.model.Species
import com.snapvet.domain.util.IdGenerator
import com.snapvet.domain.util.TimeProvider

class StartCaseUsecase(
    private val caseRepository: CaseRepository,
    private val idGenerator: IdGenerator,
    private val timeProvider: TimeProvider
) {
    suspend operator fun invoke(input: StartCaseInput): Case {
        val case = Case(
            id = idGenerator.nextId(),
            patientName = input.patientName,
            species = input.species,
            weight = input.weight,
            procedure = input.procedure,
            anestheticProtocol = input.anestheticProtocol,
            startTime = timeProvider.now(),
            endTime = null,
            status = CaseStatus.ACTIVE
        )
        caseRepository.insertCase(case)
        return case
    }
}

data class StartCaseInput(
    val patientName: String,
    val species: Species,
    val weight: Double,
    val procedure: String,
    val anestheticProtocol: String
)
