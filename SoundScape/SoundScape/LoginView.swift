//import SwiftUI
//
//struct LoginView: View {
//    @State private var loginId: String = ""
//    @State private var password: String = ""
//    @State private var errorMessage: String?
//    @State private var showSignup = false // ✅ 회원가입 화면 여부
//    
//    @EnvironmentObject var userInfo: UserInfo
//
//    var body: some View {
//        NavigationStack { // ✅ NavigationStack 추가
//            ZStack {
//                Color(.systemGroupedBackground)
//                    .edgesIgnoringSafeArea(.all)
//                
//                VStack {
//                    Spacer()
//                    
//                    // 헤더
//                    VStack(spacing: 8) {
//                        Image(systemName: "music.note.list")
//                            .font(.system(size: 48))
//                            .foregroundColor(.blue)
//                        Text("사운드스케이프")
//                            .font(.largeTitle)
//                            .fontWeight(.bold)
//                    }
//                    .padding(.bottom, 40)
//                    
//                    // 로그인 입력 필드
//                    VStack(spacing: 16) {
//                        CustomTextField(text: $loginId, placeholder: "아이디")
//                        CustomSecureField(text: $password, placeholder: "비밀번호")
//                    }
//                    .padding(.horizontal)
//                    
//                    // 에러 메시지
//                    if let errorMessage = errorMessage {
//                        Text(errorMessage)
//                            .foregroundColor(.red)
//                            .font(.footnote)
//                            .padding(.top, 5)
//                            .transition(.opacity)
//                    }
//                    
//                    // 로그인 버튼
//                    Button(action: login) {
//                        Text("로그인")
//                            .font(.headline)
//                            .foregroundColor(.white)
//                            .frame(maxWidth: .infinity)
//                            .padding()
//                            .background(Color.blue)
//                            .clipShape(Capsule())
//                    }
//                    .padding(.horizontal)
//                    .padding(.top, 20)
//                    .shadow(radius: 3)
//                    
//                    // 회원가입 버튼 (✅ fullScreenCover로 변경)
//                    Button(action: { showSignup.toggle() }) {
//                        Text("회원가입")
//                            .font(.headline)
//                            .foregroundColor(.blue)
//                            .padding(.top, 10)
//                    }
//                    .fullScreenCover(isPresented: $showSignup) {
//                        SignupView()
//                    }
//                    
//                    Spacer()
//                    
//                    // 푸터
//                    Text("© 2025 Soundscape")
//                        .font(.footnote)
//                        .foregroundColor(.gray)
//                        .padding(.bottom, 10)
//                }
//            }
//            .fullScreenCover(isPresented: $userInfo.isLoggedIn) { // ✅ 로그인 성공 시 전체 화면 전환
//                TabbarView()
//            }
//        }
//    }
//
//    func login() {
//        let url = URL(string: "http://dhehdud456.cafe24.com/api/login")!
//        
////        let url = URL(string: "http://192.168.219.151:8085/api/login")!
//
//        var request = URLRequest(url: url)
//        request.httpMethod = "POST"
//        
//        let body = "loginId=\(loginId)&password=\(password)"
//        request.httpBody = body.data(using: .utf8)
//        
//        request.setValue("application/x-www-form-urlencoded", forHTTPHeaderField: "Content-Type")
//        
//        let task = URLSession.shared.dataTask(with: request) { data, response, error in
//            print(data)
//            DispatchQueue.main.async {
//                if let error = error {
//                    // 네트워크 오류 발생 시 처리
//                    self.errorMessage = "로그인 실패: \(error.localizedDescription)"
//                } else if let data = data {
//                    if let responseString = String(data: data, encoding: .utf8) {
//                        if responseString == "로그인 성공!" {
//                            // 로그인 성공 시 처리
//                            UserInfo.shared.loginId = self.loginId
//                            userInfo.isLoggedIn = true // ✅ 로그인 성공 시 isLoggedIn 변경 → fullScreenCover 트리거
//                        } else if responseString == "아이디 또는 비밀번호가 일치하지 않습니다." {
//                            // 로그인 실패 시 처리
//                            self.errorMessage = responseString
//                        } else {
//                            // 알 수 없는 응답 처리
//                            self.errorMessage = "알 수 없는 오류가 발생했습니다."
//                        }
//                    }
//                }
//            }
//        }
//        task.resume()
//    }
//}
//// ✨ 커스텀 입력 필드 (애플 스타일)
//struct CustomTextField: View {
//    @Binding var text: String
//    var placeholder: String
//    
//    var body: some View {
//        TextField(placeholder, text: $text)
//            .padding()
//            .background(Color.white)
//            .cornerRadius(12)
//            .shadow(color: Color.gray.opacity(0.2), radius: 3, x: 0, y: 2)
//            .autocapitalization(.none)
//    }
//}
//
//struct CustomSecureField: View {
//    @Binding var text: String
//    var placeholder: String
//    
//    var body: some View {
//        SecureField(placeholder, text: $text)
//            .padding()
//            .background(Color.white)
//            .cornerRadius(12)
//            .shadow(color: Color.gray.opacity(0.2), radius: 3, x: 0, y: 2)
//    }
//}
