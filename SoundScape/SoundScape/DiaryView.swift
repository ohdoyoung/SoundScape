import SwiftUI
import CoreData

struct DiaryView: View {
    @State private var musicCalText = "" // 일기 내용
    @State private var selectedEmotions: Set<String> = [] // 선택된 감정들
    @State private var diaryBackground: Color = Color.blue.opacity(0.1) // 일기 배경 색상
    @FocusState private var isTextEditorFocused: Bool // ✅ 포커스 상태 추가
    @State private var keyboardHeight: CGFloat = 0 // ✅ 키보드 높이 저장
    @Environment(\.presentationMode) var presentationMode // ✅ 이전 화면으로 이동을 위한 변수 추가

    let maxVisibleRows = 5
    let emotions = ["🙂", "😊", "😎", "😢", "😜", "🥳", "🤩", "😇", "🤔", "🤯",
                    "😈", "😱", "😷", "😳", "🥺", "😴", "💪", "❤️", "🔥", "😂",
                    "😭", "🥶", "🤪", "😡", "💀"]
    @Binding var albumId: String?
    @Binding var trackId: String?

    var body: some View {
        VStack(alignment: .leading, spacing: 20) {
            ScrollView {
                VStack(alignment: .leading, spacing: 20) {
                    // 감정 선택 버튼
                    // 커스텀 TextEditor (키보드 닫기 버튼 포함)
                    CustomTextEditor(text: $musicCalText)
                        .frame(height: 200)
                        .overlay(
                            RoundedRectangle(cornerRadius: 12)
                                .stroke(Color.gray, lineWidth: 1)
                        )
                        .padding()
                        .focused($isTextEditorFocused)
                       
                    ScrollView(.vertical, showsIndicators: false) {
                        LazyVGrid(columns: Array(repeating: GridItem(.flexible(), spacing: 10), count: 5), spacing: 10) {
                            ForEach(emotions.prefix(maxVisibleRows * 5), id: \.self) { emotion in
                                EmotionButton(emotion: emotion, selectedEmotions: $selectedEmotions)
                            }
                        }
                        .padding()
                    }
                    .frame(height: CGFloat(maxVisibleRows) * 18)
                    .clipped()
                }
                .padding(.bottom, keyboardHeight) // ✅ 키보드 높이에 맞춰 아래 여백 추가
            }

            // 일기 저장 버튼
            Button(action: {
                let dateFormatter = DateFormatter()
                dateFormatter.dateFormat = "yyyy-MM-dd HH:mm:ss"
                let todayString = dateFormatter.string(from: Date())

//                let userId = UserInfo.shared.loginId
                let emotionsJson = Array(selectedEmotions)
                saveDiary(content: musicCalText, emotions: emotionsJson, date: todayString, trackId: trackId, albumId: albumId)
                
                presentationMode.wrappedValue.dismiss() // ✅ 버튼 클릭 시 이전 화면으로 이동
            }) {
                Text("Scape")
                    .font(.headline)
                    .padding()
                    .frame(maxWidth: .infinity)
                    .background(Color.accentColor)
                    .foregroundColor(.white)
                    .cornerRadius(12)
            }
            .padding()

        
        }
        .ignoresSafeArea(.keyboard, edges: .bottom) // ✅ 키보드가 올라와도 화면 하단에 가림
    }

    // 감정 아이콘 버튼
    func EmotionButton(emotion: String, selectedEmotions: Binding<Set<String>>) -> some View {
        Button(action: {
            if selectedEmotions.wrappedValue.contains(emotion) {
                selectedEmotions.wrappedValue.remove(emotion)
            } else {
                selectedEmotions.wrappedValue.insert(emotion)
            }
        }) {
            Text(emotion)
                .font(.title)
                .padding(8)
                .background(selectedEmotions.wrappedValue.contains(emotion) ? Color.accentColor : Color.gray.opacity(0.2))
                .cornerRadius(12)
                .foregroundColor(.primary)
        }
    }

    func saveDiary(content: String, emotions: [String], date: String, trackId: String?, albumId: String?) {
        let context = PersistenceController.shared.container.viewContext
        let newEntry = MusicDiaryEntryEntity(context: context)

        newEntry.id = UUID()
        newEntry.content = content
        newEntry.createdAt = Date()
        newEntry.emotions = emotions as NSArray
        newEntry.albumId = albumId
        newEntry.trackId = trackId

        do {
            try context.save()
            print("✅ Core Data에 일기 저장 성공")
        } catch {
            print("❌ Core Data 저장 실패: \(error.localizedDescription)")
        }
    }
}
