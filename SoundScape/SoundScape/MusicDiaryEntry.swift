import Foundation

struct MusicDiaryEntry: Identifiable {
    let id: Int
    let content: String
    let emotions: [String]
    let albumId: String?
    let trackId: String?
    let createdAt: Date
}
