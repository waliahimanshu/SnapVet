package org.waliahimanshu.snapvet

interface Platform {
    val name: String
}

expect fun getPlatform(): Platform


