import Foundation

final class HealthMapService {
    // v1: loads bundled data. Wire a live API here in v2.
    func fetchCases() async throws -> [CaseLocation] {
        guard let url = Bundle.main.url(forResource: "fallback_cases", withExtension: "json"),
              let data = try? Data(contentsOf: url),
              let cases = try? JSONDecoder().decode([CaseLocation].self, from: data)
        else {
            throw URLError(.cannotDecodeContentData)
        }
        return cases
    }
}
