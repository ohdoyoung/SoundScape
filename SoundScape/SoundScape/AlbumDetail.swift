//import Foundation
//
//struct AlbumDetails: Identifiable, Decodable {
//    let id = UUID() // 이건 SwiftUI에서 사용할 수 있게 추가한 유니크 아이디입니다.
//    let name: String
//    let artist: [Artist]?
//    let tracks: Tracks
//
//}
//
//struct Tracks: Codable {
//    let items: [Track] // items라는 배열을 포함하는 객체
//}
//
//struct Track: Codable, Identifiable {
//    let id: String
//    let name: String
//    let artists: [Artist]
//    
//    var artistNames: String {
//        artists.map { $0.name }.joined(separator: ", ")
//    }
//}
//
//struct MusicTrack: Codable,Identifiable {
//    let id: String   // ✅ 고유 ID 추가
//
//    let name: String
//    let artists: [Artist]
//    let album: Album
//
//    var artistName: String {
//        artists.first?.name ?? "Unknown Artist"
//    }
//
//    var albumName: String {
//        album.name
//    }
//
//    var imageUrl: String {
//        album.firstImageURL
//    }
//}
