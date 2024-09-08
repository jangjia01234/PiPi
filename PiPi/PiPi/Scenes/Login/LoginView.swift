//
//  LoginView.swift
//  PiPi
//
//  Created by 신혜연 on 9/7/24.
//

import SwiftUI

struct LoginView: View {
    
    @EnvironmentObject private var appRootManager: AppRootManager
    @State private var email = ""
    @State private var password = ""
    @State private var showProgressView = false
    @State private var showLoginFailAlert = false
    @State private var loginError: LoginError? = nil
    
    var body: some View {
        NavigationStack {
            ZStack {
                VStack(spacing: 16) {
                    Text("이메일")
                        .frame(maxWidth: .infinity, alignment: .leading)
                        .font(.headline)
                    TextField("애플 계정 이메일을 입력해주세요.", text: $email)
                        .setFieldAppearance()
                        .keyboardType(.default)
                    Text("비밀번호")
                        .frame(maxWidth: .infinity, alignment: .leading)
                        .font(.headline)
                    SecureField("비밀번호를 입력해주세요.", text: $password)
                        .setFieldAppearance()
                        .keyboardType(.default)
                    
                    Spacer()
                    
                    Button(action: {
                        login()
                    }) {
                        Text("로그인")
                            .fontWeight(.bold)
                            .foregroundColor(.white)
                            .frame(width: 332, height: 48)
                            .background(.accent)
                            .cornerRadius(10)
                    }
                }
                .padding()
                
                if showProgressView {
                    ProgressView()
                        .setAppearance()
                }
            }
            .navigationTitle("로그인")
            .navigationBarTitleDisplayMode(.large)
            .alert(isPresented: $showLoginFailAlert) {
                Alert(
                    title: Text("로그인 실패"),
                    message: Text(loginError?.localizedDescription ?? ""),
                    dismissButton: .cancel(Text("확인"))
                )
            }
        }
    }
    
    private func login() {
        guard checkField() else { return }
        
        showProgressView = true
        Task {
            switch await FirebaseAuthManager.shared.signIn(
                email: email,
                password: password
            ) {
            case .success(_):
                appRootManager.currentRoot = .content
            case .failure(_):
                loginError = .loginFailed
                showLoginFailAlert = true
            }
            showProgressView = false
        }
    }
    
    private func checkField() -> Bool {
        guard !email.isEmpty else {
            loginError = .emailEmpty
            showLoginFailAlert = true
            return false
        }
        
        guard !password.isEmpty else {
            loginError = .passwordEmpty
            showLoginFailAlert = true
            return false
        }
        
        return true
    }
    
    enum LoginError: LocalizedError {
        
        case emailEmpty
        case passwordEmpty
        case loginFailed
        
        var errorDescription: String? {
            switch self {
            case .emailEmpty:
                return "이메일을 입력해주세요"
            case .passwordEmpty:
                return "비밀번호를 입력해주세요"
            case .loginFailed:
                return "아이디 또는 비밀번호가 일치하지 않습니다."
            }
        }
        
    }
    
}

#Preview {
    LoginView()
}
