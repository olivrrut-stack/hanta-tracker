import Foundation

final class NewsService {
    func fetchNews(country: String) async -> [NewsArticle] {
        guard Config.gNewsAPIKey != "YOUR_GNEWS_API_KEY_HERE" else { return [] }

        let query = "hantavirus \(country)"
            .addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed) ?? "hantavirus"

        let urlString = "https://gnews.io/api/v4/search?q=\(query)&lang=en&max=5&sortby=publishedAt&apikey=\(Config.gNewsAPIKey)"
        guard let url = URL(string: urlString) else { return [] }

        do {
            let (data, response) = try await URLSession.shared.data(from: url)
            guard (response as? HTTPURLResponse)?.statusCode == 200 else { return [] }
            let decoded = try JSONDecoder().decode(GNewsResponse.self, from: data)
            return decoded.articles
        } catch {
            return []
        }
    }
}
