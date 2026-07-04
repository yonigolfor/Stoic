import Foundation

enum AppLanguage: String {
    case hebrew = "he"
    case english = "en"
}

final class LanguageService {
    static var isHebrew: Bool {
        PersistenceService.shared.preferredLanguage == AppLanguage.hebrew.rawValue
    }

    // Bundle that always reflects the current preferredLanguage — works mid-session.
    static var currentBundle: Bundle {
        let code = PersistenceService.shared.preferredLanguage ?? AppLanguage.english.rawValue
        guard let path = Bundle.main.path(forResource: code, ofType: "lproj"),
              let bundle = Bundle(path: path) else { return .main }
        return bundle
    }

    static func detectOnFirstLaunch() {
        guard PersistenceService.shared.preferredLanguage == nil else { return }
        apply(detect())
    }

    // Re-detects from device locale and applies immediately (used on reset).
    static func redetect() {
        apply(detect())
    }

    private static func detect() -> String {
        Locale.preferredLanguages.first?.hasPrefix("he") == true
            ? AppLanguage.hebrew.rawValue
            : AppLanguage.english.rawValue
    }

    private static func apply(_ code: String) {
        PersistenceService.shared.preferredLanguage = code
        UserDefaults.standard.set([code], forKey: "AppleLanguages")
    }
}
