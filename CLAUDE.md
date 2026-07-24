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
5. **Friction Gate (Screen Time):** Opening a distracting app the user has restricted surfaces a native Shield → a live front-camera "Mirror Gate" pattern-interrupt, asking the user to consciously choose to step back or continue. See the dedicated **Stoic Friction Gate** section below for the full architecture and hard-won platform constraints.

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
Stoic/
├── Stoic/
│   ├── StoicApp.swift             # App entry point, SwiftData Container init, scenePhase-driven Mirror Gate trigger
│   ├── AppDelegate.swift          # UNUserNotificationCenterDelegate — routes Mirror Gate notification taps
│   ├── ContentGateView.swift      # Structural root view handling onboarding routing
│   │
│   ├── Models/
│   │   ├── UserProfile.swift      # SwiftData Entity: Name, Profession, CoreObstacle, Notification Preferences
│   │   ├── DailyCommitment.swift  # SwiftData Entity: Date, QuoteID, TargetGoals[String], CompletedFlags[Bool]
│   │   ├── StoicQuote.swift       # Codable Decodable Struct mapping the local JSON schema
│   │   └── FocusAppOption.swift   # Closed chip list (TikTok/Instagram/Snapchat/X/YouTube) shown pre-picker
│   │
│   ├── ViewModels/
│   │   ├── OnboardingViewModel.swift  # Validation state + Screen Time authorization/shield application
│   │   ├── MorningViewModel.swift     # Business logic for JSON parsing, filtering, and goal generation
│   │   ├── EveningViewModel.swift     # Evaluation of metrics, streak building, and reflection storage
│   │   └── MirrorGateViewModel.swift  # Camera lifecycle + Step Back / Continue Anyway decisions
│   │
│   ├── Views/
│   │   ├── Onboarding/
│   │   │   ├── OnboardingContainerView.swift          # 4-step TabView wizard
│   │   │   └── Steps/ProfileSetupView.swift, TimeSetupView.swift, NameSetupView.swift,
│   │   │       OnboardingIntentionalityView.swift      # Friction Gate app selection + Screen Time auth
│   │   ├── Main/
│   │   │   ├── MorningDashboardView.swift  # Premium focal interface for the day's text + Focus Victories card
│   │   │   └── EveningReflectionView.swift # Minimalist input form and status indicators
│   │   ├── MirrorGate/
│   │   │   └── StoicMirrorGateView.swift   # Live front-camera friction screen (see Friction Gate section below)
│   │   └── Components/
│   │       ├── PremiumCardView.swift       # Uniform modular container view
│   │       ├── StoicButton.swift           # Standardized haptic-enabled custom native button
│   │       └── FocusVictoryCard.swift      # Dashboard ring-progress + streak card
│   │
│   ├── Services/
│   │   ├── PersistenceService.swift    # App Group UserDefaults layer (shared with extensions)
│   │   ├── HapticService.swift         # Direct UIImpactFeedbackGenerator / SensoryFeedback wrapper
│   │   ├── NotificationManager.swift   # Orchestrates local background notification triggers
│   │   ├── CameraPreviewService.swift  # AVCaptureSession wrapper for the Mirror Gate
│   │   └── ScreenTimeGateService.swift # ManagedSettingsStore + DeviceActivity grace-period logic
│   │
│   └── Extensions/
│       └── Color+Theme.swift       # Unified static palette configuration
│
├── StoicShieldConfiguration/       # Extension target — ShieldConfigurationDataSource
├── StoicShieldAction/              # Extension target — ShieldActionDelegate
└── StoicActivityMonitor/           # Extension target — DeviceActivityMonitor
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
| `preferredLanguage` | `String?` | Read by the extensions (via App Group) to localize Shield/notification copy |
| `selectedFocusAppsRaw` | `Data?` | Encoded `FamilyActivitySelection` from onboarding; read by `StoicActivityMonitor` to re-shield |
| `lastMirrorGateGraceGrantedAt` | `Date?` | Diagnostic timestamp of the last granted grace window |
| `pendingMirrorGateTrigger` | `Bool` | Set by `AppDelegate` on notification tap; consumed by `StoicApp` once `scenePhase == .active` |
| `focusVictoriesCount` / `focusVictoriesWeekCount` / `focusStreakDays` | `Int` | Dashboard "Focus Victories" card state, updated via `recordFocusVictory()` |
| `lastGraceMonitoringError` | `String?` | Diagnostic: `DeviceActivityCenter.startMonitoring`'s thrown error (if any) from the last grace-period request. `nil` = registered successfully |

`PersistenceService` reads from App Group suite `group.com.yonigolfor.Stoic` (not `.standard`) so the three Screen Time extensions can share this state — this is required, not incidental.

---

## Conventions & Patterns

### Naming Conventions:
- Views strictly appended with `*View.swift`
- Single instances providing localized device operations appended with `*Service.swift` or `*Manager.swift`
- State stores housing active layout execution data appended with `*ViewModel.swift`

### Bilingual Support (Hebrew + English):
The app is fully bilingual — **Hebrew (he) and English (en)** are both first-class languages.

**Rules that apply everywhere:**
- Every user-facing string must have both an English and Hebrew version in `Localizable.xcstrings`. Never add UI text in one language only.
- The `StoicQuote` JSON schema carries parallel fields for every localizable value:
  - `text` / `text_he` — quote body
  - `author` / `author_he` — author name transliterated/translated to Hebrew
  - `one_word_title_en` / `one_word_title_he` — card title
- When enriching **any** quote entry, all four fields above are **mandatory**. A quote entry is incomplete without `author_he`.
- Hebrew author names follow standard Israeli transliteration conventions (e.g. Marcus Aurelius → מרקוס אורליוס, Seneca → סנקה, Epictetus → אפיקטטוס).
- UI layout must support RTL (`layoutDirection(.rightToLeft)`) for Hebrew users — do not hard-code leading/trailing assumptions.

**`text_he` Translation Standard — Marcus Voice:**
Marcus is a raw, premium Active Stoicism platform for high-performers — not an academic app. Every `text_he` must sound like a sharp, real human being speaking modern Israeli Hebrew, not a translated text.

- **Escape the Translation Trap:** Never translate word-for-word. Rearrange structure so it makes native sense to an Israeli ear.
- **Forbidden register:** No archaic, biblical, or high-literary phrasing. Avoid: אנוכי, חפץ, על נקלה, הלז, בל יעבור and similar.
- **Rhythm over fidelity:** Rearrange sentences for punch. A shorter, harder-hitting sentence beats a faithful but flat one.
- **Strict Rule — Complete Sentences:** Every `text_he` must be a grammatically complete sentence. Do not cut sentences mid-way or leave pronouns without a clear referent (e.g. "הוא נכבש" with no prior subject defined). Sharp is good. Incomplete is a bug.
- **One-word titles (`one_word_title_he`):** Must be a single punchy, modern colloquial word — not a textbook term.

### Localization Matrix:
- Never use raw string constants inside views. Implement `String(localized: "key")`. All user text allocations map directly to `Localizable.xcstrings`.

### Haptics Policy:
- Every action triggering a change of application state or interactive selection MUST explicitly communicate confirmation through `HapticService` wrapper primitives (`.success`, `.light`, `.selection`).

### External Packages Guardrail:
- **Zero Third-Party Dependencies.** Do not inject SPM packages or CocoaPods. If an engineering utility is required, it must be written natively using existing foundation libraries.

---

## Stoic Friction Gate (Screen Time Integration)

### What it does
When the user opens an app they've chosen to restrict (TikTok, Instagram, etc.), a native system Shield intercepts the launch. Tapping the shield's single button fires a local notification; tapping *that* drops the user directly into `StoicMirrorGateView` — a live front-camera screen asking them to consciously choose: **Step Back** (stay in Stoic, counted as a win on the dashboard) or **Continue Anyway** (temporarily lift the restriction for a fixed window).

### Two-hop architecture (why it's two hops, not one)
`ShieldConfigurationExtension` / `ShieldActionExtension` are sandboxed system UI — no custom SwiftUI, no camera, no `AVCaptureSession` is possible there. The only place a live camera can run is inside Stoic's own app process. So: **native Shield → tap → local notification → tap → in-app Mirror Gate**. This is the same shape used by Opal, One Sec, and Freedom, for the same platform reason.

### Targets
Four targets total, all sharing App Group `group.com.yonigolfor.Stoic`:
- `Stoic` — main app.
- `StoicShieldConfiguration` — `ShieldConfigurationDataSource`. Renders the native Shield. Ceiling: title/subtitle/icon/one button, a single flat `backgroundColor`, and a system `backgroundBlurStyle` — **no gradients, no custom views** are possible here, confirmed against the `ManagedSettingsUI` interface.
- `StoicShieldAction` — `ShieldActionDelegate`. Handles the button tap: schedules a `.timeSensitive` local notification and returns `.none` (deliberately does **not** dismiss the shield — see constraints below).
- `StoicActivityMonitor` — `DeviceActivityMonitor`. Re-applies the shield when the grace window ends (`intervalDidEnd`).

New targets must be created via Xcode's GUI wizard (`File → New → Target`) — hand-editing whole new `PBXNativeTarget` blocks into `project.pbxproj` risks corrupting it. Once a target exists, dropping Swift files into its folder is enough (`PBXFileSystemSynchronizedRootGroup` auto-includes them — no manual pbxproj registration needed).

### Entitlements
- `Stoic.entitlements`: `com.apple.developer.family-controls`, `com.apple.security.application-groups` (the group above), `com.apple.developer.usernotifications.time-sensitive`.
- Each extension's own `.entitlements`: `com.apple.security.application-groups` only — Family Controls is main-app-only.
- `com.apple.developer.family-controls` does **not** require Apple's special distribution-approval form for local development, only for App Store distribution — verified empirically via `xcodebuild -allowProvisioningUpdates` producing a real signed on-device build.

### Hard platform constraints (empirically confirmed — don't re-attempt these)
- **No API opens the containing app from `ShieldActionDelegate`.** `extensionContext`, `UIApplication`, `@Environment(\.openURL)` are all unavailable there (real compile errors, not editor noise). The only sanctioned handoff is a local notification the user taps — corroborated by Apple DTS forum threads (FB17261679, FB22696417, FB15079668). A private-API workaround (`LSApplicationWorkspace`) caused a real App Store rejection (guideline 2.5.1) elsewhere — do not attempt it.
- **`Application.bundleIdentifier` / `localizedDisplayName` come back `nil`** for third-party apps inside `ShieldConfigurationDataSource`, even though the struct declares them non-privately. Confirmed by capturing and displaying the value on-device. Stoic can never know *which* specific app a given Shield instance is blocking.
- **No public API reads the app switcher / previously-frontmost app** — checked directly against the UIKit / FamilyControls / DeviceActivity SDK interfaces; nothing like `recentApplications`/`frontmostApplication` exists for third-party apps.
- **Net effect:** Stoic cannot auto-detect which app to return to, and cannot force-foreground another app even if it knew which one. "Continue Anyway" can only unshield + show an honest "Access granted" confirmation — the user always switches back manually. Every app in this category has this same ceiling; it's not a Stoic-specific gap.
- **`ShieldActionResponse.close` returns to the Home Screen, never into the app that was shielded** — even Apple's own default Shield can't resume the intercepted launch. Once a Shield intercepts, that specific launch attempt is gone.
- **Cold-launch notification race:** if Stoic isn't already running, `AppDelegate.didReceive` can fire before SwiftUI's `.onReceive` subscriber exists, silently dropping a live `NotificationCenter` broadcast. Fixed by also persisting `pendingMirrorGateTrigger` (App Group `UserDefaults`), which `StoicApp` checks via `.onChange(of: scenePhase)` once the scene is genuinely `.active`.
- **`ShieldAction` enum cases are `.primaryButtonPressed` / `.secondaryButtonPressed`**, not `.primary`/`.secondary` — an easy naming trap in `ShieldActionExtension`'s switch.
- **`DeviceActivitySchedule` enforces an undocumented minimum interval length.** `DeviceActivityCenter.MonitoringError.intervalTooShort` is a real case, and a 10-minute (and earlier 2-minute) grace window hit it in practice — `startMonitoring` threw, was previously swallowed by `try?`, and the shield silently never came back. **15 minutes is the current known-working floor** (confirmed on-device via `PersistenceService.lastGraceMonitoringError`, surfaced by the 🩺 debug button in `MainSessionView`). Never swallow `DeviceActivityCenter.startMonitoring`'s error with `try?` again — always `do/catch` and persist it, since there's no other way to observe a Screen Time extension's failures.

### Grace period mechanism
`ScreenTimeGateService.grantGracePeriod(minutes:)` (currently called with **15** from `MirrorGateViewModel.continueAnyway` — see the `intervalTooShort` constraint above for why not lower): removes the app(s) from `ManagedSettingsStore().shield.applications` immediately, then schedules a one-shot `DeviceActivitySchedule` (`intervalStart` = now, `intervalEnd` = now + minutes) via `DeviceActivityCenter`. `StoicActivityMonitor.intervalDidEnd` re-applies the shield when it fires. This is a **fixed wall-clock window from the tap**, not usage time — a usage-threshold version (`DeviceActivityEvent`) was tried and reverted per product decision, since a fixed window is easier to predict even though it can still interrupt mid-session exactly when the window elapses.

### Testing
Screen Time APIs **do not run in the Simulator** — a physical device is required. Build and install from the CLI (works even if Xcode's own GUI is closed or its scheme list is stale):
```bash
xcodebuild -project Stoic.xcodeproj -scheme Stoic -destination "id=<device-UDID>" -configuration Debug -allowProvisioningUpdates build
xcrun devicectl device install app --device <device-UDID> "<DerivedData path>/Build/Products/Debug-iphoneos/Stoic.app"
```

`MainSessionView`'s `#if DEBUG` overlay has four tools for exercising this flow without waiting on a real Shield trigger: reset onboarding, preview the Mirror Gate directly (camera icon), clear the shield (unlock icon), and a 🩺 diagnostic alert (`lastMirrorGateGraceGrantedAt` / `lastGraceMonitoringError` / whether the store currently has an active shield) — the last one is how the `intervalTooShort` bug above was actually diagnosed, since Screen Time extensions have no other visible failure signal.

---

## Building the App

```bash
DEVELOPER_DIR=/Applications/Xcode.app/Contents/Developer \
xcodebuild \
  -project /Users/yonigolfor/Desktop/Code/apps/Stoic/Stoic.xcodeproj \
  -scheme Stoic \
  -destination "platform=iOS Simulator,name=iPhone 17" \
  -configuration Debug \
  build 2>&1 | grep -E "error:|warning:|BUILD SUCCEEDED|BUILD FAILED"
```

For anything touching Screen Time/Family Controls, use a physical device destination (`-destination "id=<device-UDID>"`) instead — see Testing above.

### Engineering Gotchas & Edge Cases:

- **SourceKit Warnings:** Syntactic diagnostics inside Xcode (and shown inline after file edits) are frequently stale or false — this got worse, not better, after the Screen Time extension targets were added (macOS-target-unavailable warnings on files that only ever run on iOS are expected noise). **Always trust the explicit output of the CLI compilation step over editor/inline diagnostics.**
- **Notification Scheduling:** Remember that `UNUserNotificationCenter` configurations fail on the Simulator if authorization hasn't been granted via permissions sheet alerts. Implement clean fallback logic.
- **Xcode "Stoic" target/scheme disappearing:** After adding the extension targets, Xcode's own Scheme picker (and occasionally the Targets list) periodically stops showing the `Stoic` target — this is an Xcode UI/index cache bug, not project corruption (the `project.pbxproj` itself stays valid throughout; `xcodebuild`/CLI builds keep working the whole time regardless). Fix in order of effort: (1) delete `Stoic.xcodeproj/xcuserdata/*/xcschemes/xcschememanagement.plist` and relaunch Xcode; (2) also clear DerivedData for the project and relaunch; (3) durable fix — `Product → Scheme → New Scheme…`, pick target `Stoic` explicitly, which writes a real `.xcscheme` file that stops depending on Xcode's autocreate behavior entirely.
