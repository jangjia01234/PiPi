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
    @State private var userProfile: User = User(
        nickname: "",
        affiliation: .postech,
        email: ""
    )
    @State private var selectedItem: TicketType = .participant
    
    // MARK: - 🔥
    // 확인 및 네이밍 개선 필요
    @Binding var isShowingSheet: Bool
    
    var activity: Activity
    
    private let activityDataManager = FirebaseDataManager<Activity>()
    private let userDataManager = FirebaseDataManager<User>()
    
    var body: some View {
        NavigationStack {
            VStack {
                TicketSegmentedControl(selectedItem: $selectedItem)
                    .background(.white)
                
                ticketsList
                    .scrollBounceBehavior(.basedOnSize)
                    .navigationBarBackButtonHidden(true)
                
                Spacer()
            }
            .background(.quaternary.opacity(0.4))
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
                        activity: activity,
                        userProfile: userProfile
                    )
                    .padding(.top, 10)
                }
            }
        }
    }
    
    private func shouldDisplayTicket(for activity: Activity, userID: String?) -> Bool {
        guard let userID else { return false }
        
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
        activityDataManager.observeAllData(
            eventType: .value
        ) { result in
            switch result {
            case .success(let result):
                self.activities = Array(result.values)
            case .failure(let error):
                dump(error)
            }
        }
    }
    
    private func fetchUserProfile() {
        userDataManager.observeSingleData(
            eventType: .value,
            id: userProfile.id
        ) { result in
            switch result {
            case .success(let fetchedUser):
                userProfile = fetchedUser
            case .failure(_):
                break
            }
        }
    }
}

enum TicketType : String, CaseIterable {
    case participant = "참가자"
    case organizer = "주최자"
}

struct TicketsView_Previews: PreviewProvider {
    static var previews: some View {
        TicketsView(
            isShowingSheet: .constant(false),
            activity: Activity(
                hostID: "1D2BF6E6-E2A3-486B-BDCF-F3A450C4A029",
                title: "벨과 함께하는 배드민턴",
                description: "",
                maxPeopleNumber: 2,
                category: .alcohol,
                startDateTime: Date(),
                estimatedTime: 1,
                coordinates: Coordinates(latitude: 0.0, longitude: 0.0)
            )
        )
    }
}
