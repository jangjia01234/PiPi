//
//  OnboardingLastPageView.swift
//  PiPi
//
//  Created by 신혜연 on 7/30/24.
//

import SwiftUI

struct OnboardingProfileView: View {
    
    @State private var nickname: String = ""
    @State private var password: String = ""
    @State private var affiliation: Affiliation = .postech
    @State private var email: String = ""
    @State private var isButtonEnabled: Bool = false
    
    var body: some View {
        NavigationStack {
            VStack(spacing: 78) {
                Text("회원가입")
                    .font(.system(size: 28))
                    .bold()
                    .multilineTextAlignment(.center)
                    .fixedSize(horizontal: false, vertical: true)
                    .frame(maxWidth: .infinity, alignment: .leading)
                
                UserDataEntryView(
                    nickname: $nickname,
                    password: $password,
                    affiliation: $affiliation,
                    email: $email
                )
                .padding(.bottom, 30)
                
                Button {
                    saveProfile()
                } label: {
                    Text("완료")
                        .fontWeight(.bold)
                        .foregroundColor(.white)
                        .frame(width: 332, height: 48)
                        .background(isButtonEnabled ? .sub : Color.secondary)
                        .cornerRadius(10)
                }
                .disabled(!isButtonEnabled)
            }
            .frame(maxHeight: .infinity)
            .padding()
            .onChange(of: [nickname, email]) {
                validateForm()
            }
            .toolbar {
                ToolbarItemGroup(placement: .keyboard) {
                    Spacer()
                    Button("완료") {
                        UIApplication.shared.sendAction(#selector(UIResponder.resignFirstResponder), to: nil, from: nil, for: nil)
                    }
                    .foregroundColor(.sub)
                }
            }
        }
    }
    
    private func validateForm() {
        isButtonEnabled = !nickname.isEmpty && !email.isEmpty
    }
    
    private func saveProfile() {
        let profile = UserProfile(
            nickname: nickname,
            affiliation: affiliation,
            email: email
        )
        
        do {
            try FirebaseDataManager.shared.addData(profile, type: .user, id: profile.id)
            print("UserProfile 저장 성공")
            UserDefaults.standard.setValue(profile.id, forKey: "userID")
        } catch {
            print("UserProfile 저장 실패: \(error)")
        }
    }
    
}

#Preview {
    OnboardingProfileView()
}
