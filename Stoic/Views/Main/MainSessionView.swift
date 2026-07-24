import SwiftUI
import SwiftData
import ManagedSettings

struct MainSessionView: View {
    @Environment(\.modelContext) private var modelContext
    @State private var viewModel = MorningViewModel()
    var onReset: () -> Void
    #if DEBUG
    @State private var showMirrorGatePreview = false
    @State private var showGraceDiagnostic = false
    #endif

    var body: some View {
        ZStack {
            Color.stoicBackground.ignoresSafeArea()

            if let commitment = viewModel.todayCommitment, commitment.isEveningComplete {
                EveningReflectionView(commitment: commitment)
            } else {
                MorningDashboardView(viewModel: viewModel)
            }
        }
        .onAppear {
            viewModel.load(context: modelContext)
        }
        #if DEBUG
        .overlay(alignment: .topLeading) {
            HStack(spacing: 16) {
                Button(action: resetApp) {
                    Image(systemName: "arrow.counterclockwise.circle")
                        .font(.system(size: 22, weight: .medium))
                        .foregroundStyle(Color.stoicTextSecondary.opacity(0.5))
                }
                Button(action: { showMirrorGatePreview = true }) {
                    Image(systemName: "camera.circle")
                        .font(.system(size: 22, weight: .medium))
                        .foregroundStyle(Color.stoicTextSecondary.opacity(0.5))
                }
                Button(action: clearShield) {
                    Image(systemName: "lock.open.circle")
                        .font(.system(size: 22, weight: .medium))
                        .foregroundStyle(Color.stoicTextSecondary.opacity(0.5))
                }
                Button(action: { showGraceDiagnostic = true }) {
                    Image(systemName: "stethoscope.circle")
                        .font(.system(size: 22, weight: .medium))
                        .foregroundStyle(Color.stoicTextSecondary.opacity(0.5))
                }
            }
            .padding(.top, 58)
            .padding(.leading, 20)
        }
        .fullScreenCover(isPresented: $showMirrorGatePreview) {
            StoicMirrorGateView(
                onStepBack: { showMirrorGatePreview = false },
                onContinue: { showMirrorGatePreview = false }
            )
        }
        .alert("Grace Period Diagnostic", isPresented: $showGraceDiagnostic) {
            Button("OK", role: .cancel) {}
        } message: {
            Text(graceDiagnosticText)
        }
        #endif
    }

    #if DEBUG
    private func resetApp() {
        try? modelContext.delete(model: UserProfile.self)
        try? modelContext.delete(model: DailyCommitment.self)
        PersistenceService.shared.hasCompletedOnboarding = false
        PersistenceService.shared.clearAllQuoteQueues()
        LanguageService.redetect()
        HapticService.shared.success()
        onReset()
    }

    private func clearShield() {
        ManagedSettingsStore().shield.applications = nil
        HapticService.shared.light()
    }

    private var graceDiagnosticText: String {
        let grantedAt = PersistenceService.shared.lastMirrorGateGraceGrantedAt.map { "\($0)" } ?? "never"
        let error = PersistenceService.shared.lastGraceMonitoringError ?? "none"
        let currentlyShielded = ManagedSettingsStore().shield.applications?.isEmpty == false
        return "Last granted: \(grantedAt)\nMonitoring error: \(error)\nCurrently shielded: \(currentlyShielded)"
    }
    #endif
}
