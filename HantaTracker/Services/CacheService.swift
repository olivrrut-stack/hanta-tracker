import Foundation

final class CacheService {
    private let fileName = "cached_cases.json"

    private var cacheURL: URL {
        FileManager.default.urls(for: .cachesDirectory, in: .userDomainMask)[0]
            .appendingPathComponent(fileName)
    }

    func save(_ cases: [CaseLocation]) {
        guard let data = try? JSONEncoder().encode(cases) else { return }
        try? data.write(to: cacheURL)
    }

    func load() -> [CaseLocation]? {
        guard let data = try? Data(contentsOf: cacheURL),
              let cases = try? JSONDecoder().decode([CaseLocation].self, from: data)
        else { return nil }
        return cases
    }

    func lastUpdated() -> Date? {
        (try? cacheURL.resourceValues(forKeys: [.contentModificationDateKey]))?.contentModificationDate
    }
}
