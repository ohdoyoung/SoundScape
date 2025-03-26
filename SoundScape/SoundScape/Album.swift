import Foundation

// ✅ 앨범 개별 정보
struct Album: Identifiable {
    let id: String
    let name: String
    let artistName: String
    let imageURL: String
}

struct MusicTrack: Identifiable {
    let id: String
    let name: String
    let artistName: String
    let imageUrl: String
}
