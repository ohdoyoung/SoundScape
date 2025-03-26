import Foundation
import MusicKit

class APIService {
    static let shared = APIService()
    private init() {}

    // 앨범 목록을 가져오는 함수
    func fetchAlbums(query: String, completion: @escaping (Result<[Album], Error>) -> Void) {
        Task {
            do {
                let request = MusicCatalogSearchRequest(term: query, types: [MusicKit.Album.self])
                let response = try await request.response()
                let albums = response.albums.map {
                    Album(id: $0.id.rawValue, name: $0.title, artistName: $0.artistName, imageURL: $0.artwork?.url(width: 300, height: 300)?.absoluteString ?? "")
                }
                DispatchQueue.main.async {
                    completion(.success(albums))
                }
            } catch {
                DispatchQueue.main.async {
                    completion(.failure(error))
                }
            }
        }
    }
}
