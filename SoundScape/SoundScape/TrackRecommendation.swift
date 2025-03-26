import Foundation

struct RecommendedTrack: Identifiable, Codable {
    let id: String
    let name: String
    let artistName: String
    let imageUrl: String
}

struct RecommendationResponse: Codable {
    let tracks: [RecommendedTrack]
}
