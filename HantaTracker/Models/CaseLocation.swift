import Foundation

enum Severity: String, Codable {
    case high
    case elevated
    case monitoring
}

struct CaseLocation: Identifiable, Codable {
    let id: String
    let country: String
    let region: String?
    let latitude: Double
    let longitude: Double
    let confirmedCount: Int?
    let severity: Severity
    let lastUpdated: String
    let description: String
    let sourceURL: String?
}
