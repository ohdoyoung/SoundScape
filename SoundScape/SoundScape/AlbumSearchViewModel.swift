import SwiftUI
import MusicKit

class AlbumSearchViewModel: ObservableObject {
    @Published var albums: [Album] = []
    @Published var tracks: [MusicTrack] = []  // ✅ 노래(트랙) 데이터 추가
    @Published var isLoading: Bool = false
    @Published var errorMessage: String? = nil

    func search(query: String) async {
        let status = await MusicAuthorization.request()
        guard status == .authorized else {
            DispatchQueue.main.async {
                self.errorMessage = "Apple Music 권한이 필요합니다."
                self.isLoading = false
            }
            return
        }
        isLoading = true
        Task {
            do {
                let request = MusicCatalogSearchRequest(term: query, types: [MusicKit.Album.self, Song.self])
                let response = try await request.response()

                let fetchedAlbums: [Album] = response.albums.map {
                    Album(id: $0.id.rawValue, name: $0.title, artistName: $0.artistName, imageURL: $0.artwork?.url(width: 300, height: 300)?.absoluteString ?? "")
                }

                let fetchedTracks: [MusicTrack] = (response.songs ?? []).map {
                    MusicTrack(id: $0.id.rawValue, name: $0.title, artistName: $0.artistName, imageUrl: $0.artwork?.url(width: 300, height: 300)?.absoluteString ?? "")
                }

                DispatchQueue.main.async {
                    self.albums = fetchedAlbums
                    self.tracks = fetchedTracks
                    self.errorMessage = nil
                    self.isLoading = false
                }
            } catch {
                DispatchQueue.main.async {
                    self.errorMessage = "Apple Music 검색 실패: \(error.localizedDescription)"
                    self.isLoading = false
                }
            }
        }
    }
}
