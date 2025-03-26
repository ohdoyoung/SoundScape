private func emotionToText(_ emoji: String) -> String {
    switch emoji {
    case "😊", "🙂", "😇": return "Happy"
    case "😭", "😢", "🥺": return "Sad"
    case "😡", "🤬": return "Angry"
    case "🥰", "❤️": return "Love"
    case "😴": return "Sleep"
    case "🎉", "🥳": return "Celebration"
    case "🌧": return "Rainy"
    case "🌙": return "Night"
    case "🔥": return "Energetic"
    case "💤": return "Relax"
    case "🤩", "😎": return "Cool"
    case "😱": return "Surprised"
    case "😷": return "Sick"
    case "😳": return "Shy"
    case "💪": return "Strong"
    case "😂": return "Funny"
    case "🥶": return "Cold"
    case "🤪": return "Crazy"
    case "🤔": return "Think"
    case "🤯": return "Mindblown"
    case "😜": return "Playful"
    case "😈": return "Devilish"
    case "💀": return "Dark"
    default: return "Mood"
    }
}
import SwiftUI
import CoreData
import MusicKit

struct CalendarView: View {
    @State private var selectedDate = Date()
    @State private var diaryEntries: [MusicDiaryEntry] = []
    @State private var albumData: [Int: AlbumInfo] = [:]
    @State private var trackData: [Int: TrackInfo] = [:]
    @State private var recommendedTracks: [RecommendedTrack] = [] // 추천 트랙
    @State private var visibleTrackId: Int? = nil // 각 일기마다 추천 트랙을 보여줄지 여부를 다르게 설정
    @State private var albumsByMonth: [String: [AlbumInfo]] = [:]
    @State private var tracksByMonth: [String: [TrackInfo]] = [:]

    @Environment(\.managedObjectContext) private var viewContext

    // @FetchRequest removed in favor of manual fetch in onAppear
    
//    let userId = UserInfo.shared.loginId
    
    var body: some View {
        VStack {
            DatePicker("날짜 선택", selection: $selectedDate, displayedComponents: .date)
                .datePickerStyle(GraphicalDatePickerStyle())
                .padding(.horizontal)
                .background(Color.white)
                .cornerRadius(10)
            
            List {
                let filteredEntries = filterDiaryEntries()
                
                ForEach(filteredEntries, id: \.id) { entry in
                    VStack(alignment: .leading, spacing: 12) {
                        diaryEntryView(entry)
                        
                       // 추천 트랙 기 버튼
                        Button(action: {
                            if visibleTrackId == entry.id {
                                visibleTrackId = nil
                            } else {
                                visibleTrackId = entry.id
                                Task {
                                    await recommendTracks(for: entry.emotions)
                                }
                            }
                        }) {
                            Text(visibleTrackId == entry.id ? "추천 트랙 숨기기" : "추천 트랙 보기")
                                .font(.subheadline)
                                .foregroundColor(.blue)
                                .padding(.top, 5)
                        }
                        
                        // 추천 트랙 리스트 표시
                        if let visibleTrackId = visibleTrackId, visibleTrackId == entry.id {
                            recommendedTracksList
                        }
                    }
                    .padding(.vertical, 10)
                }
            }
            .overlay(
                diaryEntries.isEmpty ? Text("작성된 음악 일기가 없습니다")
                    .foregroundColor(.gray)
                    .italic() : nil
            )
            .listStyle(PlainListStyle())
        }
        .onAppear {
            let fetchRequest = NSFetchRequest<NSManagedObject>(entityName: "MusicDiaryEntryEntity")
            do {
                let entries = try viewContext.fetch(fetchRequest)
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

                    if let albumId = albumId {
                        fetchAlbumInfoFromAppleMusic(albumId: albumId, createdAt: createdAt)
                    } else if let trackId = trackId {
                        fetchTrackInfoFromAppleMusic(trackId: trackId, createdAt: createdAt)
                    }

                    return MusicDiaryEntry(
                        id: object.objectID.hashValue,
                        content: content,
                        emotions: emotions,
                        albumId: albumId,
                        trackId: trackId,
                        createdAt: createdAt
                    )
                }
            } catch {
                print("❌ Core Data fetch 실패: \(error.localizedDescription)")
            }
        }
    }
    
    
    private func diaryEntryView(_ entry: MusicDiaryEntry) -> some View {
        HStack(spacing: 16) {
            if let albumId = entry.albumId {
                let calendar = Calendar.current
                let month = calendar.monthSymbols[calendar.component(.month, from: entry.createdAt) - 1]
                let year = calendar.component(.year, from: entry.createdAt)
                let monthYear = "\(year)년 \(month)"
                if let albums = albumsByMonth[monthYear],
                   let album = albums.first(where: { $0.id == albumId }) {
                    loadImage(from: album.imageUrl, size: 60)
                    VStack(alignment: .leading, spacing: 8) {
                        Text(album.name ?? "앨범 이름 없음")
                            .font(.headline)
                        Text(entry.content)
                            .font(.body)
                            .foregroundColor(.gray)
                            .lineLimit(3)
                        if !entry.emotions.isEmpty {
                            emotionTagsView(entry.emotions)
                        }
                    }
                } else {
                    defaultTextView(entry)
                }
            } else if let trackId = entry.trackId {
                let allTracks = tracksByMonth.values.flatMap { $0 }
                if let track = allTracks.first(where: { $0.id == trackId }) {
                    loadImage(from: track.imageUrl, size: 60)
                    VStack(alignment: .leading, spacing: 8) {
                        Text(track.name ?? "트랙 이름 없음")
                            .font(.headline)
                        Text(entry.content)
                            .font(.body)
                            .foregroundColor(.gray)
                            .lineLimit(3)
                        if !entry.emotions.isEmpty {
                            emotionTagsView(entry.emotions)
                        }
                    }
                } else {
                    defaultTextView(entry)
                }
            } else {
                defaultTextView(entry)
            }
            Spacer()
        }
        .padding(16)
        .background(Color.white)
        .cornerRadius(12)
        .shadow(radius: 2)
    }
    
    private func emotionTagsView(_ emotions: [String]) -> some View {
        HStack(spacing: 8) {
            ForEach(emotions, id: \.self) { emotion in
                Text(emotion)
                    .font(.footnote)
                    .foregroundColor(.white)
                    .padding(6)
                    .background(Capsule().fill(Color.blue.opacity(0.2)))
            }
        }
    }
    
    private func filterDiaryEntries() -> [MusicDiaryEntry] {
        return diaryEntries.filter {
            Calendar.current.isDate($0.createdAt, inSameDayAs: selectedDate)
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
    
    private func loadImage(from url: String?, size: CGFloat) -> some View {
        AsyncImage(url: URL(string: url ?? "")) { phase in
            switch phase {
            case .empty:
                ProgressView()
                    .progressViewStyle(CircularProgressViewStyle())
            case .success(let image):
                image.resizable()
                    .scaledToFit()
                    .frame(width: size, height: size)
                    .cornerRadius(8)
            case .failure:
                Image(systemName: "photo")
                    .resizable()
                    .scaledToFit()
                    .frame(width: size, height: size)
                    .foregroundColor(.gray)
            @unknown default:
                EmptyView()
            }
        }
    }
    
    private func formattedDate(_ date: Date) -> String {
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy-MM-dd HH:mm:ss"
        return formatter.string(from: date)
    }
    
    private func stringToDate(_ string: String) -> Date? {
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy-MM-dd HH:mm:ss"
        return formatter.date(from: string)
    }
    
    private var recommendedTracksList: some View {
        ScrollView(.horizontal, showsIndicators: false) {
            HStack(spacing: 16) {
                ForEach(recommendedTracks, id: \.id) { track in
                    VStack {
                        // 앨범 커버
                        AsyncImage(url: URL(string: track.imageUrl)) { phase in
                            switch phase {
                            case .empty:
                                ProgressView()
                                    .progressViewStyle(CircularProgressViewStyle())
                                    .frame(width: 150, height: 150)
                            case .success(let image):
                                image.resizable()
                                    .scaledToFit()
                                    .frame(width: 150, height: 150)
                                    .cornerRadius(12)
                            case .failure:
                                Image(systemName: "photo")
                                    .resizable()
                                    .scaledToFit()
                                    .frame(width: 150, height: 150)
                                    .foregroundColor(.gray)
                            @unknown default:
                                EmptyView()
                            }
                        }
                        // 트랙 이름
                        Text(track.name)
                            .font(.headline)
                            .lineLimit(1)
                            .foregroundColor(.primary)
                        // 아티스트
                        Text(track.artistName)
                            .font(.subheadline)
                            .foregroundColor(.secondary)
                            .lineLimit(1)
                    }
                    .frame(width: 150)
                }
            }
            .padding(.horizontal)
        }
    }
    
    private func recommendTracks(for emotions: [String]) async {
        var collectedTracks: [RecommendedTrack] = []

    for emotion in emotions {
        let keyword = emotionToText(emotion) + " music"
        let request = MusicCatalogSearchRequest(term: keyword, types: [MusicKit.Song.self])
        do {
            let response = try await request.response()
            let songs = (response.songs ?? []).prefix(3)

            for song in songs {
                let track = RecommendedTrack(
                    id: song.id.rawValue,
                    name: song.title,
                    artistName: song.artistName,
                    imageUrl: song.artwork?.url(width: 300, height: 300)?.absoluteString ?? ""
                )
                collectedTracks.append(track)
            }
        } catch {
            print("❌ 추천 트랙 검색 실패: \(error.localizedDescription)")
        }
    }

        DispatchQueue.main.async {
            self.recommendedTracks = collectedTracks
        }
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
                if !existingTracks.contains(where: { $0.id == track.id }) {
                    existingTracks.append(track)
                    tracksByMonth[monthYear] = existingTracks
                }
            }
        } else {
            print("createdAt 값 변환 실패: \(createdAt)")
        }
    }

    private func defaultTextView(_ entry: MusicDiaryEntry) -> some View {
        VStack(alignment: .leading, spacing: 8) {
            Text(entry.content)
                .font(.body)
                .foregroundColor(.gray)
                .lineLimit(3)
            if !entry.emotions.isEmpty {
                emotionTagsView(entry.emotions)
            }
        }
    }
}
