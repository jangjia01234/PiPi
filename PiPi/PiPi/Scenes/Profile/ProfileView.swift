//
//  ProfileView.swift
//  PiPi
//
//  Created by 신혜연 on 8/3/24.
//

import SwiftUI
import FirebaseDatabase

struct ProfileView: View {
    
    @State private var nickname: String = ""
    @State private var affiliation: Affiliation = .postech
    @State private var email: String = ""
    @State private var level: Int = 1
    @State private var isEditing: Bool = false
    
    @AppStorage("userID") var userID: String?  // @AppStorage로 UserDefaults로부터 값 불러올떄
    private let databaseManager = FirebaseDataManager.shared
    
    var body: some View {
        NavigationView {
            VStack(spacing: 0) {
                HStack {
                    Text("프로필")
                        .bold()
                        .font(.system(size: 28))
                        .padding(. leading, 23)
                    Spacer()
                }
                .padding(.bottom, 20)
                
                Divider()
                    .padding(.bottom, 13)
                
                HStack {
                    Spacer()
                    Button {
                        if isEditing {
                            saveProfile()
                        } else {
                            isEditing.toggle()
                        }
                    } label: {
                        Text(isEditing ? "완료" : "수정")
                            .fontWeight(isEditing ? .bold : .regular)
                            .padding(.trailing, 23)
                            .padding(.bottom, -10)
                            .foregroundColor(.accent)
                    }
                }
                
                if isEditing {
                    List {
                        Section {
                            EditableField(title: "닉네임", text: $nickname)
                            EditableField(title: "이메일", text: $email)
                        }
                        .listRowBackground(Color(.secondarySystemBackground))
                    }
                    .scrollContentBackground(.hidden)
                } else {
                    List {
                        Section {
                            HStack {
                                Text("닉네임")
                                    .frame(width: 60, alignment: .leading)
                                Text(nickname)
                                    .padding(.leading, 10)
                                Spacer()
                            }
                            
                            HStack {
                                Text("소속")
                                    .frame(width: 60, alignment: .leading)
                                Text(affiliation.rawValue)
                                    .padding(.leading, 10)
                                Spacer()
                            }
                            
                            HStack {
                                Text("이메일")
                                    .frame(width: 60, alignment: .leading)
                                Text(email)
                                    .padding(.leading, 10)
                                Spacer()
                            }
                            
                            HStack {
                                Text("레벨")
                                    .frame(width: 60, alignment: .leading)
                                Text("Lv.\(level)")
                                    .padding(.leading, 10)
                                Spacer()
                            }
                        }
                        .listRowBackground(Color(.secondarySystemBackground))
                    }
                    .scrollContentBackground(.hidden)
                }
            }
            .onAppear {
                if let userID = userID {
                    loadProfile(userID: userID)
                } else {
                    print("User ID is not set")
                }
            }
        }
        .navigationBarBackButtonHidden(true)
    }
    private func loadProfile(userID: String) {
        databaseManager.fetchData(type: .user, dataID: userID) { (result: Result<UserProfile, Error>) in
            switch result {
            case .success(let profile):
                DispatchQueue.main.async {
                    self.nickname = profile.nickname
                    self.affiliation = profile.affiliation
                    self.email = profile.email
                    self.level = profile.level
                }
            case .failure(let error):
                DispatchQueue.main.async {
                    print("Error fetching profile: \(error.localizedDescription)")
                }
            }
        }
    }
    private func saveProfile() {
            guard let userID = userID else { return }
            
            let profile = UserProfile(
                id: userID,
                nickname: nickname,
                affiliation: affiliation,
                email: email,
                level: level
            )
            
            do {
                try databaseManager.updateData(profile, type: .user, id: profile.id)
                print("UserProfile 수정 성공")
                isEditing = false // 수정 완료 후 편집 모드 해제
            } catch {
                print("UserProfile 수정 실패: \(error.localizedDescription)")
            }
        }
}

struct EditableField: View {
    let title: String
    @Binding var text: String
    
    var body: some View {
        HStack {
            Text(title)
                .frame(width: 60, alignment: .leading)
            TextField(title, text: $text)
                .padding(.leading, 10)
            Spacer()
        }
    }
}

#Preview {
    ProfileView()
}
