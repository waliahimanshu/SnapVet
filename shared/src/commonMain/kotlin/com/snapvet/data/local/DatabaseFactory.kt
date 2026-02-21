package com.snapvet.data.local

import com.snapvet.db.SnapVetDatabase

class DatabaseFactory(
    private val driverFactory: DatabaseDriverFactory
) {
    fun create(): SnapVetDatabase = SnapVetDatabase(driverFactory.createDriver())
}
