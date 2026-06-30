import Foundation
import SwiftData

@Model
final class UserProfile {
    var id: UUID
    var name: String
    var profession: String
    var coreObstacle: String
    var createdAt: Date

    init(name: String, profession: String, coreObstacle: String) {
        self.id = UUID()
        self.name = name
        self.profession = profession
        self.coreObstacle = coreObstacle
        self.createdAt = Date()
    }
}

enum Profession: String, CaseIterable, Identifiable {
    case entrepreneur       = "Entrepreneur"
    case softwareEngineer   = "Software Engineer"
    case creativeProf       = "Creative Professional"
    case executive          = "Executive / Manager"
    case student            = "Student"
    case healthcare         = "Healthcare Professional"
    case educator           = "Educator"
    case other              = "Other"

    var id: String { rawValue }
}

enum CoreObstacle: String, CaseIterable, Identifiable {
    case focus            = "Focus"
    case workStress       = "Work Stress"
    case selfDiscipline   = "Self-Discipline"
    case emotionalControl = "Emotional Control"

    var id: String { rawValue }

    var quoteTag: String {
        switch self {
        case .focus:            return "focus"
        case .workStress:       return "work_stress"
        case .selfDiscipline:   return "discipline"
        case .emotionalControl: return "emotional_control"
        }
    }
}
