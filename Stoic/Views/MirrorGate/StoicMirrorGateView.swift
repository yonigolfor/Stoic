import SwiftUI

struct StoicMirrorGateView: View {
    @State private var viewModel = MirrorGateViewModel()
    @State private var showContent = false
    @State private var showUnlockedConfirmation = false
    let onStepBack: () -> Void
    let onContinue: () -> Void

    var body: some View {
        ZStack {
            Color.stoicBackground.ignoresSafeArea()

            cameraLayer
                .opacity(showContent && !showUnlockedConfirmation ? 1 : 0)
                .animation(.easeInOut(duration: 0.4), value: showContent)

            LinearGradient(
                colors: [.clear, Color.stoicBackground.opacity(0.9)],
                startPoint: .center,
                endPoint: .bottom
            )
            .ignoresSafeArea()
            .opacity(showUnlockedConfirmation ? 0 : 1)

            if showUnlockedConfirmation {
                unlockedConfirmation
                    .transition(.opacity.combined(with: .scale(scale: 0.92)))
            } else {
                VStack {
                    Spacer()
                    overlayContent
                }
            }
        }
        .animation(.easeInOut(duration: 0.35), value: showUnlockedConfirmation)
        .onAppear {
            viewModel.onAppear()
            withAnimation { showContent = true }
        }
        .onDisappear {
            viewModel.onDisappear()
        }
    }

    @ViewBuilder
    private var cameraLayer: some View {
        switch viewModel.camera.state {
        case .running:
            CameraPreviewView(session: viewModel.camera.session)
                .clipShape(RoundedRectangle(cornerRadius: 28, style: .continuous))
                .padding(.horizontal, 12)
                .padding(.top, 12)
        case .unauthorized, .unavailable:
            RoundedRectangle(cornerRadius: 28, style: .continuous)
                .fill(Color.stoicSurface)
                .padding(.horizontal, 12)
                .padding(.top, 12)
                .overlay {
                    Image(systemName: "camera.fill")
                        .font(.system(size: 32))
                        .foregroundStyle(Color.stoicTextSecondary)
                }
        case .idle, .configuring:
            Color.stoicSurface
        }
    }

    private var overlayContent: some View {
        VStack(spacing: 24) {
            Text(String(localized: "mirrorGate.title", bundle: LanguageService.currentBundle))
                .font(.system(size: 28, weight: .bold, design: .serif))
                .foregroundStyle(Color.stoicTextPrimary)
                .multilineTextAlignment(.center)

            Text(String(localized: "mirrorGate.subtitle", bundle: LanguageService.currentBundle))
                .font(.system(size: 17, weight: .regular))
                .foregroundStyle(Color.stoicTextSecondary)
                .multilineTextAlignment(.center)

            VStack(spacing: 14) {
                StoicButton(title: String(localized: "mirrorGate.stepBack", bundle: LanguageService.currentBundle)) {
                    viewModel.stepBack(onComplete: onStepBack)
                }

                Button(action: {
                    viewModel.continueAnyway(onComplete: presentUnlockedConfirmation)
                }) {
                    Text(String(localized: "mirrorGate.continueAnyway", bundle: LanguageService.currentBundle))
                        .font(.system(size: 15, weight: .regular))
                        .foregroundStyle(Color.stoicTextSecondary)
                }
                .buttonStyle(.plain)
            }
        }
        .padding(.horizontal, 24)
        .padding(.bottom, 40)
    }

    private var unlockedConfirmation: some View {
        VStack(spacing: 20) {
            ZStack {
                Circle()
                    .fill(Color.stoicAccent.opacity(0.15))
                    .frame(width: 96, height: 96)

                Image(systemName: "lock.open.fill")
                    .font(.system(size: 36, weight: .medium))
                    .foregroundStyle(Color.stoicAccent)
            }
            .scaleEffect(showUnlockedConfirmation ? 1 : 0.5)
            .animation(.spring(response: 0.45, dampingFraction: 0.6), value: showUnlockedConfirmation)

            Text(String(localized: "mirrorGate.unlocked.title", bundle: LanguageService.currentBundle))
                .font(.system(size: 24, weight: .bold, design: .serif))
                .foregroundStyle(Color.stoicTextPrimary)

            Text(String(localized: "mirrorGate.unlocked.subtitle", bundle: LanguageService.currentBundle))
                .font(.system(size: 15, weight: .regular))
                .foregroundStyle(Color.stoicTextSecondary)
                .multilineTextAlignment(.center)
        }
        .padding(.horizontal, 40)
    }

    /// There's no API to auto-detect or reopen the specific app the shield intercepted
    /// (Apple keeps that opaque for privacy), so this confirmation is the honest UI for
    /// what actually happened: the restriction is lifted, briefly, without pretending to
    /// hand the user off anywhere.
    private func presentUnlockedConfirmation() {
        showUnlockedConfirmation = true
        DispatchQueue.main.asyncAfter(deadline: .now() + 2.6) {
            onContinue()
        }
    }
}
