import Foundation

struct NewsArticle: Identifiable, Decodable {
    let id = UUID()
    let title: String
    let description: String?
    let url: String
    let publishedAt: String
    let source: NewsSource

    var publishedDate: String {
        let iso = ISO8601DateFormatter()
        iso.formatOptions = [.withInternetDateTime, .withFractionalSeconds]
        guard let date = iso.date(from: publishedAt) else { return publishedAt }
        let fmt = DateFormatter()
        fmt.dateStyle = .medium
        fmt.timeStyle = .none
        return fmt.string(from: date)
    }

    enum CodingKeys: String, CodingKey {
        case title, description, url, publishedAt, source
    }
}

struct NewsSource: Decodable {
    let name: String
}

struct GNewsResponse: Decodable {
    let articles: [NewsArticle]
}
