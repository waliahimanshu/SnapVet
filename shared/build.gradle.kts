import org.jetbrains.kotlin.gradle.plugin.mpp.apple.XCFramework
import co.touchlab.skie.configuration.FunctionInterop

plugins {
    alias(libs.plugins.kotlinMultiplatform)
    alias(libs.plugins.androidLibrary)
    alias(libs.plugins.composeMultiplatform)
    alias(libs.plugins.composeCompiler)
    alias(libs.plugins.sqldelight)
    alias(libs.plugins.skie)
}

kotlin {
    jvmToolchain(17)

    androidTarget()
    
    val xcf = XCFramework("Shared")

    listOf(
        iosArm64(),
        iosSimulatorArm64()
    ).forEach { iosTarget ->
        iosTarget.binaries.framework {
            baseName = "Shared"
            isStatic = true
            freeCompilerArgs += listOf("-Xbinary=bundleId=com.snapvet.shared")
            xcf.add(this)
        }
    }
    
    jvm()
    
    js {
        browser()
    }
    
    sourceSets {
        androidMain.dependencies {
            implementation(libs.sqldelight.android.driver)
            implementation(libs.compose.uiToolingPreview)
        }
        commonMain.dependencies {
            implementation(libs.compose.runtime)
            implementation(libs.compose.foundation)
            implementation(libs.compose.material3)
            implementation(libs.compose.ui)
            implementation(libs.compose.components.resources)
            implementation(libs.compose.uiToolingPreview)
            implementation(libs.kotlinx.coroutines.core)
            implementation(libs.kotlinx.datetime)
            implementation(libs.kotlinx.serialization.json)
            implementation(libs.sqldelight.runtime)
            implementation(libs.sqldelight.coroutines.extensions)
        }
        iosMain.dependencies {
            implementation(libs.sqldelight.native.driver)
        }
        jvmMain.dependencies {
            implementation(libs.sqldelight.sqlite.driver)
        }
        commonTest.dependencies {
            implementation(libs.kotlin.test)
        }
    }
}

android {
    namespace = "org.waliahimanshu.snapvet.shared"
    compileSdk = libs.versions.android.compileSdk.get().toInt()
    compileOptions {
        sourceCompatibility = JavaVersion.VERSION_11
        targetCompatibility = JavaVersion.VERSION_11
    }
    defaultConfig {
        minSdk = libs.versions.android.minSdk.get().toInt()
    }
}

dependencies {
    debugImplementation(libs.compose.uiTooling)
}

sqldelight {
    databases {
        create("SnapVetDatabase") {
            packageName.set("com.snapvet.db")
            version = 2
            schemaOutputDirectory.set(file("sqldelight/schema"))
            verifyMigrations.set(true)
        }
    }
}

skie {
    features {
        // Avoid generating Swift wrappers for Compose ui.unit interface/global extensions
        // (e.g., toSp) that collide in Swift naming.
        group("androidx.compose.ui.unit") {
            FunctionInterop.FileScopeConversion.Enabled(false)
        }
    }
}
