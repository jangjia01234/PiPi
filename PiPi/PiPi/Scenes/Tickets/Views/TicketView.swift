//
//  TicketView.swift
//  PiPi
//
//  Created by Jia Jang on 7/31/24.
//

import SwiftUI
import Firebase
import FirebaseDatabase
import MessageUI

struct TicketView: View {
    @Binding var selectedItem: TicketType
    @Binding var isShowingSheet: Bool
    
    @State private var hostNickname: String = ""
    @State private var hostID: String? = nil
    @State private var showTicketDetailView: Bool = false
    @State private var isLocationVisible: Bool = false
    @State private var isPresentingPeerAuthView = false
    @State private var showMessageView = false
    
    private let userDataManager = FirebaseDataManager<User>()
    private let userID = FirebaseAuthManager.shared.currentUser?.uid
    
    var activity: Activity
    var userProfile: User
    
    var body: some View {
        
        let viewModel = ActivityDetailViewModel(activityID: activity.id, hostID: activity.hostID)
        
        NavigationStack {
            ZStack {
                backgroundRectangle()
                
                HStack(alignment: .top) {
                    infoText()
                    Spacer()
                    authButton()
                }
                .padding(20)
            }
            .frame(height: 180)
            .padding(.horizontal, 20)
            .sheet(isPresented: $showTicketDetailView) {
                TicketDetailView(
                    viewModel: viewModel,
                    isLocationVisible: $isLocationVisible,
                    selectedItem: $selectedItem,
                    showMessageView: $showMessageView,
                    activity: activity,
                    userProfile: userProfile
                )
            }
            .sheet(isPresented: $isPresentingPeerAuthView) {
                PeerAuthView(
                    activity: activity
                )
            }
        }
        .navigationBarBackButtonHidden(true)
        .onAppear {
            loadHostProfile(hostID: activity.hostID)
        }
    }
}

fileprivate extension TicketView {
    func backgroundRectangle() -> some View {
        ZStack {
            RoundedRectangle(cornerRadius: 20)
                .fill(.white)
                .onTapGesture {
                    showTicketDetailView = true
                }
            
            HStack {
                Rectangle()
                    .fill(selectedItem == .participant ? .accent : .sub)
                    .frame(width: 30)
                    .roundingCorner(20, corners : [.topLeft, .bottomLeft])
                
                Spacer()
            }
        }
    }
    
    func infoText() -> some View {
        VStack(alignment: .leading) {
            HStack {
                Text(activity.title)
                    .font(.system(size: 28))
                    .fontWeight(.black)
                    .padding(.bottom, 5)
                
                Spacer()
            }
            .frame(width: 160)
            
            if let formattedDate = formatDate() {
                VStack(alignment: .leading) {
                    Text(formattedDate)
                    
                    if let estimatedTime = activity.estimatedTime {
                        if estimatedTime > 0 {
                            Text("약 \(activity.estimatedTime ?? 0)시간 소요")
                                .font(.footnote)
                        } else {
                            Text("소요 시간 미정")
                                .font(.footnote)
                        }
                    }
                }
                .foregroundColor(.gray)
            }
        }
        .padding(.leading, 25)
    }
    
    func authButton() -> some View {
        VStack {
            if let userID = userID {
                if selectedItem == .participant {
                    if activity.participantID.contains(userID) {
                        Button(action: {
                            isPresentingPeerAuthView = true
                        }, label: {
                            
                            // TODO: UX Writing 변경 예정
                            Text(activity.authentication[userID] == true ? "인증완료": "인증하기")
                        })
                        .buttonStyle(.borderedProminent)
                        .tint(activity.authentication[userID] == true ? .gray : .accent)
                    }
                } else {
                    if userID == activity.hostID {
                        let totalParticipants = activity.authentication.count
                        let completedAuthentications = activity.authentication.values.filter { $0 == true }.count
                        
                        Button(action: {
                            isPresentingPeerAuthView = true
                        }, label: {
                            
                            // TODO: UX Writing 변경 예정
                            Text(totalParticipants > 0 && totalParticipants == completedAuthentications ? "인증완료" : "인증하기")
                        })
                        .buttonStyle(.borderedProminent)
                        
                        // FIXME: 색상 최신 버전으로 변경 필요
                        .tint(totalParticipants > 0 && totalParticipants == completedAuthentications ? .gray : .sub)
                    }
                }
            }
            
            Spacer()
        }
    }
    
    func handleModalStatus(content: String) {
        switch content {
        case "리스트":
            showTicketDetailView = true
            return
        case "위치 확인":
            showTicketDetailView = true
            isLocationVisible = true
            return
        default:
            showTicketDetailView = true
            break
        }
    }
    
    func loadHostProfile(hostID: String) {
        userDataManager.observeSingleData(eventType: .value, id: hostID) { result in
            switch result {
            case .success(let profile):
                DispatchQueue.main.async {
                    self.hostNickname = profile.nickname
                    self.hostID = profile.id
                }
            case .failure(let error):
                DispatchQueue.main.async {
                    print("Error fetching host profile: \(error.localizedDescription)")
                }
            }
        }
    }
    
    func formatDate() -> String? {
        let activityDate = activity.startDateTime.toString()
        
        let formatter = DateFormatter()
        formatter.locale = Locale(identifier: "ko_KR")
        
        formatter.dateFormat = "yyyy년 MM월 dd일\na HH시 mm분"
        guard let date = formatter.date(from: activityDate) else { return nil }
        
        formatter.dateFormat = "MM/dd HH:mm분"
        return formatter.string(from: date)
    }
}

#Preview {
    TicketView(
        selectedItem: .constant(.participant),
        isShowingSheet: .constant(false),
        activity: Activity.sampleData,
        userProfile: User(
            nickname: "",
            affiliation: .postech,
            email: ""
        )
    )
}
