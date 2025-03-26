import SwiftUI

struct TabbarView: View {
    enum Tab {
        case a, b, c
    }
    
    @State private var selected: Tab = .c
    @State private var selectedDate: Date = Date()
    @State private var diaryEntries: [MusicDiaryEntry] = []
    
    var body: some View {
        ZStack(alignment: .bottom) { // ✅ 탭 바를 항상 아래에 고정
            TabView(selection: $selected) {
                NavigationStack {
                    AlbumSearchView()
                }
                .tag(Tab.a)
                
                NavigationStack {
                    CalendarView()
                }
                .tag(Tab.b)
                
                NavigationStack {
                    MyPageView()
                }
                .tag(Tab.c)
            }
            
            // ✅ 탭 바를 최하단에 고정
            tabBar
        }
        .ignoresSafeArea(edges: .bottom)
        .onAppear(perform: UIApplication.shared.addTapGestureRecognizer) // ✅ 아이폰 하단 부분까지 확장
    }
    
    var tabBar: some View {
        HStack {
            Spacer()
            
            Button {
                selected = .a
            } label: {
                Image(systemName: "magnifyingglass")
                    .resizable()
                    .scaledToFit()
                    .frame(width: 22)
            }
            .foregroundStyle(selected == .a ? Color.accentColor : Color.primary)
            
            Spacer()
            
            Button {
                selected = .b
            } label: {
                Image(systemName: "calendar")
                    .resizable()
                    .scaledToFit()
                    .frame(width: 22)
            }
            .foregroundStyle(selected == .b ? Color.accentColor : Color.primary)
            
            Spacer()
            
            Button {
                selected = .c
            } label: {
                Image(systemName: "house.fill")
                    .resizable()
                    .scaledToFit()
                    .frame(width: 22)
            }
            .foregroundStyle(selected == .c ? Color.accentColor : Color.primary)
            
            Spacer()
        }
        .padding()
        .frame(height: 72)
        .background {
            RoundedRectangle(cornerRadius: 24)
                .fill(Color.white)
                .shadow(color: .black.opacity(0.15), radius: 8, y: 2)
        }
        .padding(.horizontal)
        .ignoresSafeArea(.keyboard, edges: .bottom) // ✅ 키보드가 올라와도 탭 바를 숨기지 않음
    }
}
