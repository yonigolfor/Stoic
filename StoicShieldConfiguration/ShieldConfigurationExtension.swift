import ManagedSettings
import ManagedSettingsUI
import UIKit

// Make sure that your class name matches the NSExtensionPrincipalClass in your Info.plist.
class ShieldConfigurationExtension: ShieldConfigurationDataSource {
    override func configuration(shielding application: Application) -> ShieldConfiguration {
        Self.stoicConfiguration()
    }

    override func configuration(shielding application: Application, in category: ActivityCategory) -> ShieldConfiguration {
        Self.stoicConfiguration()
    }

    override func configuration(shielding webDomain: WebDomain) -> ShieldConfiguration {
        ShieldConfiguration()
    }

    override func configuration(shielding webDomain: WebDomain, in category: ActivityCategory) -> ShieldConfiguration {
        ShieldConfiguration()
    }

    // MARK: - Copy variations (randomized per shield presentation)

    private static let titles: [(en: String, he: String)] = [
        ("Is it intentional?", "האם זה מכוון?"),
        ("Your ancestors are watching...", "אבותיך צופים בך..."),
        ("Make your bloodline proud!", "עשה את השושלת שלך גאה!"),
        ("Are you master of your mind?", "האם אתה השליט על מוחך?"),
        ("Pause. Is this path chosen?", "עצור. האם הדרך הזו נבחרה?")
    ]

    private static let subtitles: [(en: String, he: String)] = [
        ("Do you plan to create or consume?", "האם תכננת ליצור או לצרוך?"),
        ("A Stoic controls their attention.", "אדם סטואי שולט בתשומת הלב שלו."),
        ("Trading your life for cheap dopamine?", "מחליף את החיים שלך בדופמין זול?"),
        ("Conquer your impulse before it conquers you.", "כבוש את הדחף שלך לפני שהוא יכבוש אותך."),
        ("Silence the noise. Reclaim your focus.", "השתק את הרעש. החזר את הפוקוס שלך.")
    ]

    private static let primaryButtonLabels: [(en: String, he: String)] = [
        ("Consult with Marcus Aurelius", "התייעץ עם מרקוס אורליוס"),
        ("Seek Stoic Wisdom", "בקש את חכמת הסטואים"),
        ("Enter the Reflection Chamber", "כנס לחדר ההתבוננות")
    ]

    /// `ShieldConfiguration` only accepts a single flat `backgroundColor` plus a system
    /// `backgroundBlurStyle` — there's no gradient/custom-view surface available here (confirmed
    /// against the ManagedSettingsUI interface). Midnight Purple (#120324) and Royal Neon Blue
    /// (#0B132B) are pre-blended into one color and layered under `.systemUltraThinMaterialDark`
    /// as the closest achievable approximation of the requested glassmorphism look.
    private static func stoicConfiguration() -> ShieldConfiguration {
        let isHebrew = UserDefaults(suiteName: "group.com.yonigolfor.Stoic")?.string(forKey: "preferredLanguage") == "he"

        let background = UIColor(red: 0.055, green: 0.014, blue: 0.086, alpha: 1) // blend of #120324 / #0B132B
        let accent = UIColor(red: 0.42, green: 0.36, blue: 0.98, alpha: 1) // royal neon blue-violet
        let textPrimary = UIColor(white: 0.97, alpha: 1)
        let textSecondary = UIColor(white: 0.68, alpha: 1)

        let title = titles.randomElement() ?? titles[0]
        let subtitle = subtitles.randomElement() ?? subtitles[0]
        let button = primaryButtonLabels.randomElement() ?? primaryButtonLabels[0]

        let icon = UIImage(
            systemName: "brain.head.profile",
            withConfiguration: UIImage.SymbolConfiguration(pointSize: 40, weight: .medium)
        )?.withTintColor(accent, renderingMode: .alwaysOriginal)

        return ShieldConfiguration(
            backgroundBlurStyle: .systemUltraThinMaterialDark,
            backgroundColor: background,
            icon: icon,
            title: ShieldConfiguration.Label(text: isHebrew ? title.he : title.en, color: textPrimary),
            subtitle: ShieldConfiguration.Label(text: isHebrew ? subtitle.he : subtitle.en, color: textSecondary),
            primaryButtonLabel: ShieldConfiguration.Label(text: isHebrew ? button.he : button.en, color: background),
            primaryButtonBackgroundColor: accent
        )
    }
}
