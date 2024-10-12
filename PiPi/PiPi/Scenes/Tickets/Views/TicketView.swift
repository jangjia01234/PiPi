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
        NavigationStack {
            ticketView
        }
        .sheet(isPresented: $showTicketDetailView) {
            let viewModel = ActivityDetailViewModel(activityID: activity.id, hostID: activity.hostID)
            
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
            PeerAuthView(activity: activity)
        }
        .navigationBarBackButtonHidden(true)
        .onAppear {
            loadHostProfile(hostID: activity.hostID)
        }
    }
    
    // MARK: - Subviews
    private var ticketView: some View {
        ZStack {
            backgroundRectangle
            ticketContent
        }
        .frame(height: 180)
        .padding(.horizontal, 20)
    }
    
    private var ticketContent: some View {
        VStack(alignment: .leading) {
            ticketTopArea
            ticketDetailText
            Spacer()
        }
        .padding(20)
        .padding(.leading, 20)
    }
    
    private var backgroundRectangle: some View {
        HStack {
            Rectangle()
                .fill(selectedItem == .participant ? .accent : .sub)
                .frame(width: 30)
                .roundingCorner(20, corners : [.topLeft, .bottomLeft])
            
            Spacer()
        }
        .background {
            RoundedRectangle(cornerRadius: 20)
                .fill(.white)
                .onTapGesture { showTicketDetailView = true }
            
        }
    }
    
    private var ticketTopArea: some View {
        HStack(alignment: .top) {
            ticketTitle
            Spacer()
            authButton
        }
        .frame(height: 40)
    }
    
    private var ticketTitle: some View {
        Text(activity.title)
            .font(.system(size:24))
            .fontWeight(.bold)
    }
    
    private func authButtonStyle(text: String, color: Color) -> some View {
        Button {
            isPresentingPeerAuthView = true
        } label: {
            Text(text)
        }
        .buttonStyle(.borderedProminent)
        .tint(color)
    }
    
    private var authButton: some View {
        VStack {
            if let userID = userID {
                // MARK: 참가자일 경우 버튼 표시
                if selectedItem == .participant && activity.participantID.contains(userID) {
                    authButtonStyle(text: activity.authentication[userID] == true ? "인증완료": "인증하기", color: activity.authentication[userID] == true ? .gray : .accent)
                        .disabled(activity.authentication[userID] == true)
                } else {
                    // MARK: 주최자일 경우 버튼 표시
                    let totalParticipants = activity.authentication.count
                    let completedAuthentications = activity.authentication.values.filter { $0 == true }.count
                    
                    authButtonStyle(text: totalParticipants > 0 && totalParticipants == completedAuthentications ? "인증완료" : "인증하기", color: .sub)
                        .disabled(totalParticipants > 0 && totalParticipants == completedAuthentications)
                }
            }
        }
    }
    
    private var ticketDetailText: some View {
        HStack {
            VStack(alignment: .leading, spacing: 5) {
                ticketDescription
                ticketTime
            }
            
            Spacer()
        }
    }
    
    private var ticketDescription: some View {
        Text(activity.description)
            .font(.headline)
            .foregroundColor(.gray)
    }
    
    private var ticketTime: some View {
        VStack {
            if let formattedDate = formatDate() {
                if let estimatedTime = activity.estimatedTime {
                    Text(estimatedTime > 0
                         ? "\(formattedDate)\n\(activity.estimatedTime ?? 0)시간 소요"
                         : formattedDate)
                }
            }
        }
        .font(.caption)
        .foregroundColor(.gray)
    }
    
    // MARK: - functions
    private func handleModalStatus(content: String) {
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
    
    private func loadHostProfile(hostID: String) {
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
    
    private func formatDate() -> String? {
        let activityDate = activity.startDateTime.toString()
        
        let formatter = DateFormatter()
        formatter.locale = Locale(identifier: "ko_KR")
        
        formatter.dateFormat = "yyyy년 MM월 dd일\na HH시 mm분"
        guard let date = formatter.date(from: activityDate) else { return nil }
        
        formatter.dateFormat = "MM/dd HH시 mm분"
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
