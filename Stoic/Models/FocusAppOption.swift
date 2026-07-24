import Foundation

/// Pre-selection chips shown before the real `FamilyActivityPicker` is authorized.
enum FocusAppOption: String, CaseIterable, Identifiable {
    case tiktok = "TikTok"
    case instagram = "Instagram"
    case snapchat = "Snapchat"
    case x = "X"
    case youtube = "YouTube"

    var id: String { rawValue }

    var systemImage: String {
        switch self {
        case .tiktok:    return "music.note"
        case .instagram: return "camera.aperture"
        case .snapchat:  return "bolt.fill"
        case .x:         return "xmark"
        case .youtube:   return "play.rectangle.fill"
        }
    }
}
