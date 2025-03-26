import SwiftUI
import MusicKit
import CoreData

struct MyPageView: View {
    @State private var diaryEntries: [MusicDiaryEntry] = []
    @State private var albumData: [Int: AlbumInfo] = [:]
    @State private var trackData: [Int: TrackInfo] = [:]
    
    @State private var albumsByMonth: [String: [AlbumInfo]] = [:]
    @State private var tracksByMonth: [String: [TrackInfo]] = [:]
    @State private var customMonthTitles: [String: String] = [:]
    @State private var isEditingTitle: [String: Bool] = [:]
    @State private var isHidden: Bool = false // 이미지 숨기기 상태
    @State private var hiddenMonths: [String: Bool] = [:] // 월별 숨김 여부 관리
    
//    let userId = UserInfo.shared.loginId
    
    var body: some View {
        VStack {
            greetingMessage
                .padding(.bottom, 20)
            
            monthAlbumsSection
        }
        .padding()
        .background(Color.white) // 배경 색상 설정 (밝은 배경)
        .onAppear {
            fetchDiaryEntries()
        }
    }
    
    private var greetingMessage: some View {
        HStack {
            Text("반가워요, 사용자님! 🌟")
                .font(.title3)
                .fontWeight(.semibold)
                .foregroundColor(.primary)
                .padding(.top, 10)
                .transition(.opacity)
            Spacer()
        }
    }
    
    // 👁‍🗨 이미지 숨기기 토글 버튼
    private var toggleImagesButton: some View {
        withAnimation(.easeInOut(duration: 0.3)) {
            Button(action: {
                isHidden.toggle() // 숨기기 상태 토글
            }) {
                Image(systemName: isHidden ? "eye.slash" : "eye")
                    .font(.title2)
                    .foregroundColor(.blue)
                    .padding()
            }
        }
    }
    
    private var monthAlbumsSection: some View {
        ScrollView {
            VStack {
                ForEach(albumsByMonth.keys.sorted(), id: \.self) { month in
                    VStack(alignment: .leading) {
                        titleWithEditButton(for: month)
                        
                        if hiddenMonths[month] != true {
                            LazyVGrid(columns: Array(repeating: GridItem(.flexible(), spacing: 8), count: 3), spacing: 8) {
                                albumViews(for: month)
                                trackViews(for: month)
                            }
                        }
                    }
                }
            }
        }
    }
    
    private func titleWithEditButton(for month: String) -> some View {
        HStack {
            if isEditingTitle[month] == true {
                TextField("월별 제목", text: Binding(
                    get: { customMonthTitles[month] ?? "\(month) Sound" },
                    set: { newTitle in customMonthTitles[month] = newTitle }
                ))
                .textFieldStyle(RoundedBorderTextFieldStyle())
                .padding(5)
            } else {
                Text(customMonthTitles[month] ?? "\(month) Sound")
                    .font(.headline)
                    .padding(.top, 5)
            }
            
            Spacer()
            
            HStack(spacing: 10) {  // 버튼들을 정렬
                Button(action: {
                    if isEditingTitle[month] == nil {
                        isEditingTitle[month] = false
                    }
                    isEditingTitle[month]?.toggle()
                }) {
                    Image(systemName: isEditingTitle[month] == true ? "checkmark.circle.fill" : "pencil.circle.fill")
                        .font(.title2)
                        .foregroundColor(.blue)
                }
                
                Button(action: {
                    if hiddenMonths[month] == nil {
                        hiddenMonths[month] = false
                    }
                    withAnimation(.easeInOut(duration: 0.3)) {
                        hiddenMonths[month]?.toggle()
                    }
                }) {
                    Image(systemName: hiddenMonths[month] == true ? "eye.slash" : "eye")
                        .font(.title2)
                        .foregroundColor(.blue)
                }
            }
        }
        .padding(.vertical, 5)  // 위아래 패딩 추가
    }
    
    private func albumViews(for month: String) -> some View {
        ForEach(albumsByMonth[month] ?? [], id: \.id) { album in
            albumView(for: album)
                .id(UUID())  // 고유한 ID
        }
    }

    private func albumView(for album: AlbumInfo) -> some View {
        VStack {
            loadImage(from: album.imageUrl ?? "")
            Text(album.name)
                .font(.caption)
                .foregroundColor(.secondary) // 색상 개선
                .multilineTextAlignment(.center)
                .lineLimit(1)
        }
        .frame(width: 120)
        .padding(.bottom, 5) // 카드 사이 간격
        .background(Color.white) // 카드 배경
        .cornerRadius(12) // 둥근 모서리
//        .shadow(radius: 5) // 그림자 추가
    }
    
    private func trackViews(for month: String) -> some View {
        ForEach(tracksByMonth[month] ?? [], id: \.id) { track in
            trackView(for: track)
        }
    }
    private func trackView(for track: TrackInfo) -> some View {
        VStack {
            if let imageUrl = track.imageUrl, !imageUrl.isEmpty {
                loadImage(from: imageUrl)
                    .frame(width: 80, height: 80) // 이미지 크기 고정
                    .padding(.top, 8) // 위쪽에 여백 추가
                    .clipped() // 이미지가 프레임을 넘치지 않게 자르기
            } else {
                Text("이미지 없음")
                    .frame(width: 80, height: 80) // 이미지 크기 고정
                    .padding(.bottom, 5)
            }
            Text(track.name)
                .font(.caption)
                .foregroundColor(.secondary)
                .multilineTextAlignment(.center)
                .lineLimit(1)
                .frame(width: 100) // 텍스트 크기 고정
        }
        .frame(width: 120) // 전체 너비 고정
        .padding(.bottom, 5)
        .background(Color.white) // 카드 배경
        .cornerRadius(12) // 둥근 모서리
//        .shadow(radius: 5) // 그림자 추가
    }

    private func loadImage(from url: String) -> some View {
        AsyncImage(url: URL(string: url)) { phase in
            switch phase {
            case .empty:
                ProgressView()
                    .progressViewStyle(CircularProgressViewStyle(tint: .accentColor))
                    .frame(width: 80, height: 80)
                    .padding(.top,8)
                    .clipped()
            case .success(let image):
                image.resizable()
                    .aspectRatio(contentMode: .fill) // 이미지 비율을 유지하면서 프레임에 맞게 조정
                    .frame(width: 80, height: 80) // 프레임 크기
                    .clipped() // 프레임을 넘지 않도록 자르기
                    .cornerRadius(8) // 둥근 모서리
            case .failure:
                Text("이미지 로드 실패")
                    .foregroundColor(.red)
                    .frame(width: 80, height: 80)
            @unknown default:
                EmptyView()
            }
        }
    }
    
    private func fetchDiaryEntries() {
        let context = PersistenceController.shared.container.viewContext
        let fetchRequest = NSFetchRequest<NSManagedObject>(entityName: "MusicDiaryEntryEntity")

        do {
            let entries = try context.fetch(fetchRequest)
            DispatchQueue.main.async {
                diaryEntries = entries.compactMap { object in
                    guard
                        let content = object.value(forKey: "content") as? String,
                        let emotions = object.value(forKey: "emotions") as? [String],
                        let createdAt = object.value(forKey: "createdAt") as? Date
                    else {
                        return nil
                    }

                    let albumId = object.value(forKey: "albumId") as? String
                    let trackId = object.value(forKey: "trackId") as? String

                    return MusicDiaryEntry(
                        id: object.objectID.hashValue,
                        content: content,
                        emotions: emotions,
                        albumId: albumId,
                        trackId: trackId,
                        createdAt: createdAt
                    )
                }

                for object in entries {
                    let createdAt = object.value(forKey: "createdAt") as? Date ?? Date()
                    if let albumId = object.value(forKey: "albumId") as? String {
                        fetchAlbumInfoFromAppleMusic(albumId: albumId, createdAt: createdAt)
                    } else if let trackId = object.value(forKey: "trackId") as? String {
                        fetchTrackInfoFromAppleMusic(trackId: trackId, createdAt: createdAt)
                    }
                }
            }
        } catch {
            print("❌ Core Data fetch 실패: \(error.localizedDescription)")
        }
    }
    private func formattedDate(_ date: Date) -> String {
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy-MM-dd HH:mm:ss"
        return formatter.string(from: date)
    }
    
    private func groupAlbumsByMonth(album: AlbumInfo, createdAt: String) {
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "yyyy-MM-dd HH:mm:ss"
        
        if let date = dateFormatter.date(from: createdAt) {
            let calendar = Calendar.current
            let month = calendar.monthSymbols[calendar.component(.month, from: date) - 1]
            let year = calendar.component(.year, from: date)
            let monthYear = "\(year)년 \(month)"
            
            DispatchQueue.main.async {
                var existingAlbums = albumsByMonth[monthYear] ?? []
                
                // 이미 추가된 앨범인지 확인 후 추가
                if !existingAlbums.contains(where: { $0.id == album.id }) {
                    existingAlbums.append(album)
                    albumsByMonth[monthYear] = existingAlbums
                }
            }
        } else {
            print("createdAt 값 변환 실패: \(createdAt)")
        }
    }
    
    private func groupTracksByMonth(track: TrackInfo, createdAt: String) {
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "yyyy-MM-dd HH:mm:ss"
        
        if let date = dateFormatter.date(from: createdAt) {
            let calendar = Calendar.current
            let month = calendar.monthSymbols[calendar.component(.month, from: date) - 1]
            let year = calendar.component(.year, from: date)
            let monthYear = "\(year)년 \(month)"
            
            DispatchQueue.main.async {
                var existingTracks = tracksByMonth[monthYear] ?? []
                
                // 이미 추가된 트랙인지 확인 후 추가
                if !existingTracks.contains(where: { $0.id == track.id }) {
                    existingTracks.append(track)
                    tracksByMonth[monthYear] = existingTracks
                }
            }
        } else {
            print("createdAt 값 변환 실패: \(createdAt)")
        }
    }

    private func fetchAlbumInfoFromAppleMusic(albumId: String, createdAt: Date) {
        Task {
            do {
                let request = MusicCatalogResourceRequest<MusicKit.Album>(matching: \.id, equalTo: MusicItemID(albumId))
                let response = try await request.response()
                if let album = response.items.first {
                    let artworkURL = album.artwork?.url(width: 200, height: 200)?.absoluteString
                    let info = AlbumInfo(id: albumId, name: album.title, imageUrl: artworkURL)
                    let formatted = formattedDate(createdAt)
                    groupAlbumsByMonth(album: info, createdAt: formatted)
                }
            } catch {
                print("Apple Music 앨범 정보 불러오기 실패: \(error)")
            }
        }
    }

    private func fetchTrackInfoFromAppleMusic(trackId: String, createdAt: Date) {
        Task {
            do {
                let request = MusicCatalogResourceRequest<MusicKit.Song>(matching: \.id, equalTo: MusicItemID(trackId))
                let response = try await request.response()
                if let track = response.items.first {
                    let artworkURL = track.artwork?.url(width: 200, height: 200)?.absoluteString
                    let info = TrackInfo(id: trackId, name: track.title, imageUrl: artworkURL)
                    let formatted = formattedDate(createdAt)
                    groupTracksByMonth(track: info, createdAt: formatted)
                }
            } catch {
                print("Apple Music 트랙 정보 불러오기 실패: \(error)")
            }
        }
    }
}
