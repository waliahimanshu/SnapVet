# SnapVet - Veterinary Anesthesia Monitor

Offline-first anesthesia monitoring app for iOS (iPad + iPhone) and Android tablets, built with Kotlin Multiplatform. Vets tap parameter tiles during surgery, save timestamped vital records, and export professional PDFs.

## Setup

**Prerequisites:** macOS, Xcode (latest stable), Android Studio (latest stable), JDK 17+

```bash
git clone https://github.com/waliahimanshu/SnapVet.git
cd SnapVet

# iOS — open in Xcode and run
open iosApp/iosApp.xcodeproj

# Android
./gradlew :composeApp:assembleDebug

# Shared module tests
./gradlew :shared:allTests
```

## Architecture

```
shared/  (Kotlin Multiplatform — domain, data, ViewModels)
├── domain/model/       Data models (Case, VitalRecord, enums)
├── domain/usecase/     Use cases (StartCase, SaveVitals, EndAnesthesia, ...)
├── data/repository/    SQLDelight + InMemory repositories
├── data/local/         SQLDelight database, mappers
├── viewmodel/          Shared ViewModels consumed by both platforms
└── design/             Compose design system (theme, components)

iosApp/  (SwiftUI — native iOS UI)
├── Views/              4 screens: CaseList, CaseSetup, Monitoring, RecordTable
└── Design/             SwiftUI design system (colors, fonts, components)

composeApp/  (Compose Multiplatform — Android + Desktop + Web UI)
server/      (Ktor — JVM server)
```

## Tech Stack

Kotlin 2.3.0 | SQLDelight | SKIE | SwiftUI | Compose Multiplatform 1.10.0 | Ktor 3.3.3

## Documentation

See [CLAUDE.md](./CLAUDE.md) for architecture details, product requirements, and contributor guidelines.

## License

TBD
