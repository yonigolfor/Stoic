# Senior iOS Product Engineer — Manifest

**Role:** Senior iOS Product Engineer building SwiftUI apps at Apple Premium UX quality.
Guiding principles: absolute smoothness (120Hz ProMotion optimized), compact idiomatic Swift, zero reinventing the wheel.

## Iron Principles (apply before writing a single line of code)

**Native First — Do Not Over-Engineer:**
Before reaching for complex logic, manual offset calculations, GeometryReader, custom frames, or Safe Area manipulations — stop and ask: "How did Apple implement this in their own premium apps (like Journal or Fitness)? Which built-in SwiftUI component or modifier gives me this out of the box?"

**Leverage OS Mechanisms:**
Maximize native frameworks (`SwiftData`, `.sensoryFeedback`, built-in Layout Protocols, `UserNotifications`) over third-party solutions or complex imperative code. OS-level execution is always more efficient, future-proof, and memory-managed.

**Measure Before Optimizing (YAGNI):**
Do not add caching layers or complex asynchronous thread hops unless a Profiler proves a real hit on the main thread. Clean, native layout code is fundamentally fast code.

---

# Marcus — Developer Guide

## What This App Is
Marcus is a premium, distraction-free "Active Stoicism" platform designed for high-performers. Unlike generic quote aggregators that foster passive consumption, Marcus bridges ancient wisdom with immediate, localized daily execution.

### Core Value & Features:
1. **Context-Aware Onboarding:** Tailors the user experience based on a closed set of high-leverage profiles (Profession, Core Mental Obstacle) to drive targeted daily utility.
2. **Morning Alignment:** Serves exactly ONE algorithmically filtered quote per day matching the user's cognitive block, requiring the user to commit to 2 highly specific, micro-actionable daily goals.
3. **Evening Accountability:** A seamless friction-free reflection phase to log goal completion statuses and save structural journal data locally.
4. **100% Native Architecture:** Zero network dependency, zero servers, full SwiftData execution, and local scheduled push configurations.

---

## Architecture

**Pattern:** MVVM structured via modern native state injection. 100% Native Apple SDKs.

### Service & ViewModel Tree:
- **AppState / Session Context:** Evaluates initialization states and onboarding routing flags.
- **Persistence Layer (`SwiftData`):** Handles structural storage for historical reflection profiles, daily tracking, and local metrics.
- **NotificationManager:** Configures OS-level background notifications for custom user timeframes.

```
[App Entry Point]
│
▼
[ContentNotificationGate] ──(Reads AppState)──► [OnboardingView] or [MainView]
│
├─► [MorningSessionViewModel] ──► Interacts with Local JSON & SwiftData
└─► [EveningSessionViewModel] ──► Mutates Daily Journal Schema in SwiftData
```

**State flows down, events flow up** through dedicated ViewModels. Views read state via localized modern observation properties—they never touch data stores or managers directly.

**Threading Rules:**
- Main ViewModels are strictly marked `@MainActor`. All structural mutations happen on the main actor thread.
- JSON parsing and complex SwiftData history filtering run on background Tasks, explicitly published to the main thread via sequential `await MainActor.run { }` blocks.

---

## File Structure

```
Marcus/
├── MarcusApp.swift               # App entry point, SwiftData Container initialization
├── ContentGateView.swift         # Structural root view handling onboarding routing
│
├── Models/
│   ├── UserProfile.swift         # SwiftData Entity: Name, Profession, CoreObstacle, Notification Preferences
│   ├── DailyCommitment.swift     # SwiftData Entity: Date, QuoteID, TargetGoals[String], CompletedFlags[Bool]
│   └── StoicQuote.swift          # Codable Decodable Struct mapping the local JSON schema
│
├── ViewModels/
│   ├── OnboardingViewModel.swift # Handles validation state for the initial setups
│   ├── MorningViewModel.swift    # Business logic for JSON parsing, filtering, and goal generation
│   └── EveningViewModel.swift    # Evaluation of metrics, streak building, and reflection storage
│
├── Views/
│   ├── Onboarding/
│   │   ├── OnboardingContainerView.swift # Managed multi-step wizard layout
│   │   ├── Steps/ProfileSetupView.swift  # Closed list choices (Profession / Obstacle)
│   │   └── Steps/TimeSetupView.swift     # UNNotification integration time pickers
│   ├── Main/
│   │   ├── MorningDashboardView.swift    # Premium focal interface for the day's text
│   │   └── EveningReflectionView.swift   # Minimalist input form and status indicators
│   └── Components/
│       ├── PremiumCardView.swift         # Uniform modular container view
│       └── StoicButton.swift             # Standardized haptic-enabled custom native button
│
├── Services/
│   ├── PersistenceService.swift  # Light UserDefaults layer for absolute primitives
│   ├── HapticService.swift       # Direct UIImpactFeedbackGenerator / SensoryFeedback wrapper
│   └── NotificationManager.swift # Orchestrates local background notification triggers
│
└── Extensions/
    └── Color+Theme.swift         # Unified static palette configuration
```

---

## Color & Typography Palette

All UI elements must conform directly to this custom minimalist theme. Do not raw-code hex strings or separate values.

### Color Tokens:

```swift
extension Color {
    // Premium Minimalist Earth Tones
    static let stoicBackground   = Color(red: 0.09, green: 0.09, blue: 0.08) // #171715 deep raw charcoal
    static let stoicSurface      = Color(red: 0.14, green: 0.14, blue: 0.13) // #1F1F1D card backgrounds
    static let stoicAccent       = Color(red: 0.76, green: 0.70, blue: 0.62) // #C2B49E muted roman stone / gold
    static let stoicTextPrimary  = Color(red: 0.95, green: 0.95, blue: 0.93) // #F2F2ED bone white text
    static let stoicTextSecondary = Color(red: 0.60, green: 0.60, blue: 0.57) // #999992 muted dust gray
}
```

### Typography Hierarchy:

- **The Core Quote:** `.system(size: 24, weight: .medium, design: .serif)` — always serif for historical core context texts.
- **Primary Headers:** `.system(size: 28, weight: .bold, design: .rounded)`.
- **Form Selections / Inputs:** `.system(size: 17, weight: .regular, design: .default)`.
- **Stat Badges / Counters:** Utilize `.contentTransition(.numericText())` to morph numbers smoothly during progression animation.

---

## Navigation Matrix

- **App Initialization:** Checked against `hasCompletedOnboarding`. If `false`, presents `OnboardingContainerView` via a clean modal overlay or structural edge-to-edge layout gateway.
- **Core Dashboard Architecture:** Avoid TabViews if possible to focus attention. Instead, use a contextual layout switcher driven by time of day or action completion:
  - If morning action is pending → Render `MorningDashboardView`.
  - If daily goals are tracked but evening review is due → Present `EveningReflectionView` smoothly.
- **Sheets / Modals:** History or historical log lists are revealed via native `.sheet` structures using `.presentationDetents([.medium, .large])` to respect standard iOS view structures.

---

## Persistence Configurations

### Primary Engine:
`SwiftData` manages data entities that map individual user tracking progression.

### Primitive Defaults (`PersistenceService` Keys):

| Key | Type | Purpose |
|-----|------|---------|
| `hasCompletedOnboarding` | `Bool` | Controls application root gate view routing |
| `morningNotificationTime` | `String` | Stored system configuration string representation |
| `eveningNotificationTime` | `String` | Stored system configuration string representation |
| `currentStreak` | `Int` | Cached value for structural dashboard representation |

---

## Conventions & Patterns

### Naming Conventions:
- Views strictly appended with `*View.swift`
- Single instances providing localized device operations appended with `*Service.swift` or `*Manager.swift`
- State stores housing active layout execution data appended with `*ViewModel.swift`

### Localization Matrix:
- Never use raw string constants inside views. Implement `String(localized: "key")`. All user text allocations map directly to `Localizable.xcstrings`.

### Haptics Policy:
- Every action triggering a change of application state or interactive selection MUST explicitly communicate confirmation through `HapticService` wrapper primitives (`.success`, `.light`, `.selection`).

### External Packages Guardrail:
- **Zero Third-Party Dependencies.** Do not inject SPM packages or CocoaPods. If an engineering utility is required, it must be written natively using existing foundation libraries.

---

## Building the App

```bash
DEVELOPER_DIR=/Applications/Xcode.app/Contents/Developer \
xcodebuild \
  -project /Users/user/Desktop/apps/Marcus/Marcus.xcodeproj \
  -scheme Marcus \
  -destination "platform=iOS Simulator,name=iPhone 17" \
  -configuration Debug \
  build 2>&1 | grep -E "error:|warning:|BUILD SUCCEEDED|BUILD FAILED"
```

### Engineering Gotchas & Edge Cases:

- **SourceKit Warnings:** Syntactic diagnostics inside Xcode for SwiftData macros are occasionally slow or produce false positives. **Always trust the explicit output of the CLI compilation step over editor visuals.**
- **Notification Scheduling:** Remember that `UNUserNotificationCenter` configurations fail on the Simulator if authorization hasn't been granted via permissions sheet alerts. Implement clean fallback logic.
