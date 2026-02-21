package com.snapvet.viewmodel

import kotlinx.coroutines.CoroutineScope
import kotlinx.coroutines.Dispatchers
import kotlinx.coroutines.SupervisorJob
import kotlinx.coroutines.cancel

open class BaseViewModel(
    private val externalScope: CoroutineScope? = null
) {
    protected val scope: CoroutineScope = externalScope
        ?: CoroutineScope(SupervisorJob() + Dispatchers.Default)

    open fun clear() {
        if (externalScope == null) {
            scope.cancel()
        }
    }
}
