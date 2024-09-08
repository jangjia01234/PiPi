//
//  LoginView.swift
//  PiPi
//
//  Created by 신혜연 on 9/7/24.
//

import SwiftUI

struct LoginView: View {
    @State private var email: String = ""
    @State private var password: String = ""
    @State private var passwordValid: Bool = true
    @State private var isButtonEnabled: Bool = false
    
    var body: some View {
        NavigationStack {
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
                Button {
                    
                } label: {
                    Text("완료")
                        .fontWeight(.bold)
                        .foregroundColor(.white)
                        .frame(width: 332, height: 48)
                        .background(isButtonEnabled ? .accentColor : Color.secondary)
                        .cornerRadius(10)
                }
            }
            .padding()
            .navigationTitle("로그인")
        }
    }
    
}

#Preview {
    LoginView()
}
