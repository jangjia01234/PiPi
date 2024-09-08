//
//  OnboardingLastPageView.swift
//  PiPi
//
//  Created by 신혜연 on 7/30/24.
//

import SwiftUI

struct SignUpView: View {
    
    @EnvironmentObject private var appRootManager: AppRootManager
    @State private var nickname: String = ""
    @State private var password: String = ""
    @State private var affiliation: Affiliation = .postech
    @State private var email: String = ""
    @State private var isButtonEnabled: Bool = false
    @State private var passwordValid: Bool = true
    
    private let userDataManager = FirebaseDataManager<User>()
    
    var body: some View {
        NavigationStack {
            VStack {
                UserDataEntryView(
                    nickname: $nickname,
                    password: $password,
                    affiliation: $affiliation,
                    email: $email,
                    passwordValid: $passwordValid
                )

                Spacer()
                
                Button {
                    saveProfile()
                } label: {
                    Text("완료")
                        .fontWeight(.bold)
                        .foregroundColor(.white)
                        .frame(width: 332, height: 48)
                        .background(isButtonEnabled ? .accentColor : Color.secondary)
                        .cornerRadius(10)
                }
                .disabled(!isButtonEnabled)
            }
            .frame(maxHeight: .infinity)
            .padding()
            .onChange(of: [nickname, password, email]) {
                validateForm()
            }
            .onChange(of: password) { newPassword in
                passwordValid = validatePassword(newPassword)
            }
            .navigationTitle("회원가입")
            .toolbar {
                ToolbarItemGroup(placement: .keyboard) {
                    Spacer()
                    Button("완료") {
                        UIApplication.shared.sendAction(#selector(UIResponder.resignFirstResponder), to: nil, from: nil, for: nil)
                    }
                    .foregroundColor(.accentColor)
                }
            }
        }
    }
    
    private func validateForm() {
        isButtonEnabled = !nickname.isEmpty && !email.isEmpty && validatePassword(password)
    }
    
    private func validatePassword(_ password: String) -> Bool {
        if password.isEmpty {
               return false
           }
        
        let passwordRegEx = "^(?=.*[A-Z])(?=.*[0-9])(?=.*[a-z]).{8,}$"
        let predicate = NSPredicate(format: "SELF MATCHES %@", passwordRegEx)
        return predicate.evaluate(with: password)
    }
    
    private func saveProfile() {
        let profile = User(
            nickname: nickname,
            affiliation: affiliation,
            email: email
        )
        
        do {
            try userDataManager.addData(profile, id: profile.id)
            UserDefaults.standard.setValue(profile.id, forKey: "userID")
        } catch {
            dump(error)
        }
    }
    
}

#Preview {
    SignUpView()
}
