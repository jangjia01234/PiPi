//
//  TicketsView.swift
//  PiPi
//
//  Created by Jia Jang on 7/31/24.
//

import SwiftUI

struct TicketsView: View {
    @Binding var isShowingSheet: Bool
    
    @State private var activities: [Activity] = []
    @State private var selectedItem: TicketType = .participant
    @State private var userProfile: User = User(
        nickname: "",
        affiliation: .postech,
        email: ""
    )
    
    private let userID = FirebaseAuthManager.shared.currentUser?.uid
    private let activityDataManager = FirebaseDataManager<Activity>()
    private let userDataManager = FirebaseDataManager<User>()
    
    var activity: Activity
    
    var body: some View {
        NavigationStack {
            ticketsView
        }
        .onAppear(perform: loadData)
    }
    
    // MARK: - Subviews
    private var ticketsView: some View {
        VStack {
            TicketSegmentedControl(selectedItem: $selectedItem)
                .background(.white)
            ticketsList
            Spacer()
        }
        .background(.quaternary.opacity(0.4))
    }
    
    private var ticketsList: some View {
        ScrollView {
            if let userID = userID {
                let filteredActivities = activities.filter { activity in
                    return selectedItem == .participant ? activity.participantID.contains(userID) : activity.hostID == userID
                }
                
                if filteredActivities.isEmpty {
                    Text(selectedItem == .participant ? "예약 내역이 없습니다" : "주최한 모임이 없습니다.")
                        .foregroundColor(.gray)
                        .padding(.top, 50)
                } else {
                    ForEach(filteredActivities.sorted(by: { $0.startDateTime > $1.startDateTime }), id: \.id) { activity in
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
        .scrollBounceBehavior(.basedOnSize)
        .navigationBarBackButtonHidden(true)
    }
    
    // MARK: - Functions
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

#Preview {
    TicketsView(isShowingSheet: .constant(false), activity: Activity.sampleData)
}
