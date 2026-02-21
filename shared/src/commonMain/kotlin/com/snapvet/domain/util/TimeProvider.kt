package com.snapvet.domain.util

import kotlin.time.Instant

interface TimeProvider {
    fun now(): Instant
}

class SystemTimeProvider : TimeProvider {
    override fun now(): Instant = Instant.fromEpochMilliseconds(currentTimeMillis())
}
