# AGENTS.md

This file mirrors `CLAUDE.md`. If you update rules, keep both in sync.

This file provides guidance to AI coding agents when working with code in this repository.

## Project Overview

SnapVet is an offline-first veterinary anesthesia monitoring app built with Kotlin Multiplatform. It records vital parameters during surgery with fast, tap-based data entry optimized for gloved hands. The MVP1 core is functional: 4 screens, 6 use cases, dual design system (Compose + SwiftUI), SQLDelight + InMemory repositories, and 4 shared ViewModels are all implemented.

**Primary focus going forward: iOS (iPhone + iPad).** Shared domain logic stays cross-platform (KMP). Android/Desktop/Web/Server exist but are secondary.

## Build & Run Commands

```bash
# iOS — open in Xcode and run from there
open iosApp/iosApp.xcodeproj

# Shared module tests (all platforms)
./gradlew :shared:allTests
./gradlew :shared:jvmTest            # JVM tests only

# Android
./gradlew :composeApp:assembleDebug

# Desktop (JVM)
./gradlew :composeApp:run

# Server (Ktor)
./gradlew :server:run

# Web (Wasm)
./gradlew :composeApp:wasmJsBrowserDevelopmentRun

# Web (JS)
./gradlew :composeApp:jsBrowserDevelopmentRun

# ComposeApp tests
./gradlew :composeApp:allTests

# Server tests
./gradlew :server:test
```

## iOS Release Automation

- iOS release uses a two-step GitHub Actions pipeline: TestFlight upload first, then a separate manual App Store submission workflow.
- Full setup, secrets, and operating steps are documented in `docs/ios-release-pipeline.md`.
- TestFlight upload workflow: `.github/workflows/ios-testflight.yml` (trigger: tag `ios/v*` or manual dispatch).
- App Store submission workflow: `.github/workflows/ios-appstore-submit.yml` (manual only; requires `app_version` + `build_number` inputs).
- Versioning rule: bump `MARKETING_VERSION` manually when starting a new release line; CI build number is auto-derived from `GITHUB_RUN_NUMBER` in `fastlane beta`.
- Export compliance: if app uses only Apple/system encryption (no custom/proprietary crypto), set `ITSAppUsesNonExemptEncryption=false` in `iosApp/iosApp/Info.plist` and choose "None of the algorithms mentioned above" in App Store Connect when prompted.
- App icon requirement for upload: `iosApp/iosApp/Assets.xcassets/AppIcon.appiconset` must include required iPhone/iPad slots plus `ios-marketing` 1024x1024, and app metadata must include `CFBundleIconName=AppIcon`.
- Xcode/signing reliability: keep one active Xcode selected via `xcode-select`, avoid mixed toolchains during archive/export, and ensure the selected team has permission to create/use App Store provisioning profiles.
- Keep this section mirrored across `AGENTS.md` and `CLAUDE.md` when release automation changes.

## Architecture

### Module Structure

- **`shared/`** — Kotlin Multiplatform library (Android + iOS + JVM + JS + WasmJS). Contains domain models, use cases, repositories (SQLDelight + InMemory), ViewModels, database layer, and the Compose design system. Produces an iOS framework named "Shared" (static).
- **`iosApp/`** — Native SwiftUI iOS application. Imports the `Shared` framework. Contains 4 screens (CaseList, CaseSetup, Monitoring, RecordTable), SwiftUI design system components, and ViewModel wrappers that bridge KMP ViewModels to SwiftUI's `@Published`/`@ObservedObject` pattern.
- **`composeApp/`** — Compose Multiplatform application (Android + Desktop + Web). Depends on `shared`. Contains the UI layer using Compose.
- **`server/`** — Ktor server application (JVM only). Depends on `shared`. Runs on Netty.

### Architecture Guidelines

- **Naming**: All use case classes must end with `Usecase` (e.g., `StartCaseUsecase`). All repository interfaces/impls must end with `Repository` (e.g., `CaseRepository`, `CaseRepositoryImpl`).
- **Package structure**: Keep clear vertical slices for future modularization.
  - `com.snapvet.domain.model` — domain models and enums
  - `com.snapvet.domain.usecase` — use cases (pure business logic)
  - `com.snapvet.domain.util` — domain utilities (IDs, time)
  - `com.snapvet.data.local` — database + mappers
  - `com.snapvet.data.repository` — repository interfaces + implementations
  - `com.snapvet.data.remote` — API interfaces and DTOs
  - `com.snapvet.viewmodel` — shared ViewModels
- **OOP + Clean code**: Apply SRP, DRY, interface segregation, and abstraction. Use constructor injection for dependencies. Keep business logic testable and side-effect-free where possible.
- **Separation of concerns**: ViewModels orchestrate use cases; use cases call repositories; repositories handle data sources; mappers isolate DB/DTO conversions.
- **Unidirectional data flow**: UI → ViewModel intents → use cases → repositories → state updates via `StateFlow`/`Flow`.
- **Compose/Multiplatform best practices**: Keep UI stateless where possible, pass state down and events up, avoid side effects in composables, and use stable state holders. Keep platform UI specifics out of shared business logic.

### Package Structure

- Shared Kotlin domain/data: `com.snapvet.domain.*`, `com.snapvet.data.*`, `com.snapvet.viewmodel`
- Shared Kotlin design system: `com.snapvet.design.*`
- Shared Kotlin platform/utils: `org.waliahimanshu.snapvet`
- Android/ComposeApp: `org.waliahimanshu.snapvet`
- Server: `org.waliahimanshu.snapvet`

### Database Migration Guidelines (SQLDelight)

- **No Room-style JSON auto-migrations**: SQLDelight uses explicit SQL migrations.
- **Versioning**: Bump `sqldelight { databases { ... version = X } }` for each schema change.
- **Migration files**: Add `shared/src/commonMain/sqldelight/com/snapvet/db/X.sqm` (e.g., `2.sqm`) with SQL to migrate from version `X-1` to `X`.
- **Schema snapshots**: Run `./gradlew :shared:generateSqlDelightSchema` to update schema files in `shared/sqldelight/schema/`.
- **Verification**: Keep `verifyMigrations = true` enabled so builds fail if migrations are missing or incorrect.

### Dual Design System (Compose + SwiftUI) — CRITICAL

Because the project uses native UI (Compose for Android, SwiftUI for iOS) rather than full Compose Multiplatform UI, every design component exists twice and must stay synchronized. When modifying a component, always update both the Compose and SwiftUI versions together:

| Compose (shared)                                         | SwiftUI (iosApp)                                  |
|----------------------------------------------------------|---------------------------------------------------|
| `com.snapvet.design.theme.SnapVetColors`                 | `Color+Extension.swift` (Color extensions)        |
| `com.snapvet.design.theme.SnapVetTypography`             | `Font+Extension.swift`                            |
| `com.snapvet.design.theme.SnapVetTheme`                  | N/A (SwiftUI uses color/font extensions directly) |
| `com.snapvet.design.theme.DarkColorScheme`               | N/A (maps SnapVetColors to Material3 dark scheme) |
| `com.snapvet.design.component.parameter.ParameterTile`   | `ParameterTileView.swift`                         |
| `com.snapvet.design.component.input.NumericKeypad`       | `NumericKeypadView.swift`                         |
| `com.snapvet.design.ChipSelector`                        | `ChipSelectorView.swift`                          |
| `com.snapvet.design.component.parameter.ParameterStatus` | `ParameterStatus` enum in ParameterTileView.swift |
| `com.snapvet.design.component.PatientInfoBar`            | `PatientInfoBarView.swift`                        |

Color values are defined in hex in `SnapVetColors` (Compose) and must match the RGB equivalents in `Color+Extension.swift` (SwiftUI). The prefix convention is `snapvet` for SwiftUI color extensions.

## Product Requirements

### The Golden Rule: Tap → Edit → Save Row

> **Make anesthetic monitoring fast, tap-based, and interruption-proof, then automatically turn entries into a clean table. No typing. No scrolling spreadsheets. Just tap → save → done.**

### Save Mechanism — Manual Save Button (IMPORTANT)

The save flow has two distinct steps:
1. **Tile-level edit:** Vet taps a tile → keypad/slider/chip selector opens → enters value → taps **Save on the keypad** → this only updates the on-screen working copy (no database write)
2. **Row-level commit:** Vet taps the **"Save" button** in the bottom bar → ALL current tile values are committed as one timestamped `VitalRecord` row

Each tile shows the **previous saved value greyed out** (top-right corner, `TextTertiary` color) so the vet can see what changed since the last commit. The previous value is only shown when it differs from the current working value.

Tile values are "sticky" — once entered, they persist on screen until manually changed. Unchanged values carry forward into each new record. This means every saved row has ALL 12+ parameter values, not just the ones that changed.

The bottom bar shows: **Save button** (green, prominent) + **save status** ("Saved 2m ago") + **"End Anesthesia"** button. A 5-minute nudge highlights the Save button and/or tile borders when it's time to record.

### Session Management

- Start: "Start Anesthesia" button → timer begins
- Duration: Variable (20 minutes to 2+ hours)
- End: "End Anesthesia" button → stops timer, marks case complete
- No pause/resume functionality
- One active case at a time

### Data Recording

- Recording trigger: Manual **Save button** in bottom bar
- What gets saved: ALL parameter values (every tile) + auto-timestamp
- 5-minute nudge: Visual reminder (Save button and/or tile borders highlight), no audio
- Missed intervals: Just save when you can — no backfill option

### Input Methods

- **Numeric tiles** (HR, RR, SpO2, EtCO2, BP, Temp, Sevo%, O2 Flow): System keyboard is the primary input method; custom `NumericKeypad` component is kept as an available option
- **Bounded numeric tiles** (e.g., SpO2 80-100): Should also offer slider input as alternative (TODO: not yet implemented)
- **Non-numeric tiles** (ECG, CRT, Mucous Membrane): Tap → chip selector
- **BP tile**: Special — shows SYS/DIA/MAP, user fills what they have (partial entry OK)
- **Notes tile**: Free text input OR quick tags

### Screens

1. **Case List (Home)** — List of past cases (patient name, date, species, status). "New Case" button.
2. **Case Setup** — Form: patient name, species (Dog/Cat), weight, procedure, anesthetic protocol. "Start Anesthesia" button.
3. **Monitoring Screen** (core experience — 90% of vet's time) — Patient info header with elapsed timer, 4x3 parameter tile grid (14 tiles: HR, RR, SpO2, EtCO2, BP Sys/Dia/Map, Temp, Sevo/Iso, O2 Flow, ECG, CRT, Mucous Membrane, Notes), bottom bar with Save + End Anesthesia.
4. **Record Table** — Scrollable table of saved vital records with timestamps. Export PDF button.

### Data Models

```kotlin
data class Case(
    val id: String, val patientName: String, val species: Species,
    val weight: Double, val procedure: String, val anestheticProtocol: String,
    val startTime: Instant, val endTime: Instant?, val status: CaseStatus
)

data class VitalRecord(
    val id: String, val caseId: String, val timestamp: Instant,
    val hr: Int?, val rr: Int?, val spo2: Int?, val etco2: Int?,
    val bpSys: Int?, val bpDia: Int?, val bpMap: Int?,
    val temp: Double?, val sevoIso: Double?, val o2Flow: Double?,
    val ecg: ECGReading?, val crt: CRTReading?,
    val mucousMembrane: MucousMembraneReading?, val notes: String?
)

enum class Species { DOG, CAT }
enum class CaseStatus { ACTIVE, COMPLETED }
enum class ECGReading { NSR, SINUS_BRADY, SINUS_TACHY, VPCS, ATRIAL_FIB }
enum class CRTReading { LESS_THAN_2_SEC, GREATER_THAN_2_SEC }
enum class MucousMembraneReading { PINK, PALE, BLUE, GREY, MUDDY }
```

### MVP1 Scope Summary

- Single user, single device, no login required
- Dogs & Cats only
- Full offline functionality with local data persistence
- PDF export with email/share (PRIORITY output)
- No drug logging (MVP2), no cloud sync (MVP2), no user accounts (MVP2)

## Current State & TODOs

### What Works

- All 4 screens implemented in SwiftUI (CaseList, CaseSetup, Monitoring, RecordTable)
- 6 use cases: StartCaseUsecase, SaveVitalsUsecase, EndAnesthesiaUsecase, GetLatestVitalRecordUsecase, ObserveCaseListUsecase, ObserveVitalRecordsUsecase
- 4 shared ViewModels: CaseListViewModel, CaseSetupViewModel, MonitoringViewModel, RecordTableViewModel (+ BaseViewModel)
- SQLDelight database schema with cases + vital_records tables
- Both SQLDelight and InMemory repository implementations
- Dual design system (Compose + SwiftUI) with synchronized colors, typography, and components
- ViewModel wrappers bridging KMP → SwiftUI (`SharedViewModels.swift`)
- 5-minute save nudge logic in MonitoringViewModel
- DI via constructor injection in AppState.swift (no Koin)

### Known Issues & TODOs

- **PDF export not built** — critical MVP1 feature, needs platform-specific implementation (UIGraphicsPDFRenderer on iOS, Android PdfDocument API)
- **iOS uses InMemoryRepositoryProvider** — SQLDelight provider exists but iOS is wired to in-memory storage in `AppState.swift`
- **Tests are minimal** — only a placeholder test (1 + 2 = 3) in `SharedCommonTest.kt`
- **Battery level hardcoded to 68%** in `MonitoringScreen.swift`
- **Slider input for bounded values** (e.g., SpO2 80-100) not yet implemented
- **No Koin DI** — currently using manual constructor injection; Koin was planned but not set up

## Design Conventions

- Touch targets: minimum 44x44pt (iOS) / 48x48dp (Android) — optimized for gloved hands
- Landscape-first tablet layout; grid adapts per device size (4x3 iPad, 2x6 smaller tablets)
- Parameter tiles use `ParameterStatus` (NORMAL/WARNING/ALERT) to drive border and value colors
- System keyboard is the primary numeric input; custom `NumericKeypad` component is available as an option
- Non-numeric parameters (ECG, CRT, Mucous Membrane) use `ChipSelector`
- Notes tile supports free text input OR quick tags
- The app uses a dark medical-grade UI theme (dark blue-gray backgrounds with medical green accents)
- Always dark theme — `SnapVetTheme` ignores light/dark toggle and always uses `DarkColorScheme`

## iOS SwiftUI Compile Guardrails (Learnings)

- `NumericKeypadView` `currentValue` must always be a `Binding<String>`. If the source is computed (`bpFieldValue(...)`), wrap with `Binding(get:set:)` instead of passing a plain `String`.
- For numeric-only BP input (SAP/DAP/MAP), disable decimal entry at keypad level (`showsDecimalKey: false`) and keep values as integer strings.
- Keep type alignment explicit between Swift and KMP bridge types:
  - UI formatting helpers should use `Int?` when passing `KotlinInt?.intValue`.
  - KMP model fields still receive `KotlinInt?` through conversion helpers (`kotlinInt(...)`) at update boundaries.
- If a function expects `Int32?`, do not pass `Int?` directly. Either change the function to `Int?` for UI-only formatting or cast intentionally at the boundary.
- Prefer handling numeric conversions in one place (update/apply functions) to avoid repeated `Int`/`Int32` mismatch errors across views.

## Key Technical Details

- Kotlin 2.3.0, Compose Multiplatform 1.10.0, Ktor 3.3.3
- JVM target: 11
- Android: minSdk 24, targetSdk 36, compileSdk 36
- iOS targets: iosArm64, iosSimulatorArm64
- Gradle configuration cache and build cache enabled
- Compose Hot Reload plugin is enabled for the composeApp module

## Preview Convention

Each component file contains its own `@Preview` (Compose) or `#Preview` (SwiftUI) functions at the bottom — do not create separate preview files. Kotlin previews use `// region Previews` / `// endregion` markers. Swift previews use `// MARK: - Previews`.
