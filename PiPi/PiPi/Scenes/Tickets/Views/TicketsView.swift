//
//  TicketsView.swift
//  PiPi
//
//  Created by Jia Jang on 7/31/24.
//

import SwiftUI

struct TicketsView: View {
    @AppStorage("userID") var userID: String?
    @State private var activities: [Activity] = []
    @State private var userProfile: UserProfile = UserProfile(
        id: "6F0457BD-1AC9-4368-926A-634853569179",
        nickname: "",
        affiliation: .postech,
        email: "",
        level: 1
    )
    @State private var selectedItem: TicketType = .participant
    @State private var authSuccess: Bool = false
    
    // MARK: - 🔥
    // 확인 및 네이밍 개선 필요
    @Binding var isShowingSheet: Bool
    
    var activity: Activity
    private typealias ActivityDatabaseResult = Result<[String: Activity], Error>
    private typealias UserDatabaseResult = Result<UserProfile, Error>
    
    var body: some View {
        NavigationStack {
            TicketSegmentedControl(selectedItem: $selectedItem)
            
            ticketsList
                .scrollBounceBehavior(.basedOnSize)
                .navigationBarBackButtonHidden(true)
            // MARK: - PeerAuthView 시트 상태관리
                .sheet(isPresented: $isShowingSheet) {
                    PeerAuthView(
                        selectedItem: $selectedItem,
                        authSuccess: $authSuccess,
                        activity: activity
                    )
                }
            
            Spacer()
        }
        .onAppear(perform: loadData)
    }
    
    private var ticketsList: some View {
        ScrollView {
            ForEach(activities, id: \.id) { activity in
                if shouldDisplayTicket(for: activity, userID: userID) {
                    TicketView(
                        selectedItem: $selectedItem,
                        isShowingSheet: $isShowingSheet,
                        authSuccess: $authSuccess,
                        activity: activity,
                        userProfile: userProfile
                    )
                }
            }
        }
    }
    
    private func shouldDisplayTicket(for activity: Activity, userID: String?) -> Bool {
        guard let userID = userID else { return false }
        
        switch selectedItem {
        case .participant:
            return activity.participantID.contains(userID)
        case .organizer:
            return activity.hostID == userID
        }
    }
    
    private func loadData() {
        fetchActivities()
        fetchUserProfile()
    }
    
    private func fetchActivities() {
        FirebaseDataManager.shared.fetchData(type: .activity) { (result: ActivityDatabaseResult) in
            switch result {
            case .success(let result):
                activities = Array(result.values)
            case .failure(let error):
                dump(error)
            }
        }
    }
    
    private func fetchUserProfile() {
        FirebaseDataManager.shared.fetchData(
            type: .user,
            dataID: userProfile.id
        ) { (result: UserDatabaseResult) in
            switch result {
            case .success(let fetchedUser):
                userProfile = fetchedUser
            case .failure(let error):
                break
            }
        }
    }
}

enum TicketType : String, CaseIterable {
    case participant = "참가자"
    case organizer = "주최자"
}
