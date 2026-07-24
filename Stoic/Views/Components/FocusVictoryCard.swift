import SwiftUI

struct FocusVictoryCard: View {
    let weekCount: Int
    let weeklyGoal: Int
    let streakDays: Int

    private var progress: Double {
        guard weeklyGoal > 0 else { return 0 }
        return min(Double(weekCount) / Double(weeklyGoal), 1)
    }

    var body: some View {
        PremiumCardView {
            HStack(spacing: 20) {
                ringView

                VStack(alignment: .leading, spacing: 6) {
                    SectionLabel(title: String(localized: "dashboard.focusVictories.title", bundle: LanguageService.currentBundle))

                    Text(String(format: String(localized: "dashboard.focusVictories.subtitle", bundle: LanguageService.currentBundle), weekCount))
                        .font(.system(size: 16, weight: .medium))
                        .foregroundStyle(Color.stoicTextPrimary)
                        .fixedSize(horizontal: false, vertical: true)

                    if streakDays > 1 {
                        HStack(spacing: 4) {
                            Image(systemName: "flame.fill")
                                .foregroundStyle(Color.stoicAccent)
                            Text(String(format: String(localized: "dashboard.focusVictories.streak", bundle: LanguageService.currentBundle), streakDays))
                                .foregroundStyle(Color.stoicTextSecondary)
                        }
                        .font(.system(size: 13, weight: .semibold))
                    }
                }
            }
        }
    }

    private var ringView: some View {
        ZStack {
            Circle()
                .stroke(Color.stoicTextSecondary.opacity(0.2), lineWidth: 8)

            Circle()
                .trim(from: 0, to: progress)
                .stroke(Color.stoicAccent, style: StrokeStyle(lineWidth: 8, lineCap: .round))
                .rotationEffect(.degrees(-90))
                .animation(.easeOut(duration: 0.6), value: progress)

            Text("\(weekCount)")
                .font(.system(size: 20, weight: .bold, design: .rounded))
                .foregroundStyle(Color.stoicTextPrimary)
                .contentTransition(.numericText())
        }
        .frame(width: 64, height: 64)
    }
}
