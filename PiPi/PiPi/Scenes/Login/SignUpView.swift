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
    @State private var showProgressView = false
    
    private let userDataManager = FirebaseDataManager<User>()
    
    var body: some View {
        NavigationStack {
            ZStack {
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
                        signUp()
                    } label: {
                        Text("완료")
                            .fontWeight(.bold)
                            .foregroundColor(.white)
                            .frame(width: 332, height: 48)
                            .background(isButtonEnabled ? .accentColor : Color.secondary)
                            .cornerRadius(10)
                    }
                    .disabled(!isButtonEnabled || showProgressView)
                }
                .frame(maxHeight: .infinity)
                .padding()
                
                if showProgressView {
                    ProgressView()
                        .setAppearance()
                }
            }
            .onChange(of: [nickname, password, email]) {
                validateForm()
            }
            .onChange(of: password) {
                passwordValid = validatePassword(password)
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
    
    private func signUp() {
        showProgressView = true
        Task {
            let result = await FirebaseAuthManager.shared.signUp(
                email: email,
                password: password
            )
            switch result {
            case .success(let user):
                saveUser(id: user.uid)
            case .failure(let error):
                dump(error)
            }
            showProgressView = false
        }
    }
    
    private func saveUser(id: String) {
        let user = User(
            id: id,
            nickname: nickname,
            affiliation: affiliation,
            email: email
        )
        do {
            try userDataManager.addData(user, id: id)
        } catch {
            dump(error)
        }
    }
    
}

#Preview {
    SignUpView()
}
