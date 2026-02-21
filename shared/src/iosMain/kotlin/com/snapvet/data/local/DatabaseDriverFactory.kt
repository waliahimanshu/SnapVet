package com.snapvet.data.local

import app.cash.sqldelight.db.SqlDriver
import app.cash.sqldelight.driver.native.NativeSqliteDriver
import com.snapvet.db.SnapVetDatabase

actual class DatabaseDriverFactory {
    actual fun createDriver(): SqlDriver {
        return NativeSqliteDriver(SnapVetDatabase.Schema, "snapvet.db")
    }
}
