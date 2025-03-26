import SwiftUI
import MusicKit

struct AlbumDetailView: View {
    let album: Album
    @State private var showTracks = false
    @State private var musicKitAlbum: MusicKit.Album?
    @State private var tracks: [Track] = []
    @State private var albumId: String?

    var body: some View {
        ScrollView {
            VStack {
                // 앨범 썸네일 이미지
                AsyncImage(url: URL(string: album.imageURL)) { image in
                    image.resizable()
                        .scaledToFit()
                        .frame(height: 150)
                        .cornerRadius(12)
                        .shadow(radius: 5)
                } placeholder: {
                    ProgressView()
                }
                .padding()

                // 앨범 이름 표시
                Text(album.name)
                    .font(.title2)
                    .fontWeight(.bold)
                    .padding(.top, 5)

                Text(album.artistName)
                    .font(.subheadline)
                    .foregroundColor(.gray)

                // 트랙 보기 버튼
                Button(action: {
                    withAnimation {
                        showTracks.toggle()
                    }
                }) {
                    Text(showTracks ? "트랙 숨기기" : "트랙 보기")
                        .font(.subheadline)
                        .foregroundColor(.accentColor)
                        .padding(10)
                        .frame(maxWidth: 120, minHeight: 20)
                        .background(Color.white)
                        .cornerRadius(12)
                        .shadow(radius: 5)
                }
                .padding(.top, 20)

                if showTracks {
                    List(tracks, id: \.id) { track in
                        HStack {
                            VStack(alignment: .leading) {
                                Text(track.title)
                                    .font(.headline)
                                Text(track.artistName)
                                    .font(.subheadline)
                                    .foregroundColor(.gray)
                            }
                            Spacer()
                        }
                    }
                    .frame(height: 300)
                    .padding(.top, 10)
                }

                Spacer()

                DiaryView(albumId: $albumId, trackId: .constant(nil))
                    .padding()
            }
        }
        .onAppear {
            albumId = album.id
            fetchAlbumDetails()
        }
        .navigationBarTitle("앨범 상세", displayMode: .inline)
    }

    func fetchAlbumDetails() {
        Task {
            do {
                let request = MusicCatalogResourceRequest<MusicKit.Album>(matching: \.id, equalTo: MusicItemID(album.id))
                let response = try await request.response()
                if let fetchedAlbum = response.items.first {
                    musicKitAlbum = fetchedAlbum
                    tracks = Array(fetchedAlbum.tracks ?? [])                }
            } catch {
                print("앨범 상세 불러오기 실패: \(error)")
            }
        }
    }
}
