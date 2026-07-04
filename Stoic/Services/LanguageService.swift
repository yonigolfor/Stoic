import Foundation

enum AppLanguage: String {
    case hebrew = "he"
    case english = "en"
}

final class LanguageService {
    static var isHebrew: Bool {
        PersistenceService.shared.preferredLanguage == AppLanguage.hebrew.rawValue
    }

    static func detectOnFirstLaunch() {
        guard PersistenceService.shared.preferredLanguage == nil else { return }
        let code = Locale.preferredLanguages.first?.hasPrefix("he") == true
            ? AppLanguage.hebrew.rawValue
            : AppLanguage.english.rawValue
        PersistenceService.shared.preferredLanguage = code
        UserDefaults.standard.set([code], forKey: "AppleLanguages")
        UserDefaults.standard.synchronize()
    }
}
