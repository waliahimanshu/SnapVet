package com.snapvet.domain.util

interface IdGenerator {
    fun nextId(): String
}

class RandomIdGenerator : IdGenerator {
    override fun nextId(): String {
        val now = currentTimeMillis()
        val random = kotlin.random.Random.nextLong().toString().removePrefix("-")
        return "$now-$random"
    }
}
