import Foundation

@MainActor
final class OutbreakViewModel: ObservableObject {
    @Published var cases: [CaseLocation] = []
    @Published var isLoading = false
    @Published var lastUpdated: Date?
    @Published var selectedCase: CaseLocation?
    @Published var news: [NewsArticle] = []
    @Published var isLoadingNews = false

    private let service = HealthMapService()
    private let cache = CacheService()
    private let newsService = NewsService()

    func load() async {
        isLoading = true
        do {
            let fetched = try await service.fetchCases()
            cases = fetched
            cache.save(fetched)
            lastUpdated = Date()
        } catch {
            if let cached = cache.load() {
                cases = cached
                lastUpdated = cache.lastUpdated()
            } else {
                cases = loadFallback()
                lastUpdated = nil
            }
        }
        isLoading = false
    }

    func fetchNews(for country: String) async {
        news = []
        isLoadingNews = true
        news = await newsService.fetchNews(country: country)
        isLoadingNews = false
    }

    func clearNews() {
        news = []
    }

    private func loadFallback() -> [CaseLocation] {
        guard let url = Bundle.main.url(forResource: "fallback_cases", withExtension: "json"),
              let data = try? Data(contentsOf: url),
              let cases = try? JSONDecoder().decode([CaseLocation].self, from: data)
        else { return [] }
        return cases
    }
}
