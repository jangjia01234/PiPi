//
//  OnboardingLastPageView.swift
//  PiPi
//
//  Created by 신혜연 on 7/30/24.
//

import SwiftUI

struct OnboardingProfileView: View {
    
    @State private var nickname: String = ""
    @State private var affiliation: String = ""
    @State private var email: String = ""
    @State private var level: Int = 1
    @State private var isButtonEnabled: Bool = false
    
    let affiliations = Affiliation.allCases.map { $0.rawValue }
    
    var body: some View {
        NavigationStack {
            ScrollView {
                VStack {
                    Text("프로필을\n 설정해주세요!")
                        .multilineTextAlignment(.center)
                        .font(.title)
                        .fontWeight(.bold)
                        .padding(.vertical, 64)
                    
                    VStack(spacing: 8) {
                        Text("닉네임")
                            .frame(maxWidth: .infinity, alignment: .leading)
                            .font(.subheadline)
                            .bold()
                            .padding(.leading, 8)
                        
                        HStack {
                            TextField("닉네임을 입력해주세요.", text: $nickname)
                                .textFieldStyle(PlainTextFieldStyle())
                                .padding(EdgeInsets(top: 4, leading: 10, bottom: 4, trailing: 10))
                                .background(Color(UIColor.systemGray6))
                                .cornerRadius(8)
                                .font(.system(size: 16))
                                .padding(.horizontal, 10)
                                .onChange(of: nickname) {
                                    validateForm()
                                }
                        }
                        
                        HStack(spacing:0) {
                            Text("소속")
                                .font(.subheadline)
                                .bold()
                                .padding(.leading, 8)
                            Spacer()
                        }
                        
                        
                        Picker("소속을 선택해주세요.", selection: $affiliation) {
                            ForEach(affiliations, id: \.self) { affiliation in
                                Text(affiliation).tag(affiliation)
                            }
                        }
                        .pickerStyle(SegmentedPickerStyle())
                        .padding(.horizontal, 10)
                        .onChange(of: affiliation) {                            
                            validateForm()
                        }
                        
                        HStack(spacing:0) {
                            Text("이메일")
                                .font(.subheadline)
                                .bold()
                                .padding(.leading, 8)
                            Spacer()
                        }
                        
                        HStack(spacing: 4) {
                            TextField("이메일을 입력해주세요.", text: $email)
                                .textFieldStyle(PlainTextFieldStyle())
                                .padding(EdgeInsets(top: 4, leading: 10, bottom: 4, trailing: 10))
                                .autocapitalization(.none) // 첫 대문자 비활성화
                                .background(Color(UIColor.systemGray6))
                                .cornerRadius(8)
                                .font(.system(size: 16))
                                .padding(.leading, 10)
                                .padding(.trailing, 4)
                                .onChange(of: email) {
                                    validateForm()
                                }
                            
                            Text("@icloud.com")
                                .font(.system(size: 14))
                        }
                        .padding(.trailing, 40)
                    }
                    .padding(.horizontal, 40)
                    .padding(.bottom, 25)
                    
                    Button {
                        saveProfile()
                    } label: {
                        Text("완료")
                            .fontWeight(.bold)
                            .foregroundColor(.white)
                            .frame(width: 332, height: 48)
                            .background(isButtonEnabled ? Color.orange : Color.secondary)
                            .cornerRadius(10)
                    }
                    .disabled(!isButtonEnabled)
                    .padding(.bottom, 186)
                }
                .toolbar {
                    ToolbarItemGroup(placement: .keyboard) {
                        Spacer()
                        Button("완료") {
                            UIApplication.shared.sendAction(#selector(UIResponder.resignFirstResponder), to: nil, from: nil, for: nil)
                        }
                        .foregroundColor(Color("SubColor"))
                    }
                }
                .navigationBarBackButtonHidden(true)
            }
        }
    }
    
    private func validateForm() {
        isButtonEnabled = !nickname.isEmpty && !email.isEmpty && !affiliation.isEmpty
    }
    
    private func saveProfile() {
        let userID = UUID().uuidString
        let profile = UserProfile(
            id: userID,
            nickname: nickname,
            affiliation: affiliation,
            email: "\(email)@icloud.com",
            level: level // 예시로 레벨을 기본값으로 설정
        )
        
        do {
            try FirebaseDataManager.shared.addData(profile, type: .user, id: profile.id)
            print("UserProfile 저장 성공")
            UserDefaults.standard.setValue(userID, forKey: "userID")
        } catch {
            print("UserProfile 저장 실패: \(error)")
        }
    }
}
