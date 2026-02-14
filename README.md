This is a Kotlin Multiplatform project targeting Android, iOS, Web, Desktop (JVM), Server.

* [/composeApp](./composeApp/src) is for code that will be shared across your Compose Multiplatform applications.
  It contains several subfolders:
  - [commonMain](./composeApp/src/commonMain/kotlin) is for code that’s common for all targets.
  - Other folders are for Kotlin code that will be compiled for only the platform indicated in the folder name.
    For example, if you want to use Apple’s CoreCrypto for the iOS part of your Kotlin app,
    the [iosMain](./composeApp/src/iosMain/kotlin) folder would be the right place for such calls.
    Similarly, if you want to edit the Desktop (JVM) specific part, the [jvmMain](./composeApp/src/jvmMain/kotlin)
    folder is the appropriate location.

* [/iosApp](./iosApp/iosApp) contains iOS applications. Even if you’re sharing your UI with Compose Multiplatform,
  you need this entry point for your iOS app. This is also where you should add SwiftUI code for your project.

* [/server](./server/src/main/kotlin) is for the Ktor server application.

* [/shared](./shared/src) is for the code that will be shared between all targets in the project.
  The most important subfolder is [commonMain](./shared/src/commonMain/kotlin). If preferred, you
  can add code to the platform-specific folders here too.

### Build and Run Android Application

To build and run the development version of the Android app, use the run configuration from the run widget
in your IDE’s toolbar or build it directly from the terminal:
- on macOS/Linux
  ```shell
  ./gradlew :composeApp:assembleDebug
  ```
- on Windows
  ```shell
  .\gradlew.bat :composeApp:assembleDebug
  ```

### Build and Run Desktop (JVM) Application

To build and run the development version of the desktop app, use the run configuration from the run widget
in your IDE’s toolbar or run it directly from the terminal:
- on macOS/Linux
  ```shell
  ./gradlew :composeApp:run
  ```
- on Windows
  ```shell
  .\gradlew.bat :composeApp:run
  ```

### Build and Run Server

To build and run the development version of the server, use the run configuration from the run widget
in your IDE’s toolbar or run it directly from the terminal:
- on macOS/Linux
  ```shell
  ./gradlew :server:run
  ```
- on Windows
  ```shell
  .\gradlew.bat :server:run
  ```

### Build and Run Web Application

To build and run the development version of the web app, use the run configuration from the run widget
in your IDE's toolbar or run it directly from the terminal:
- for the Wasm target (faster, modern browsers):
  - on macOS/Linux
    ```shell
    ./gradlew :composeApp:wasmJsBrowserDevelopmentRun
    ```
  - on Windows
    ```shell
    .\gradlew.bat :composeApp:wasmJsBrowserDevelopmentRun
    ```
- for the JS target (slower, supports older browsers):
  - on macOS/Linux
    ```shell
    ./gradlew :composeApp:jsBrowserDevelopmentRun
    ```
  - on Windows
    ```shell
    .\gradlew.bat :composeApp:jsBrowserDevelopmentRun
    ```

### Build and Run iOS Application

To build and run the development version of the iOS app, use the run configuration from the run widget
in your IDE’s toolbar or open the [/iosApp](./iosApp) directory in Xcode and run it from there.

---

Learn more about [Kotlin Multiplatform](https://www.jetbrains.com/help/kotlin-multiplatform-dev/get-started.html),
[Compose Multiplatform](https://github.com/JetBrains/compose-multiplatform/#compose-multiplatform),
[Kotlin/Wasm](https://kotl.in/wasm/)…

We would appreciate your feedback on Compose/Web and Kotlin/Wasm in the public Slack channel [#compose-web](https://slack-chats.kotlinlang.org/c/compose-web).
If you face any issues, please report them on [YouTrack](https://youtrack.jetbrains.com/newIssue?project=CMP).


# SnapVet - Veterinary Anesthesia Monitor

> A cross-platform veterinary anesthesia monitoring application for iPad and Android tablets, built with Kotlin Multiplatform.

**Note on Naming:** The repository is named "SnapVet" but mockups show "AnesFlow". The final app name can be decided later - this README uses "SnapVet" for consistency.

---

## 📋 Project Overview

SnapVet is an offline-first anesthesia monitoring app designed for veterinary clinics. It enables veterinarians and technicians to record vital parameters during surgery with a focus on speed, reliability, and ease of use on tablets.

### Core Philosophy
- **Offline-first**: Works perfectly without internet
- **Fast data entry**: Optimized for quick taps during surgery
- **Crash-proof**: Every save persists immediately to local database
- **Native feel**: Platform-specific UI for best user experience

---

## 🎯 Key Decisions & Requirements

### Critical Behaviors (MVP1)
1. **Session Management:**
  - Start: "Start Anesthesia" button → timer begins
  - Duration: Variable (20 minutes to 2+ hours)
  - End: "End Anesthesia" button → stops timer, marks case complete
  - ❌ No pause/resume functionality

2. **Data Recording:**
  - Recording trigger: User taps "Save Entry" whenever ready (ideally every 5 minutes)
  - What gets saved: ALL parameter values (every tile) + auto-timestamp
  - 5-minute nudge: Visual reminder only (header/tile color change), no audio
  - Missed intervals: Just save when you can - no backfill option, no retroactive editing

3. **UI Priorities:**
  - Monitoring screen is THE core experience (spend most dev time here)
  - PDF export is MORE important than table view screen
  - Dark blue medical-grade theme (not bright colors)
  - Optimized for gloved hands on tablets

4. **Scope Boundaries:**
  - ✅ Dogs & Cats only (MVP1)
  - ✅ Single user, single device, no login
  - ✅ One active case at a time
  - ❌ No drug logging (deferred to MVP2)
  - ❌ No cloud sync (deferred to MVP2)

---

## 🏗️ Architecture

### Shared KMP + Native UI Approach

```
shared/ (Kotlin Multiplatform - 70-80% of codebase)
├── data/
│   ├── local/        ← SQLDelight (local database)
│   ├── remote/       ← Ktor client (MVP2 - cloud sync)
│   └── repository/   ← Business logic layer
├── domain/
│   ├── model/        ← Data models, enums
│   └── usecase/      ← Use cases (StartCase, SaveVitals, etc.)
└── viewmodel/        ← Shared ViewModels (KMP-ViewModel)

androidApp/ (Jetpack Compose)
├── ui/screens/       ← Android-specific UI
└── theme/            ← Material Design theme

iosApp/ (SwiftUI)
├── Views/            ← iOS-specific UI
└── Assets/           ← iOS assets
```

### Tech Stack

**Shared Layer (KMP)**
- **UI Framework**: Platform-native (Compose for Android, SwiftUI for iOS)
- **Database**: SQLDelight (true KMP, offline-first)
- **DI**: Koin
- **Navigation**: Voyager (Android) / SwiftUI Navigation (iOS)
- **Date/Time**: kotlinx-datetime
- **ViewModel**: KMP-ViewModel
- **Swift Interop**: SKIE (makes Kotlin → Swift seamless)

**Platform-Specific**
- **Android**: Jetpack Compose, Material 3, Android PdfDocument API
- **iOS**: SwiftUI, UIGraphicsPDFRenderer for PDF

**MVP2 Additions**
- **Backend**: Supabase (Auth + Postgres + Realtime)
- **HTTP Client**: Ktor
- **Sync**: Background sync with local-first approach

---

## 🎨 Design System (Based on Mockups)

### Visual Reference
The app uses a **dark medical-grade UI** optimized for tablet use in surgical environments.

### Color Palette
```
Primary Background:   #2C3E50 (Dark Blue-Gray)
Tile Background:      #34495E (Slightly lighter blue)
Accent Primary:       #27AE60 (Medical Green - for Save/Start buttons)
Accent Alert:         #E74C3C (Coral Red - for abnormal values/alerts)
Text Primary:         #FFFFFF (White)
Text Secondary:       #95A5A6 (Light Gray)
Header Bar:           #1A2332 (Darker Blue)
```

### Component Design

**Parameter Tiles** (4x3 Grid on iPad)
- Rounded corners (8-12px radius)
- Large, readable typography (parameter name 14-16pt, value 32-40pt)
- Dark blue background with subtle shadow
- Tap reveals numeric keypad or chip selector overlay

**Numeric Keypad Overlay**
- Slides in from right (iPad) or bottom (phone)
- Large number buttons (optimized for gloved hands)
- Clear and Save buttons prominent
- Current value displayed at top in large font (60-80pt)

**Non-Numeric Chip Selectors**
- Quick-tap chips for categorical values
- Color-coded (e.g., Pink chip for normal mucous membrane)
- ECG shows waveform graphic + text (NSR, Sinus Brady, etc.)

**Patient Info Bar**
- Top sticky header
- Shows: Patient Name, Weight, Species, Elapsed Timer, Battery indicator
- Always visible during monitoring

**5-Minute Nudge**
- Header bar or tile borders change color (subtle yellow/orange glow)
- No audio alarm (MVP1 - to avoid alarm fatigue)

### Typography
- **Headings**: SF Pro Display (iOS) / Roboto (Android), Bold, 20-24pt
- **Parameter Names**: SF Pro Text / Roboto, Medium, 14-16pt
- **Values**: SF Pro Display / Roboto Mono, Bold, 32-48pt
- **Table**: SF Mono / Roboto Mono, Regular, 12-14pt

### Tablet Optimization
- Landscape-first design (primary orientation)
- Grid adapts: 4x3 on iPad, 2x6 on smaller tablets, single column on phones
- Minimum touch target: 44x44pt (iOS) / 48x48dp (Android)

---

## 📱 Screen Mockups Reference

### Screen 1: New Case Setup
![New Case Screen](mockups/new-case.png)

**Elements:**
- Back button (top-left)
- Title: "New Case"
- Input fields:
  - Patient Name (text input)
  - Species: Dog | Cat (toggle selector)
  - Weight (kg) (numeric input)
  - Procedure (text input)
  - Anesthetic Protocol (text input)
  - Start Time: Auto-filled (08:23 AM) - editable
- **"Start Anesthesia" button** (large, green, prominent)

**Behavior:**
- Tapping "Start Anesthesia" → saves case → starts timer → navigates to Monitoring Screen

---

### Screen 2: Monitoring Screen (Core Experience)
![Monitoring Screen](mockups/monitoring.png)

**Header Bar:**
- App name/logo: "AnesFlow" (or "SnapVet")
- Patient info: "Bella | 12.4 kg"
- Elapsed timer: "Anesthesia Time: 00:27" (MM:SS or HH:MM)
- Battery indicator

**Parameter Tile Grid (4x3 on iPad):**

| HR<br>85 | RR<br>12 | SpO₂<br>98% | BP<br>115/65 (80) |
|----------|----------|-------------|-------------------|
| **EtCO₂**<br>38 | **Temp**<br>99.1° | **Sevo%**<br>2.0 | **O₂ Flow**<br>1.5 L/min |
| **ECG**<br>🌊 NSR | **CRT**<br>< 2 sec | **Mucous Membrane**<br>🔴 Pink | **Notes** |

**Tile Behaviors:**
- **Numeric tiles** (HR, RR, SpO₂, EtCO₂, Temp, Sevo%, O₂ Flow):
  - Tap → numeric keypad overlay slides in
  - Shows current value at top
  - Large buttons (1-9, 0, backspace)
  - "Clear" button (blue) clears input
  - "Save" button (green) saves value to tile, closes overlay
- **BP tile**: Shows three values (SYS/DIA/MAP) - tap opens keypad for each field
- **ECG tile**: Shows waveform graphic + text label (NSR, Sinus Brady, etc.)
  - Tap → chip selector with rhythm options
- **CRT tile**: Shows current value (< 2 sec or > 2 sec)
  - Tap → 2-option chip selector
- **Mucous Membrane tile**: Shows color-coded chip (Pink, Pale, Blue, etc.)
  - Tap → color chip selector
- **Notes tile**: Tap → opens text input for free-form notes

**Bottom Actions:**
- **"Save Entry" button** (not shown in mockup but mentioned in requirements)
  - Captures all current tile values → timestamp → saves to database
- **"End Anesthesia" button** (not shown but required)
  - Stops timer → marks case as completed → navigate to record table

**5-Minute Nudge:**
- When 5 minutes elapsed since last save:
  - Header bar changes color (subtle orange/yellow glow) OR
  - Tile borders pulse with color
  - No audio alarm

---

### Screen 3: Anesthetic Records Table
![Records Table](mockups/records-table.png)

**Header Bar:**
- Back button
- Title: "Anesthetic Records"
- Menu icon (hamburger) - for export options

**Table Layout:**
- Horizontally scrollable (many columns)
- Columns: Time | HR | RR | SpO₂ | BP SYS | BP DIA | MAP | ECO₂ | Temp | Sevo | O₂ | ECG | CRT | MM
- Rows: One per saved entry, timestamped (08:25, 08:30, 08:35, etc.)
- Empty cells if parameter not recorded (optional for MVP1)

**Actions:**
- **"Export PDF" button** (priority)
  - Generates PDF with patient info header + table
  - Opens share sheet (email, drive, messages, etc.)
- **"View PDF" button** (optional)
  - Preview before sharing

**Notes:**
- Table view is nice-to-have - PDF export is the critical feature
- Can be simplified if needed - focus on PDF quality

---

## 🎯 MVP1 - Offline-First Local App

### Scope
Single user, single device, no login required. Full offline functionality with local data persistence.

### Features
- ✅ Create new anesthesia cases (patient info, species, weight, procedure)
- ✅ "Start Anesthesia" button → starts elapsed timer (runs until "End Anesthesia")
- ✅ Real-time vital monitoring with parameter tiles (4x3 grid on iPad)
- ✅ Numeric inputs (HR, RR, SpO₂, EtCO₂, BP, Temp, Iso/Sevo%, O₂) via keypad overlay
- ✅ Quick-tap non-numeric inputs:
  - ECG: NSR, Sinus Brady, Sinus Tachy, VPCs, Atrial Fib (with waveform graphic)
  - CRT: <2 sec, >2 sec
  - Mucous Membrane: Pink, Pale, Blue, Grey, Muddy (color-coded chips)
- ✅ BP tile shows all three fields (SYS/DIA/MAP) - user fills what they have
- ✅ 5-minute visual nudge (header bar or tile border color change, NO sound)
- ✅ "Save Entry" button → timestamped snapshot of ALL current values
- ✅ Missed intervals: no backfill option, just save when you can (notation optional)
- ✅ "End Anesthesia" button → closes case, stops timer
- ✅ Case history browsing (patient name, date, species)
- ✅ On-screen record table view (nice-to-have)
- ✅ **PDF export with email/share (PRIORITY)**
- ✅ Species: Dogs & Cats only (MVP1)
- ✅ One active case at a time
- ❌ No session pause/resume
- ❌ No retroactive editing of old time slots (out of scope for MVP1)
- ❌ No drug logging (MVP2)
- ❌ No cloud sync (MVP2)
- ❌ No user accounts (MVP2)

### Session Behavior
- **Session Length**: Variable (20 minutes to 2+ hours, determined by surgery duration)
- **Timer**: Starts when user taps "Start Anesthesia", runs continuously until "End Anesthesia"
- **Recording Frequency**: User taps "Save Entry" whenever ready (ideally every 5 minutes)
- **5-Minute Nudge**: Visual reminder to save (header/tile color change), but not enforced
- **All Parameters Every Save**: Yes - every "Save Entry" captures all current tile values
- **No Pause/Resume**: Once started, timer runs until case ends
- **No Backfill**: If you miss the 5-minute mark, just save at 7 minutes - no retroactive entry

### Data Model

```kotlin
// Case
data class Case(
    val id: String,              // UUID
    val patientName: String,
    val species: Species,         // DOG, CAT
    val weight: Double,           // kg
    val procedure: String,
    val anestheticProtocol: String,
    val startTime: Instant,
    val endTime: Instant?,
    val status: CaseStatus        // ACTIVE, COMPLETED
)

// VitalRecord - One row per "Save Entry"
data class VitalRecord(
    val id: String,               // UUID
    val caseId: String,           // FK to Case
    val timestamp: Instant,
    
    // Numeric vitals
    val hr: Int?,                 // bpm
    val rr: Int?,                 // bpm
    val spo2: Int?,               // %
    val etco2: Int?,              // mmHg
    val bpSys: Int?,              // mmHg
    val bpDia: Int?,              // mmHg
    val bpMap: Int?,              // mmHg
    val temp: Double?,            // °C
    val sevoIso: Double?,         // %
    val o2Flow: Double?,          // L/min
    
    // Non-numeric vitals
    val ecg: ECGReading?,
    val crt: CRTReading?,
    val mucousMembrane: MucousMembraneReading?,
    
    val notes: String?
)

// Enums
enum class Species { DOG, CAT }
enum class CaseStatus { ACTIVE, COMPLETED }

// ECG Readings - displayed with waveform graphic
enum class ECGReading { 
    NSR,           // Normal Sinus Rhythm (waveform: ~~~)
    SINUS_BRADY,   // Sinus Bradycardia
    SINUS_TACHY,   // Sinus Tachycardia
    VPCS,          // Ventricular Premature Contractions
    ATRIAL_FIB     // Atrial Fibrillation
}

// CRT Readings - simple binary
enum class CRTReading { 
    LESS_THAN_2_SEC,    // Normal
    GREATER_THAN_2_SEC  // Delayed (potential concern)
}

// Mucous Membrane - color-coded chips
enum class MucousMembraneReading { 
    PINK,   // Normal (display: pink/coral chip)
    PALE,   // Anemia concern (display: pale pink chip)
    BLUE,   // Cyanosis (display: blue chip)
    GREY,   // Shock (display: grey chip)
    MUDDY   // Toxicity (display: brown/muddy chip)
}
```

**Display Notes:**
- ECG tile shows both waveform graphic AND text label
- Mucous Membrane uses color-coded chips matching the medical condition
- BP tile has three sub-fields in one tile: SYS / DIA / MAP (e.g., "115/65 (80)")
- Temperature displays with degree symbol: "99.1°"
- O₂ Flow shows unit: "1.5 L/min"
- Sevo/Iso shows percentage: "2.0%"

---

## 🚀 MVP1 Build Plan - Systematic Breakdown

### Phase 1: Foundation (Week 1)
**Goal**: Set up project structure and data layer

#### Milestone 1.1: Project Setup
- [ ] Initialize KMP project with Android + iOS targets
- [ ] Configure Gradle build files
- [ ] Set up module structure (shared, androidApp, iosApp)
- [ ] Add dependencies (SQLDelight, Koin, kotlinx-datetime, Voyager, SKIE)
- [ ] Verify Android build
- [ ] Verify iOS build (Xcode project generation)
- [ ] Set up version control (.gitignore properly configured)

**Deliverable**: Empty project that compiles on both platforms

#### Milestone 1.2: Data Models & Database
- [ ] Create domain models (Case, VitalRecord, enums)
- [ ] Define SQLDelight schema (.sq files)
  - [ ] Cases table
  - [ ] VitalRecords table
  - [ ] Queries: insert, update, getById, getAll, etc.
- [ ] Set up database driver (expect/actual)
- [ ] Write repository interfaces
- [ ] Implement CaseRepository
- [ ] Implement VitalRepository
- [ ] Write unit tests for repositories

**Deliverable**: Working local database with CRUD operations

#### Milestone 1.3: Use Cases & ViewModels
- [ ] Create use cases:
  - [ ] CreateCaseUseCase
  - [ ] StartAnesthesiaUseCase
  - [ ] SaveVitalsUseCase
  - [ ] EndAnesthesiaUseCase
  - [ ] GetCaseHistoryUseCase
  - [ ] GetVitalRecordsUseCase
- [ ] Set up Koin DI modules
- [ ] Create shared ViewModels:
  - [ ] CaseListViewModel
  - [ ] CaseSetupViewModel
  - [ ] MonitoringViewModel
  - [ ] RecordTableViewModel
- [ ] Test ViewModel logic with unit tests

**Deliverable**: Complete shared business logic layer

---

### Phase 2: Core Monitoring Screen (Week 2-3)
**Goal**: Build the most critical screen - where vets spend 90% of their time

#### Milestone 2.1: Android Monitoring Screen (UI Only)
- [ ] Create MonitoringScreen composable
- [ ] Build patient info header (name, weight, species, elapsed timer, battery indicator)
- [ ] Create parameter tile grid layout (4x3 for iPad, responsive for other sizes)
- [ ] Build numeric tiles (standard tiles):
  - [ ] HR (bpm)
  - [ ] RR (bpm)
  - [ ] SpO₂ (%)
  - [ ] EtCO₂ (mmHg)
  - [ ] Temp (°C or °F)
  - [ ] Iso/Sevo% (%)
  - [ ] O₂ Flow (L/min)
- [ ] Build BP tile (special - three values in one tile):
  - [ ] Display format: "SYS/DIA (MAP)"
  - [ ] Example: "115/65 (80)"
  - [ ] Tap opens keypad to enter each value separately OR
  - [ ] Three small input fields within the tile
- [ ] Build non-numeric tiles with chip selectors:
  - [ ] ECG tile: waveform graphic + text label (NSR, Sinus Brady, etc.)
  - [ ] CRT tile: text display (< 2 sec or > 2 sec)
  - [ ] Mucous Membrane tile: color-coded chip display (Pink, Pale, Blue, etc.)
- [ ] Build Notes tile (tap to add free text)
- [ ] Add "Save Entry" button (bottom or floating action button)
- [ ] Add "End Anesthesia" button (menu or bottom bar)
- [ ] Implement tablet layout optimization (landscape primary)
- [ ] Add 5-minute nudge visual placeholder (header bar color change area)

**Deliverable**: Monitoring screen UI (Android) - no functionality yet, just visual layout

#### Milestone 2.2: Input Components
- [ ] Build numeric keypad overlay/dialog:
  - [ ] Large number buttons (1-9, 0, backspace)
  - [ ] Decimal point support (for Temp, Sevo%, O₂ Flow)
  - [ ] Current value display at top (large font: 60-80pt)
  - [ ] Unit display below value (bpm, %, mmHg, °C, L/min)
  - [ ] "Clear" button (blue) - clears current input
  - [ ] "Save" button (green) - confirms and closes
  - [ ] Optimized for gloved hands (min 48dp touch targets)
- [ ] Build BP input overlay (special case - three fields):
  - [ ] Option A: Three sequential keypads (SYS → DIA → MAP)
  - [ ] Option B: One overlay with three input boxes
  - [ ] Show labels: "Systolic", "Diastolic", "MAP"
  - [ ] Allow partial entry (user can skip MAP if not measured)
  - [ ] Save button saves all three values
- [ ] Build ECG chip selector overlay:
  - [ ] 5 options: NSR, Sinus Brady, Sinus Tachy, VPCs, Atrial Fib
  - [ ] Display waveform icon next to each option
  - [ ] Large tap targets
  - [ ] Selected state highlighted
- [ ] Build CRT chip selector overlay:
  - [ ] 2 options: "< 2 sec" (normal), "> 2 sec" (delayed)
  - [ ] Simple binary choice
- [ ] Build Mucous Membrane chip selector overlay:
  - [ ] 5 color-coded chips: Pink, Pale, Blue, Grey, Muddy
  - [ ] Each chip shows color AND text label
  - [ ] Large tap targets
- [ ] Build notes input dialog:
  - [ ] Full-screen text input on tablets
  - [ ] Keyboard auto-shows
  - [ ] "Save" and "Cancel" buttons
  - [ ] Optional: quick-tag buttons ("Administered X", "Patient stable", etc.)
- [ ] Add haptic feedback on all taps (subtle)
- [ ] Test each input component in isolation

**Deliverable**: All input components working in isolation

#### Milestone 2.3: Wire Up Monitoring Logic (Android)
- [ ] Connect MonitoringViewModel to UI
- [ ] Implement tile tap → keypad/chip selector flow
- [ ] Implement value updates in ViewModel state
- [ ] Implement "Save Entry" button:
  - [ ] Captures all current tile values
  - [ ] Auto-generates timestamp
  - [ ] Persists VitalRecord to database
  - [ ] Debounce rapid taps
  - [ ] Show brief success confirmation (subtle)
- [ ] Implement elapsed timer:
  - [ ] Start when case begins
  - [ ] Display in MM:SS or HH:MM format
  - [ ] Update every second
- [ ] Implement 5-minute interval tracking:
  - [ ] Track time since last save
  - [ ] Trigger visual nudge at 5-minute mark
- [ ] Implement visual nudge:
  - [ ] Change header bar color (subtle yellow/orange) OR
  - [ ] Add pulsing border to tiles
  - [ ] Clear nudge when user saves
- [ ] Implement "End Anesthesia" button:
  - [ ] Confirm dialog ("Are you sure? This will close the case.")
  - [ ] Stop timer
  - [ ] Mark case as COMPLETED in database
  - [ ] Set endTime timestamp
  - [ ] Navigate to Record Table screen (or Home)
- [ ] Test full monitoring cycle:
  - [ ] Start case → monitoring screen loads
  - [ ] Update 3-5 parameters
  - [ ] Save entry → verify database write
  - [ ] Wait 5 minutes → verify nudge appears
  - [ ] Save again → verify nudge clears
  - [ ] End anesthesia → verify case marked complete

**Deliverable**: Fully functional monitoring screen on Android

#### Milestone 2.4: iOS Monitoring Screen
- [ ] Create MonitoringView in SwiftUI
- [ ] Replicate patient info header
- [ ] Create parameter tile grid (VStack/HStack/LazyVGrid)
- [ ] Build numeric tiles with SwiftUI styling
- [ ] Build non-numeric tiles with chip selectors
- [ ] Create numeric input sheet/overlay
- [ ] Create chip selector sheets
- [ ] Wire up to shared MonitoringViewModel via SKIE
- [ ] Test on iPad simulator and real device

**Deliverable**: Fully functional monitoring screen on iOS

---

### Phase 3: Case Management (Week 4)
**Goal**: Allow users to create cases and view history

#### Milestone 3.1: Case Setup Screen
- [ ] **Android**: Create CaseSetupScreen composable
  - [ ] Patient name input field
  - [ ] Species toggle (Dog/Cat) with icons
  - [ ] Weight input (numeric)
  - [ ] Procedure text field
  - [ ] Anesthetic protocol text field
  - [ ] Start time (auto-filled, editable)
  - [ ] "Start Anesthesia" button
  - [ ] Form validation
- [ ] **iOS**: Create CaseSetupView in SwiftUI
  - [ ] Mirror Android layout
  - [ ] Native iOS form styling
- [ ] Wire both to CaseSetupViewModel
- [ ] Test case creation flow → navigate to monitoring

**Deliverable**: Case creation working on both platforms

#### Milestone 3.2: Home Screen (Case List)
- [ ] **Android**: Create HomeScreen composable
  - [ ] List of past cases (patient name, date, species, status)
  - [ ] "New Case" FAB/button
  - [ ] Tap case → navigate to record table view
  - [ ] Empty state for no cases
  - [ ] Search/filter (optional nice-to-have)
- [ ] **iOS**: Create HomeView in SwiftUI
  - [ ] List with native iOS styling
  - [ ] Navigation to case setup
  - [ ] Navigation to record table
- [ ] Wire to CaseListViewModel
- [ ] Test navigation flows

**Deliverable**: Complete case history browsing

---

### Phase 4: Record Table & Export (Week 5)
**Goal**: Display saved vitals and enable PDF export

#### Milestone 4.1: Record Table Screen (Optional Nice-to-Have)
- [ ] **Android**: Create RecordTableScreen
  - [ ] Scrollable table (LazyColumn with HorizontalScrollView)
  - [ ] Columns: Time, HR, RR, SpO₂, EtCO₂, SYS, DIA, MAP, Temp, Iso/Sevo%, O₂, ECG, CRT, MM, Notes
  - [ ] Header row
  - [ ] Auto-size columns
  - [ ] Empty state if no records
  - [ ] "Export PDF" button (prominent)
- [ ] **iOS**: Create RecordTableView
  - [ ] ScrollView with structured layout
  - [ ] Native iOS table styling
- [ ] Wire to RecordTableViewModel
- [ ] Test with multiple vital records

**Note:** If time is limited, prioritize Milestone 4.2 (PDF Export) over perfecting this table view. The table can be simplified or even skipped if PDF output is excellent.

**Deliverable**: Readable on-screen record table (can be minimal)

#### Milestone 4.2: PDF Export ⚠️ **PRIORITY FEATURE**
This is more important than the on-screen table. A vet can skip the table view but MUST have a professional PDF to attach to patient records.

- [ ] Define professional PDF layout structure
  - [ ] **Header Section:**
    - Clinic name/logo (if available)
    - Patient name, species, weight
    - Procedure and anesthetic protocol
    - Start time, end time, total duration
  - [ ] **Vital Records Table:**
    - All columns: Time, HR, RR, SpO₂, EtCO₂, SYS, DIA, MAP, Temp, Iso/Sevo%, O₂, ECG, CRT, MM, Notes
    - Rows: All saved vital records with timestamps
    - Readable font (10-12pt monospace for table)
    - Proper column alignment
  - [ ] **Footer Section:**
    - Veterinarian signature line (optional)
    - Generated timestamp
    - "Generated by SnapVet" attribution
- [ ] **Android**: Implement PDF generation with Android PdfDocument API
  - [ ] Create expect/actual interface for PDF generator
  - [ ] Implement actual for Android
  - [ ] Draw patient header
  - [ ] Draw table with proper pagination (multi-page if needed)
  - [ ] Save to device storage (Downloads folder)
  - [ ] Share via Android intent (email, Drive, messaging apps)
- [ ] **iOS**: Implement PDF generation with UIGraphicsPDFRenderer
  - [ ] Create actual implementation for iOS
  - [ ] Match Android layout exactly
  - [ ] Save to Files app
  - [ ] Share via UIActivityViewController (email, AirDrop, etc.)
- [ ] Add "Export PDF" button to RecordTableScreen (or directly on monitoring screen)
- [ ] Test PDF output quality on both platforms
- [ ] Verify PDF opens correctly in:
  - [ ] Gmail (Android & iOS)
  - [ ] Apple Mail
  - [ ] Preview (macOS)
  - [ ] Adobe Acrobat Reader
  - [ ] Google Drive
- [ ] Test with edge cases:
  - [ ] Single entry case
  - [ ] 50+ entry case (multi-page PDF)
  - [ ] Missing parameters (empty cells handled gracefully)
  - [ ] Long notes (text wrapping)

**Deliverable**: Professional, shareable PDF export - this is a make-or-break feature

---

### Phase 5: Polish & Testing (Week 6)
**Goal**: Refinement, edge cases, and app store preparation

#### Milestone 5.1: Edge Cases & Error Handling
- [ ] Handle app crash during active case (restore state)
- [ ] Handle rapid taps on Save button (debouncing)
- [ ] Handle empty/invalid inputs gracefully
- [ ] Handle database errors (show user-friendly messages)
- [ ] Handle low storage warnings
- [ ] Test with 100+ vital records in a single case
- [ ] Test with 50+ cases in history

**Deliverable**: Robust error handling

#### Milestone 5.2: UI/UX Polish
- [ ] Add loading indicators where appropriate
- [ ] Add success confirmations (subtle)
- [ ] Improve tile animations and transitions
- [ ] Refine color scheme for medical context (avoid alarm fatigue)
- [ ] Ensure accessibility (font sizes, contrast, VoiceOver support)
- [ ] Add haptic feedback consistently
- [ ] Optimize for iPad landscape and portrait
- [ ] Test on various Android tablet sizes

**Deliverable**: Polished, professional UI

#### Milestone 5.3: Testing & Documentation
- [ ] Write integration tests for critical flows
- [ ] Manual testing checklist (create case → monitor → save → export)
- [ ] Performance testing (smooth 60fps on monitoring screen)
- [ ] Battery usage testing
- [ ] Document known limitations
- [ ] Create user guide (basic how-to)
- [ ] Prepare app store screenshots
- [ ] Write app store descriptions

**Deliverable**: MVP1 ready for internal testing / beta

---

## 🎯 MVP2 - Cloud Sync & Multi-User

### New Features
- ✅ User registration and login (email + password)
- ✅ Clinic/team concept (multi-user access to shared cases)
- ✅ Cloud sync with Supabase (offline-first, syncs when online)
- ✅ Drug logging (timestamped drug entries: name, dose, route)
- ✅ Fluid tracking (rate mL/hr, running total)
- ✅ Abnormal value alerts (tiles turn red/yellow based on species norms)
- ✅ Custom tile configuration (show/hide parameters per user)
- ✅ Advanced case search and filtering
- ✅ Exotic species support (beyond dogs/cats)

### Extended Data Model

```kotlin
// User
data class User(
    val id: String,
    val email: String,
    val name: String,
    val clinicId: String
)

// Clinic
data class Clinic(
    val id: String,
    val name: String,
    val address: String?
)

// DrugEntry
data class DrugEntry(
    val id: String,
    val caseId: String,
    val timestamp: Instant,
    val drugName: String,
    val dose: String,        // e.g. "0.5 mg/kg"
    val route: DrugRoute     // IV, IM, SC, PO, INHALATION
)

// FluidEntry
data class FluidEntry(
    val id: String,
    val caseId: String,
    val timestamp: Instant,
    val fluidType: String,   // e.g. "LRS", "0.9% NaCl"
    val rateMLPerHr: Double,
    val totalML: Double
)

enum class DrugRoute { IV, IM, SC, PO, INHALATION }
```

### Backend: Supabase

**Why Supabase?**
- You have prior experience (Couple Finance planning)
- Built-in auth (email/password, magic link, OAuth)
- Postgres database with Row Level Security (RLS)
- Real-time subscriptions for multi-device sync
- Storage for PDF backups
- supabase-kt library for KMP
- Generous free tier

**Supabase Schema**
```sql
-- users (managed by Supabase Auth)
-- custom user metadata: clinic_id

-- clinics
CREATE TABLE clinics (
  id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
  name TEXT NOT NULL,
  address TEXT,
  created_at TIMESTAMP DEFAULT NOW()
);

-- cases
CREATE TABLE cases (
  id UUID PRIMARY KEY,
  clinic_id UUID REFERENCES clinics(id),
  created_by UUID REFERENCES auth.users(id),
  patient_name TEXT NOT NULL,
  species TEXT NOT NULL,
  weight REAL NOT NULL,
  procedure TEXT,
  anesthetic_protocol TEXT,
  start_time TIMESTAMP NOT NULL,
  end_time TIMESTAMP,
  status TEXT NOT NULL,
  synced_at TIMESTAMP DEFAULT NOW()
);

-- vital_records
CREATE TABLE vital_records (
  id UUID PRIMARY KEY,
  case_id UUID REFERENCES cases(id) ON DELETE CASCADE,
  timestamp TIMESTAMP NOT NULL,
  hr INTEGER,
  rr INTEGER,
  spo2 INTEGER,
  etco2 INTEGER,
  bp_sys INTEGER,
  bp_dia INTEGER,
  bp_map INTEGER,
  temp REAL,
  sevo_iso REAL,
  o2_flow REAL,
  ecg TEXT,
  crt TEXT,
  mucous_membrane TEXT,
  notes TEXT,
  created_at TIMESTAMP DEFAULT NOW()
);

-- drug_entries (MVP2)
CREATE TABLE drug_entries (
  id UUID PRIMARY KEY,
  case_id UUID REFERENCES cases(id) ON DELETE CASCADE,
  timestamp TIMESTAMP NOT NULL,
  drug_name TEXT NOT NULL,
  dose TEXT NOT NULL,
  route TEXT NOT NULL,
  created_at TIMESTAMP DEFAULT NOW()
);

-- fluid_entries (MVP2)
CREATE TABLE fluid_entries (
  id UUID PRIMARY KEY,
  case_id UUID REFERENCES cases(id) ON DELETE CASCADE,
  timestamp TIMESTAMP NOT NULL,
  fluid_type TEXT NOT NULL,
  rate_ml_per_hr REAL,
  total_ml REAL,
  created_at TIMESTAMP DEFAULT NOW()
);

-- Row Level Security (RLS)
-- Users can only access cases from their clinic
ALTER TABLE cases ENABLE ROW LEVEL SECURITY;
CREATE POLICY "Users can view own clinic cases" 
  ON cases FOR SELECT 
  USING (clinic_id IN (
    SELECT clinic_id FROM user_profiles WHERE user_id = auth.uid()
  ));
```

---

## 🚀 MVP2 Build Plan - Systematic Breakdown

### Phase 6: Authentication & User Management (Week 7-8)

#### Milestone 6.1: Supabase Setup
- [ ] Create Supabase project
- [ ] Define database schema (clinics, cases, vital_records, drug_entries, fluid_entries)
- [ ] Set up Row Level Security policies
- [ ] Configure auth providers (email/password)
- [ ] Create user metadata for clinic assignment
- [ ] Add supabase-kt dependency to shared module

**Deliverable**: Supabase backend ready

#### Milestone 6.2: Auth Flow - Shared Layer
- [ ] Create AuthRepository with Supabase client
- [ ] Implement sign up
- [ ] Implement sign in
- [ ] Implement sign out
- [ ] Implement session management
- [ ] Create AuthViewModel
- [ ] Add use cases: LoginUseCase, RegisterUseCase, LogoutUseCase

**Deliverable**: Auth logic in shared layer

#### Milestone 6.3: Auth Screens
- [ ] **Android**: Login screen, Register screen
- [ ] **iOS**: Login view, Register view
- [ ] Add form validation
- [ ] Show loading states
- [ ] Handle auth errors gracefully
- [ ] Add "Forgot Password" flow
- [ ] Test complete auth flow on both platforms

**Deliverable**: Working authentication

---

### Phase 7: Cloud Sync (Week 9-10)

#### Milestone 7.1: Sync Architecture
- [ ] Design sync strategy (local-first, background sync)
- [ ] Create SyncRepository
- [ ] Implement conflict resolution (last-write-wins for MVP2)
- [ ] Add sync status tracking (pending, syncing, synced, failed)
- [ ] Implement queue for offline changes
- [ ] Add network connectivity monitoring

**Deliverable**: Sync architecture defined

#### Milestone 7.2: Sync Implementation
- [ ] Implement case sync (upload completed cases)
- [ ] Implement vital records sync
- [ ] Implement two-way sync (pull remote cases)
- [ ] Add background worker for periodic sync (Android: WorkManager, iOS: Background Tasks)
- [ ] Show sync status in UI (subtle indicator)
- [ ] Handle sync failures with retry logic
- [ ] Test offline → online sync scenario
- [ ] Test multi-device sync

**Deliverable**: Working cloud sync

#### Milestone 7.3: Multi-User Features
- [ ] Fetch and display clinic members
- [ ] Show "created by" info on cases
- [ ] Real-time case updates (optional - using Supabase Realtime)
- [ ] Handle concurrent editing conflicts
- [ ] Add clinic settings screen

**Deliverable**: Multi-user clinic support

---

### Phase 8: Drug & Fluid Tracking (Week 11)

#### Milestone 8.1: Drug Logging
- [ ] Add DrugEntry model and database table
- [ ] Create drug input dialog
  - [ ] Drug name (text or quick-select from common drugs)
  - [ ] Dose (text with unit)
  - [ ] Route (chip selector: IV, IM, SC, PO, Inhalation)
  - [ ] Timestamp (auto or manual)
- [ ] Add "Log Drug" button to monitoring screen
- [ ] Display drug log in record table
- [ ] Include in PDF export
- [ ] Sync drug entries to cloud

**Deliverable**: Drug logging feature

#### Milestone 8.2: Fluid Tracking
- [ ] Add FluidEntry model and database table
- [ ] Create fluid input dialog
  - [ ] Fluid type (text or quick-select)
  - [ ] Rate (mL/hr)
  - [ ] Running total tracker
- [ ] Add fluid tracking tile to monitoring screen
- [ ] Display fluid log in record table
- [ ] Include in PDF export
- [ ] Sync fluid entries to cloud

**Deliverable**: Fluid tracking feature

---

### Phase 9: Advanced Features (Week 12-13)

#### Milestone 9.1: Abnormal Value Alerts
- [ ] Define species-specific normal ranges
  - [ ] Dog ranges (HR, RR, SpO₂, EtCO₂, BP, Temp)
  - [ ] Cat ranges
  - [ ] Exotic species ranges (future)
- [ ] Implement tile color coding:
  - [ ] Green = normal
  - [ ] Yellow = borderline
  - [ ] Red = abnormal
- [ ] Add user preference to enable/disable alerts
- [ ] Test with various value inputs

**Deliverable**: Visual alerts for abnormal vitals

#### Milestone 9.2: Custom Tile Configuration
- [ ] Create settings screen
- [ ] Allow show/hide for each parameter tile
- [ ] Save user preferences to local storage
- [ ] Sync preferences to cloud (user profile)
- [ ] Dynamically render monitoring grid based on preferences
- [ ] Add preset configurations (minimal, standard, advanced)

**Deliverable**: Customizable monitoring screen

#### Milestone 9.3: Enhanced Search & Filtering
- [ ] Add search bar to home screen
- [ ] Filter by:
  - [ ] Date range
  - [ ] Species
  - [ ] Status (active/completed)
  - [ ] Patient name
  - [ ] Created by (clinic member)
- [ ] Add sorting options (date, patient name, species)
- [ ] Save filter preferences

**Deliverable**: Advanced case search

#### Milestone 9.4: Exotic Species Support
- [ ] Add more species enum values (RABBIT, BIRD, REPTILE, FERRET, etc.)
- [ ] Add species icon library
- [ ] Define species-specific normal ranges
- [ ] Test with non-dog/cat species
- [ ] Update PDF export to handle all species

**Deliverable**: Exotic species support

---

### Phase 10: Polish & Launch Prep (Week 14-15)

#### Milestone 10.1: Performance Optimization
- [ ] Profile database queries (optimize slow queries)
- [ ] Reduce memory usage
- [ ] Optimize PDF generation speed
- [ ] Ensure smooth 60fps on monitoring screen with 100+ records
- [ ] Test with slow network (sync performance)
- [ ] Battery usage optimization

**Deliverable**: Optimized app performance

#### Milestone 10.2: Security & Privacy
- [ ] Code review for security vulnerabilities
- [ ] Ensure sensitive data is encrypted at rest (SQLCipher optional)
- [ ] Verify Row Level Security in Supabase
- [ ] Add data export for GDPR compliance
- [ ] Add account deletion flow
- [ ] Privacy policy and terms of service

**Deliverable**: Security audit complete

#### Milestone 10.3: Final Testing
- [ ] End-to-end testing on both platforms
- [ ] Beta testing with 5-10 vet clinics
- [ ] Collect feedback and iterate
- [ ] Fix critical bugs
- [ ] Ensure offline mode works perfectly
- [ ] Test sync edge cases
- [ ] Perform stress testing (large datasets)

**Deliverable**: MVP2 ready for production

#### Milestone 10.4: App Store Submission
- [ ] Prepare app store assets (icon, screenshots, promo video)
- [ ] Write compelling app descriptions
- [ ] Set up App Store Connect and Google Play Console
- [ ] Submit Android app for review
- [ ] Submit iOS app for review
- [ ] Monitor reviews and respond to feedback
- [ ] Plan post-launch marketing

**Deliverable**: SnapVet live on app stores!

---

## 📊 Timeline Summary

| Phase | Duration | Milestones | Status |
|-------|----------|------------|--------|
| **MVP1** | | | |
| Phase 1: Foundation | 1 week | 1.1, 1.2, 1.3 | 🔲 Not Started |
| Phase 2: Monitoring Screen | 2 weeks | 2.1, 2.2, 2.3, 2.4 | 🔲 Not Started |
| Phase 3: Case Management | 1 week | 3.1, 3.2 | 🔲 Not Started |
| Phase 4: Record Table & Export | 1 week | 4.1, 4.2 | 🔲 Not Started |
| Phase 5: Polish & Testing | 1 week | 5.1, 5.2, 5.3 | 🔲 Not Started |
| **MVP1 Total** | **6 weeks** | | |
| **MVP2** | | | |
| Phase 6: Auth & Users | 2 weeks | 6.1, 6.2, 6.3 | 🔲 Not Started |
| Phase 7: Cloud Sync | 2 weeks | 7.1, 7.2, 7.3 | 🔲 Not Started |
| Phase 8: Drug & Fluid | 1 week | 8.1, 8.2 | 🔲 Not Started |
| Phase 9: Advanced Features | 2 weeks | 9.1, 9.2, 9.3, 9.4 | 🔲 Not Started |
| Phase 10: Launch Prep | 2 weeks | 10.1, 10.2, 10.3, 10.4 | 🔲 Not Started |
| **MVP2 Total** | **9 weeks** | | |
| **Grand Total** | **15 weeks** | | |

---

## 🎓 Learning Path (For SwiftUI/iOS Development)

Since you're building iOS UI for the first time, here's a focused learning plan:

### Week 0 (Before Phase 1): SwiftUI Crash Course
- [ ] Complete Apple's SwiftUI Essentials tutorial (2-3 days)
- [ ] Learn about @State, @Binding, @ObservedObject
- [ ] Understand VStack, HStack, List, Form
- [ ] Learn SwiftUI navigation (NavigationStack, sheets, alerts)
- [ ] Practice with a simple CRUD app (to-do list)

### During Development: Just-In-Time Learning
- [ ] Phase 2: Learn LazyVGrid for tile layout
- [ ] Phase 2: Learn custom view modifiers
- [ ] Phase 3: Learn Form and TextField validation
- [ ] Phase 4: Learn ScrollView and table layouts
- [ ] Phase 6: Learn async/await in Swift for Supabase calls

### Resources
- [Apple's SwiftUI Tutorials](https://developer.apple.com/tutorials/swiftui)
- [100 Days of SwiftUI](https://www.hackingwithswift.com/100/swiftui) (do first 15 days)
- [SKIE Documentation](https://skie.touchlab.co/) for Kotlin ↔ Swift interop

---

## 🧪 Testing Strategy

### Unit Tests (Shared Layer)
- Repository tests (SQLDelight queries)
- Use case tests (business logic)
- ViewModel tests (state management)

### Integration Tests
- Full flow tests (create case → save vitals → export PDF)
- Sync tests (offline → online scenarios)

### Manual Testing
- Tablet testing (iPad, Android tablets)
- Real-world usage (shadow a vet during surgery if possible)

### Beta Testing
- MVP1: Internal testing with 2-3 friendly vets
- MVP2: Expand to 5-10 clinics for feedback

---

## 🚦 Success Criteria

### MVP1 Launch Criteria
- [ ] App works 100% offline
- [ ] Can create case, monitor, save vitals, export PDF in under 2 minutes
- [ ] Zero crashes during 10 consecutive monitoring sessions
- [ ] PDF exports correctly with all data
- [ ] UI is smooth on iPad (60fps on monitoring screen)

### MVP2 Launch Criteria
- [ ] All MVP1 features remain stable
- [ ] Cloud sync works within 30 seconds when online
- [ ] Multi-user clinic access with proper permissions
- [ ] Drug and fluid logging integrated seamlessly
- [ ] 95%+ uptime for Supabase backend

---

## 📦 Repository Structure

```
SnapVet/
├── shared/
│   ├── src/
│   │   ├── commonMain/
│   │   │   ├── kotlin/
│   │   │   │   ├── data/
│   │   │   │   ├── domain/
│   │   │   │   ├── viewmodel/
│   │   │   │   └── di/
│   │   │   └── sqldelight/
│   │   ├── androidMain/
│   │   └── iosMain/
│   └── build.gradle.kts
├── androidApp/
│   ├── src/main/
│   │   ├── kotlin/
│   │   │   ├── ui/
│   │   │   ├── theme/
│   │   │   └── MainActivity.kt
│   │   └── AndroidManifest.xml
│   └── build.gradle.kts
├── iosApp/
│   ├── iosApp/
│   │   ├── Views/
│   │   ├── Assets/
│   │   └── iosApp.swift
│   └── iosApp.xcodeproj
├── gradle/
├── build.gradle.kts
├── settings.gradle.kts
├── README.md
└── .gitignore
```

---

## 🔧 Development Environment Setup

### Prerequisites
- **macOS** (required for iOS development)
- **Android Studio** (latest stable)
- **Xcode** (latest stable)
- **Kotlin Multiplatform Mobile plugin** for Android Studio
- **CocoaPods** (for iOS dependencies)
- **JDK 17+**

### First-Time Setup
```bash
# Clone repo
git clone https://github.com/waliahimanshu/SnapVet.git
cd SnapVet

# Install iOS dependencies
cd iosApp
pod install
cd ..

# Build Android
./gradlew :androidApp:build

# Build iOS (from Android Studio or Xcode)
# Open iosApp/iosApp.xcworkspace in Xcode
```

---

## 📝 Contributing

This is a solo project for MVP1-2, but contributions welcome post-launch!

---

## 📄 License

TBD (likely MIT or GPL depending on distribution model)

---

## 🙏 Acknowledgments

Built with ❤️ for veterinary professionals who save lives every day.

---

## 📞 Contact

**Developer**: Himanshu Walia  
**GitHub**: [@waliahimanshu](https://github.com/waliahimanshu)

---

**Next Steps**: Start with Phase 1, Milestone 1.1. Good luck! 🚀

---

## 📎 Appendix

### Original Requirements Document
This README is based on the original planning document which specified:
- Single user, single device, no login (MVP1)
- Dogs and cats only (exotics in MVP2)
- All parameters recorded every save (no sparse entries)
- Session starts with "Start Anesthesia," ends with "End Anesthesia" button
- No pause/resume functionality
- No backfill for missed intervals
- Save = snapshot all current values with auto-timestamp
- 5-minute visual nudge (color change, no sound for MVP1)
- Non-numeric params use quick-tap chip selectors
- BP shows all three fields (SYS/DIA/MAP)
- No drug logging in MVP1 (moved to MVP2)
- Output: on-screen table view + PDF export (PDF is priority)
- Cases saved locally, browsable by patient name and date
- One active case at a time

### Mockup Screens
Three core screens were mocked up:
1. **New Case Setup**: Form to create case and start anesthesia
2. **Monitoring Screen**: Tile-based parameter grid with timer (core experience)
3. **Anesthetic Records Table**: Scrollable table + PDF export

These mockups informed the dark blue medical-grade design system and interaction patterns.

### Architecture Decision
**Shared KMP + Native UI** (not full Compose Multiplatform UI):
- Shared Kotlin code (70-80%): data, business logic, ViewModels
- Native UI (20-30%): Compose for Android, SwiftUI for iOS
- Rationale: iPads are primary device in vet clinics; SwiftUI gives best iOS/iPad experience
- SKIE bridges Kotlin → Swift seamlessly for ViewModel consumption

---

### Version History
- **v1.0** (Current): Initial planning document based on mockups and requirements
- Future: Will be updated as development progresses and decisions are made

---

**Built with ❤️ for veterinary professionals who save lives every day.**