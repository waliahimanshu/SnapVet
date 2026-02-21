package com.snapvet.domain.usecase

import com.snapvet.data.repository.VitalRecordRepository
import com.snapvet.domain.model.VitalRecord
import com.snapvet.domain.model.VitalsInput
import com.snapvet.domain.util.IdGenerator
import com.snapvet.domain.util.TimeProvider

class SaveVitalsUsecase(
    private val vitalRecordRepository: VitalRecordRepository,
    private val idGenerator: IdGenerator,
    private val timeProvider: TimeProvider
) {
    suspend operator fun invoke(caseId: String, input: VitalsInput): VitalRecord {
        val record = VitalRecord(
            id = idGenerator.nextId(),
            caseId = caseId,
            timestamp = timeProvider.now(),
            hr = input.hr,
            rr = input.rr,
            spo2 = input.spo2,
            etco2 = input.etco2,
            bpSys = input.bpSys,
            bpDia = input.bpDia,
            bpMap = input.bpMap,
            temp = input.temp,
            sevoIso = input.sevoIso,
            o2Flow = input.o2Flow,
            ecg = input.ecg,
            crt = input.crt,
            mucousMembrane = input.mucousMembrane,
            notes = input.notes
        )
        vitalRecordRepository.insertRecord(record)
        return record
    }
}
