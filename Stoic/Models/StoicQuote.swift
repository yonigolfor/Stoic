import Foundation

struct StoicQuote: Codable, Identifiable {
    let text: String
    let author: String
    let category: String?
    let oneWordTitleEn: String?
    let oneWordTitleHe: String?
    let textHe: String?
    let authorHe: String?
    let emoji: String?

    var id: String { text }

    var localizedText: String { LanguageService.isHebrew ? (textHe ?? text) : text }
    var localizedAuthor: String { LanguageService.isHebrew ? (authorHe ?? author) : author }

    enum CodingKeys: String, CodingKey {
        case text, author, category, emoji
        case oneWordTitleEn = "one_word_title_en"
        case oneWordTitleHe = "one_word_title_he"
        case textHe         = "text_he"
        case authorHe       = "author_he"
    }
}

struct QuoteCollection: Codable {
    let quotes: [StoicQuote]
}
