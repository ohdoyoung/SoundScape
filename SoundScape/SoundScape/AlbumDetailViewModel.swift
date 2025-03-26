//import Foundation
//
//class AlbumDetailViewModel: ObservableObject {
//    @Published var albumDetails: AlbumDetails?
//
//    func fetchAlbumDetails(albumID: String) {
//        // Spotify API 호출 로직 (예제)
//        let urlString = "https://api.spotify.com/v1/albums/\(albumID)"
//        
//        // ✅ 실제 API 호출 예제
//        URLSession.shared.dataTask(with: URL(string: urlString)!) { data, response, error in
//            guard let data = data, error == nil else {
//                print("데이터 가져오기 실패:", error?.localizedDescription ?? "Unknown error")
//                return
//            }
//            
//            do {
//                let decodedResponse = try JSONDecoder().decode(AlbumDetails.self, from: data)
//                DispatchQueue.main.async {
//                    self.albumDetails = decodedResponse
//                }
//            } catch {
//                print("JSON 디코딩 오류:", error.localizedDescription)
//            }
//        }.resume()
//    }
//}
