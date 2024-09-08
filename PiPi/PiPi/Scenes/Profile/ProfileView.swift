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
    @State private var isEditing: Bool = false
    
    private let userDataManager = FirebaseDataManager<User>()
    private let userID = FirebaseAuthManager.shared.currentUser?.uid
    
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
                    Form {
                        Section("프로필 정보") {
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
                        }
                        .listRowBackground(Color(.secondarySystemBackground))
                        
                        Section("계정") {
                            Button(action: {
                                signOut()
                            }) {
                                Text("로그아웃")
                                    .foregroundStyle(.red)
                            }
                        }
                        .listRowBackground(Color(.secondarySystemBackground))
                    }
                    .scrollContentBackground(.hidden)
                }
            }
            .onAppear {
                if let userID {
                    loadProfile(userID: userID)
                } else {
                    print("userID is not set")
                }
            }
        }
        .navigationBarBackButtonHidden(true)
    }
    
    private func signOut() {
        Task {
            do {
                try await FirebaseAuthManager.shared.signOut()
            } catch {
                dump(error)
            }
        }
    }
    
    private func loadProfile(userID: String) {
        userDataManager.observeSingleData(eventType: .value, id: userID) { result in
            switch result {
            case .success(let profile):
                DispatchQueue.main.async {
                    self.nickname = profile.nickname
                    self.affiliation = profile.affiliation
                    self.email = profile.email
                }
            case .failure(let error):
                dump("Error fetching profile: \(error.localizedDescription)")
            }
        }
    }
    
    private func saveProfile() {
        guard let userID else { return }
        
        let profile = User(
            id: userID,
            nickname: nickname,
            affiliation: affiliation,
            email: email
        )
        
        do {
            try userDataManager.updateData(profile, id: profile.id)
            print("UserProfile 수정 성공")
            isEditing = false
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
