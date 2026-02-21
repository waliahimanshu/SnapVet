package com.snapvet.domain.util

import kotlinx.datetime.Instant

interface TimeProvider {
    fun now(): Instant
}

class SystemTimeProvider : TimeProvider {
    override fun now(): Instant = Instant.fromEpochMilliseconds(currentTimeMillis())
}
