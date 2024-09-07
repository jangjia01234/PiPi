//
//  UserDataEntryView.swift
//  PiPi
//
//  Created by 정상윤 on 8/13/24.
//

import SwiftUI

struct UserDataEntryView: View {
    
    @State private var showEmailTip = false
    //@State private var passwordValid = true
    
    @Binding var nickname: String
    @Binding var password: String
    @Binding var affiliation: Affiliation
    @Binding var email: String
    @Binding var passwordValid: Bool
    
    var body: some View {
        VStack(spacing: 16) {
            emailDataEntry
            passwordDataEntry
            nicknameDataEntry
            affiliationDataEntry
        }
    }
    
    private var passwordDataEntry: some View {
        VStack {
            Text("비밀번호")
                .frame(maxWidth: .infinity, alignment: .leading)
                .font(.headline)
            SecureField("비밀번호를 입력해주세요.", text: $password)
                .setAppearance()
                .keyboardType(.default)
            Text("* 비밀번호는 8자 이상, 대문자, 소문자, 숫자를 포함해야 합니다.")
                .frame(maxWidth: .infinity, alignment: .leading)
                .font(.system(size: 12))
                .foregroundColor(password.isEmpty || passwordValid ? .gray : .red)
                .padding(.leading, 10)
        }
    }
    
    private var nicknameDataEntry: some View {
        VStack {
            Text("닉네임")
                .frame(maxWidth: .infinity, alignment: .leading)
                .font(.headline)
            TextField("닉네임을 입력해주세요.", text: $nickname)
                .setAppearance()
                .keyboardType(.default)
        }
    }
    
    private var affiliationDataEntry: some View {
        VStack {
            Text("소속")
                .frame(maxWidth: .infinity, alignment: .leading)
                .font(.headline)
            Picker("소속을 선택해주세요.", selection: $affiliation) {
                ForEach(Affiliation.allCases, id: \.self) { affiliation in
                    Text(affiliation.rawValue)
                        .tag(affiliation)
                }
            }
            .pickerStyle(.segmented)
        }
    }
    
    private var emailDataEntry: some View {
        VStack {
            HStack {
                Text("이메일")
                    .font(.headline)
                Button(action: {
                    showEmailTip = true
                }) {
                    Image(systemName: "questionmark.circle")
                }
                .popover(isPresented: $showEmailTip) {
                    Text("iMessage 사용을 위해 꼭 애플 계정 이메일을 입력해주세요!")
                        .presentationCompactAdaptation(.popover)
                }
            }
            .frame(maxWidth: .infinity, alignment: .leading)
            
            TextField("애플 계정 이메일을 입력해주세요.", text: $email)
                .setAppearance()
                .keyboardType(.emailAddress)
        }
    }
}

// Fix: fileprivate -> public으로 전환
extension View {
    
    func setAppearance() -> some View {
        self.font(.body)
            .padding(EdgeInsets(top: 5, leading: 10, bottom: 5, trailing: 10))
            .textFieldStyle(PlainTextFieldStyle())
            .autocapitalization(.none)
            .background(Color(.systemGray6))
            .clipShape(RoundedRectangle(cornerRadius: 8))
    }
    
}

#Preview {
    UserDataEntryView(
        nickname: .constant(""), password: .constant(""), affiliation: .constant(.postech), email: .constant(""), passwordValid: .constant(true)
    )
}
