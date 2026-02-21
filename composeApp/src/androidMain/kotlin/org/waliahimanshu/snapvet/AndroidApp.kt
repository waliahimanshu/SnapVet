package org.waliahimanshu.snapvet

import androidx.compose.runtime.Composable
import androidx.compose.runtime.remember
import androidx.compose.ui.platform.LocalContext
import com.snapvet.data.local.DatabaseDriverFactory
import com.snapvet.data.local.DatabaseFactory
import com.snapvet.data.repository.InMemoryRepositoryProvider
import com.snapvet.data.repository.RepositoryProvider
import com.snapvet.data.repository.SqlDelightRepositoryProvider

@Composable
fun AndroidApp(useInMemory: Boolean = false) {
    val context = LocalContext.current
    val provider: RepositoryProvider = remember(useInMemory) {
        if (useInMemory) {
            InMemoryRepositoryProvider()
        } else {
            val driverFactory = DatabaseDriverFactory(context)
            val database = DatabaseFactory(driverFactory).create()
            SqlDelightRepositoryProvider(database)
        }
    }

    App(provider = provider)
}
