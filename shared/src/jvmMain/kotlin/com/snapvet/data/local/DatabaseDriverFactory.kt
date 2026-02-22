package com.snapvet.data.local

import app.cash.sqldelight.db.SqlDriver
import app.cash.sqldelight.driver.jdbc.sqlite.JdbcSqliteDriver
import com.snapvet.db.SnapVetDatabase
import java.io.File

actual class DatabaseDriverFactory {
    actual fun createDriver(): SqlDriver {
        val databaseFile = File("snapvet.db")
        return JdbcSqliteDriver(url = "jdbc:sqlite:${databaseFile.absolutePath}").also { driver ->
            if (!databaseFile.exists()) {
                SnapVetDatabase.Schema.create(driver)
            }
        }
    }
}
