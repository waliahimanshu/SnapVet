# CLAUDE.md

This file mirrors `AGENTS.md`. If you update rules, keep both in sync.

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## Project Overview

SnapVet is an offline-first veterinary anesthesia monitoring app for iPad and Android tablets, built with Kotlin Multiplatform. It records vital parameters during surgery with fast, tap-based data entry optimized for gloved hands. Currently in early development — design system components exist but core app screens and business logic are not yet implemented.

## Build & Run Commands

```bash
# Android
./gradlew :composeApp:assembleDebug

# Desktop (JVM)
./gradlew :composeApp:run

# Server (Ktor)
./gradlew :server:run

# Web (Wasm - modern browsers)
./gradlew :composeApp:wasmJsBrowserDevelopmentRun

# Web (JS - older browsers)
./gradlew :composeApp:jsBrowserDevelopmentRun

# iOS - open iosApp/ directory in Xcode and run from there

# Tests
./gradlew :shared:allTests           # Shared module tests (all platforms)
./gradlew :shared:jvmTest            # Shared module JVM tests only
./gradlew :composeApp:allTests       # ComposeApp tests
./gradlew :server:test               # Server tests
```

## iOS Release Automation

- iOS release uses a two-step GitHub Actions pipeline: TestFlight upload first, then a separate manual App Store submission workflow.
- Full setup, secrets, and operating steps are documented in `docs/ios-release-pipeline.md`.
- Keep this section mirrored across `AGENTS.md` and `CLAUDE.md` when release automation changes.

## Architecture

### Module Structure

- **`shared/`** — Kotlin Multiplatform library (Android + iOS + JVM + JS + WasmJS). Contains the design system and will contain domain models, database, repositories, use cases, and ViewModels. Produces an iOS framework named "Shared" (static).
- **`composeApp/`** — Compose Multiplatform application (Android + Desktop + Web). Depends on `shared`. Contains the UI layer using Compose. Currently has a placeholder `App.kt`.
- **`server/`** — Ktor server application (JVM only). Depends on `shared`. Runs on Netty.
- **`iosApp/`** — Native SwiftUI iOS application. Imports the `Shared` framework from the shared module. Contains its own parallel implementation of design system components in Swift.

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

Color values are defined in hex in `SnapVetColors` (Compose) and must match the RGB equivalents in `Color+Extension.swift` (SwiftUI). The prefix convention is `snapvet` for SwiftUI color extensions.

### Package Structure

- Shared Kotlin: `org.waliahimanshu.snapvet` (platform, greeting, constants) and `com.snapvet.design.*` (design system)
- Android/ComposeApp: `org.waliahimanshu.snapvet`
- Server: `org.waliahimanshu.snapvet`

### Planned Architecture (not yet implemented)

The README describes the target architecture for MVP1:
- **data/local/** — SQLDelight database
- **data/repository/** — Repository pattern
- **domain/model/** — Data models (Case, VitalRecord, enums like Species, ECGReading, MucousMembraneReading)
- **domain/usecase/** — Use cases (StartCase, SaveVitals, EndAnesthesia, etc.)
- **viewmodel/** — Shared KMP ViewModels
- **DI** — Koin
- **iOS interop** — SKIE for Kotlin-to-Swift bridging

## Key Technical Details

- Kotlin 2.3.0, Compose Multiplatform 1.10.0, Ktor 3.3.3
- JVM target: 11
- Android: minSdk 24, targetSdk 36, compileSdk 36
- iOS targets: iosArm64, iosSimulatorArm64
- Gradle configuration cache and build cache enabled
- The app uses a dark medical-grade UI theme (dark blue-gray backgrounds with medical green accents)
- Always dark theme — `SnapVetTheme` ignores light/dark toggle and always uses `DarkColorScheme`
- Compose Hot Reload plugin is enabled for the composeApp module

## Save Mechanism — Manual Save Button (IMPORTANT)

The save flow has two distinct steps:
1. **Tile-level edit:** Vet taps a tile → keypad/slider/chip selector opens → enters value → taps **Save on the keypad** → this only updates the on-screen working copy (no database write)
2. **Row-level commit:** Vet taps the **"Save" button** in the bottom bar → ALL current tile values are committed as one timestamped `VitalRecord` row

Each tile shows the **previous saved value greyed out** (top-right corner, `TextTertiary` color) so the vet can see what changed since the last commit. The previous value is only shown when it differs from the current working value.

Tile values are "sticky" — once entered, they persist on screen until manually changed. Unchanged values carry forward into each new record. This means every saved row has ALL 12+ parameter values, not just the ones that changed.

The bottom bar shows: **Save button** (green, prominent) + **save status** ("Saved 2m ago") + **"End Anesthesia"** button. A 5-minute nudge highlights the Save button and/or tile borders when it's time to record.

## Design Conventions

- Touch targets: minimum 44x44pt (iOS) / 48x48dp (Android) — optimized for gloved hands
- Landscape-first tablet layout; grid adapts per device size (4x3 iPad, 2x6 smaller tablets)
- Parameter tiles use `ParameterStatus` (NORMAL/WARNING/ALERT) to drive border and value colors
- Numeric input uses a custom `NumericKeypad` component (not system keyboard)
- Bounded numeric values (e.g., SpO₂ 80-100) should also offer slider input (TODO: not yet implemented)
- Non-numeric parameters (ECG, CRT, Mucous Membrane) use `ChipSelector`
- Notes tile supports free text input OR quick tags

## Preview Convention

Each component file contains its own `@Preview` (Compose) or `#Preview` (SwiftUI) functions at the bottom — do not create separate preview files. Kotlin previews use `// region Previews` / `// endregion` markers. Swift previews use `// MARK: - Previews`.
