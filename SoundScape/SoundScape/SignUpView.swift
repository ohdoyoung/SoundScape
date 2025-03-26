//import SwiftUI
//
//struct SignupView: View {
//    
//    @State private var loginId: String = ""
//    @State private var password: String = ""
//    @State private var nickname: String = ""
//    @State private var errorMessage: String?
//    @State private var isSignupSuccessful = false // ✅ 회원가입 성공 여부
//    @Environment(\.dismiss) var dismiss // 뒤로 가기 기능을 위한 dismiss
//
//    
//    var body: some View {
//        NavigationStack{
//            ZStack {
//                Color(.systemGroupedBackground)
//                    .edgesIgnoringSafeArea(.all)
//                
//                VStack {
//                    Spacer()
//                    
//                    // 헤더
//                    VStack(spacing: 8) {
//                        Image(systemName: "person.badge.plus")
//                            .font(.system(size: 48))
//                            .foregroundColor(.blue)
//                        Text("회원가입")
//                            .font(.largeTitle)
//                            .fontWeight(.bold)
//                    }
//                    .padding(.bottom, 40)
//                    
//                    // 입력 필드
//                    VStack(spacing: 16) {
//                        CustomTextField(text: $loginId, placeholder: "아이디")
//                        CustomSecureField(text: $password, placeholder: "비밀번호")
//                        CustomTextField(text: $nickname, placeholder: "닉네임")
//                    }
//                    .padding(.horizontal)
//                    
//                    // 오류 메시지
//                    if let errorMessage = errorMessage {
//                        Text(errorMessage)
//                            .foregroundColor(.red)
//                            .font(.footnote)
//                            .padding(.top, 5)
//                            .transition(.opacity)
//                    }
//                    
//                    // 가입 버튼
//                    Button(action: signup) {
//                        Text("회원가입")
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
//                    Spacer()
//                        .navigationBarItems(leading: Button(action: {
//                            dismiss() // 뒤로 가기 버튼 동작
//                        }) {
//                            Image(systemName: "chevron.left") // 뒤로 가기 아이콘
//                                .font(.title)
//                                .foregroundColor(.blue)
//                        })
//                    // 푸터
//                    Text("© 2025 Soundscape")
//                        .font(.footnote)
//                        .foregroundColor(.gray)
//                        .padding(.bottom, 10)
//                }
//            }
//            .fullScreenCover(isPresented: $isSignupSuccessful) { // ✅ 회원가입 성공 시 로그인 화면으로 이동
//                LoginView()
//            }
//        }
//    }
//    func signup() {
//        let url = URL(string: "http://dhehdud456.cafe24.com/api/signup")!
////        let url = URL(string: "http://192.168.219.151:8085/api/signup")!
//
//        var request = URLRequest(url: url)
//        request.httpMethod = "POST"
//        
//        // POST 요청의 body에 전달할 데이터
//        let body = "loginId=\(loginId)&password=\(password)&nickname=\(nickname)"
//        request.httpBody = body.data(using: .utf8)
//        
//        // Content-Type 설정
//        request.setValue("application/x-www-form-urlencoded", forHTTPHeaderField: "Content-Type")
//        
//        let task = URLSession.shared.dataTask(with: request) { data, response, error in
//            DispatchQueue.main.async {
//                if let error = error {
//                    // 네트워크 에러 처리
//                    self.errorMessage = "회원가입 실패: \(error.localizedDescription)"
//                } else if let data = data {
//                    // 서버로부터 받은 응답 처리
//                    if let responseString = String(data: data, encoding: .utf8) {
//                        if responseString.contains("이미 존재하는 아이디입니다.") {
//                            // 중복된 아이디일 경우
//                            self.errorMessage = "이미 존재하는 아이디입니다."
//                        } else if responseString.contains("회원가입 성공!") {
//                            // 회원가입 성공 시
//                            self.isSignupSuccessful = true // 로그인 화면으로 이동
//                        } else {
//                            // 그 외의 상황에 대한 에러 처리
//                            
//                            self.errorMessage = "알 수 없는 오류가 발생했습니다.\n서버 응답: \(responseString)"
//                            print(errorMessage)
//                        }
//                    }
//                }
//            }
//        }
//        task.resume()
//    }
//}
//
