import SwiftUI

struct AlbumSearchView: View {
    @StateObject private var viewModel = AlbumSearchViewModel()
    @State private var searchText = ""
    @State private var selectedAlbumID: String?
    @State private var selectedTrackID: String?

    var body: some View {
        NavigationStack {
            VStack {
                // 검색 입력 필드
                searchBar

                // 검색 결과 목록
                List {
                    if !viewModel.albums.isEmpty {
                        albumSection(viewModel.albums)
                    }

                    if !viewModel.tracks.isEmpty {
                        trackSection(viewModel.tracks)
                    }
                }
                .navigationTitle("앨범/노래 검색")
                .listStyle(PlainListStyle())
            }
            .background(Color.white) // 배경색 설정
        }
    }

    // ✅ 애플뮤직 스타일의 검색 바
    private var searchBar: some View {
        HStack {
            Image(systemName: "magnifyingglass")
                .foregroundColor(.gray)
            TextField("앨범/노래 검색", text: $searchText, onCommit: {
                print("🔍 검색 시작: \(searchText)")
                Task {
                    await viewModel.search(query: searchText)
                }
            })
            .textFieldStyle(PlainTextFieldStyle())
            .padding(10)
            .background(Color.white)
            .cornerRadius(8)
            .shadow(radius: 5)

        }
        .padding(.horizontal)
        .padding(.top, 20)
    }

    // ✅ 앨범 리스트 UI 분리
    private func albumSection(_ albums: [Album]) -> some View {
        Section {
            // 섹션 헤더
            Text("앨범")
                .font(.title2)
                .fontWeight(.bold)
                .foregroundColor(.primary)
                .padding(.top, 10)
                .padding(.bottom, 5)
                .background(Color.white) // 배경 색으로 구분을 줌
                .padding(.horizontal)
            
            // 앨범 항목 리스트
            ForEach(albums, id: \.id) { album in
                NavigationLink(
                    destination: AlbumDetailView(album: album),
                    tag: album.id,
                    selection: $selectedAlbumID
                ) {
                    albumRow(album)
                }
                .padding(.vertical, 8)
            }
        }
        .background(Color.white)
        .cornerRadius(12)
        .padding(.horizontal)
    }

    // ✅ 노래 리스트 UI 분리
    private func trackSection(_ tracks: [MusicTrack]) -> some View {
        Section {
            // 섹션 헤더
            Text("노래")
                .font(.title2)
                .fontWeight(.bold)
                .foregroundColor(.primary)
                .padding(.top, 10)
                .padding(.bottom, 5)
                .background(Color.white) // 배경 색으로 구분을 줌
                .padding(.horizontal)

            // 노래 항목 리스트
            ForEach(tracks, id: \.id) { track in
                NavigationLink(
                    destination: TrackDetailView(track: track),
                    tag: track.id,
                    selection: $selectedTrackID
                ) {
                    trackRow(track)
                }
                .padding(.vertical, 8)
            }
        }
        .background(Color.white)
        .cornerRadius(12)
        .padding(.horizontal)
    }

    // ✅ 앨범 UI 요소 분리
    private func albumRow(_ album: Album) -> some View {
        HStack(spacing: 15) {
            albumImage(url: album.imageURL)
                .frame(width: 100, height: 100)
                .cornerRadius(12)

            VStack(alignment: .leading) {
                Text(album.name)
                    .font(.title3)
                    .fontWeight(.semibold)
                    .foregroundColor(.primary)
                    .lineLimit(1)

                Text(album.artistName)
                    .font(.subheadline)
                    .foregroundColor(.gray)
                    .lineLimit(1)
            }

            Spacer()

            Button(action: { selectedAlbumID = album.id }) {
                Image(systemName: "plus.circle.fill")
                    .resizable()
                    .scaledToFit()
                    .frame(width: 24, height: 24)
                    .foregroundColor(.green)
            }
        }
    }

    // ✅ 노래 UI 요소 분리
    private func trackRow(_ track: MusicTrack) -> some View {
        HStack(spacing: 15) {
            albumImage(url: track.imageUrl)
                .frame(width: 60, height: 60)
                .cornerRadius(8)

            VStack(alignment: .leading) {
                Text(track.name)
                    .font(.title3)
                    .fontWeight(.semibold)
                    .foregroundColor(.primary)
                    .lineLimit(1)

                Text(track.artistName)
                    .font(.subheadline)
                    .foregroundColor(.gray)
                    .lineLimit(1)
            }

            Spacer()

            Button(action: { selectedTrackID = track.id }) {
                Image(systemName: "play.circle.fill")
                    .resizable()
                    .scaledToFit()
                    .frame(width: 24, height: 24)
                    .foregroundColor(.green)
            }
        }
    }

    // ✅ 이미지 뷰 분리
    private func albumImage(url: String) -> some View {
        AsyncImage(url: URL(string: url)) { image in
            image.resizable()
                .scaledToFill()
        } placeholder: {
            Color.gray
        }
        .frame(width: 60, height: 60)
        .clipShape(RoundedRectangle(cornerRadius: 8))
    }
}

// 커스텀 modifier로 상단 모서리 둥글게 만들기
struct RoundedTopCorners: ViewModifier {
    func body(content: Content) -> some View {
        content
            .clipShape(RoundedRectangle(cornerRadius: 12, style: .continuous))
            .overlay(
                RoundedRectangle(cornerRadius: 12)
                    .stroke(Color.gray.opacity(0.3), lineWidth: 1)
            )
    }
}

#Preview {
    AlbumSearchView()
}
