package org.waliahimanshu.snapvet

import androidx.compose.ui.window.Window
import androidx.compose.ui.window.application
import com.snapvet.data.repository.InMemoryRepositoryProvider

fun main() = application {
    Window(
        onCloseRequest = ::exitApplication,
        title = "SnapVet",
    ) {
        App(provider = InMemoryRepositoryProvider())
    }
}
