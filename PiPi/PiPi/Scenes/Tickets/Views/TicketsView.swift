//
//  TicketsView.swift
//  PiPi
//
//  Created by Jia Jang on 7/31/24.
//

import SwiftUI

enum TicketType : String, CaseIterable {
    case participant = "참가자"
    case organizer = "주최자"
}

struct TicketsView: View {
    @AppStorage("userID") var userID: String?
    @State private var activities: [Activity] = []
    @State private var userProfile: UserProfile = UserProfile(
            id: "6F0457BD-1AC9-4368-926A-634853569179",
            nickname: "",
            affiliation: "",
            email: "",
            level: 1
        )
    @State private var selectedItem: TicketType = .participant
    @State private var isShowingTicketDetailView: Bool = false
    @State private var isAuthDone: Bool = false
    @Binding var isShowingSheet: Bool
    
    var activity: Activity
    
    private typealias ActivityDatabaseResult = Result<[String: Activity], Error>
    private typealias UserDatabaseResult = Result<UserProfile, Error>
    
    var body: some View {
        NavigationStack {
            TicketSegmentedControl(selectedItem: $selectedItem)
            
            ScrollView {
                ForEach(activities, id: \.id) { activity in
                    if let userID = userID {
                        if selectedItem == .participant {
                            if activity.participantID.contains(userID) {
                                TicketView(selectedItem: $selectedItem, isShowingSheet: $isShowingSheet, isAuthDone: $isAuthDone, activity: activity, userProfile: userProfile)
                            }
                        } else {
                            // FIX: host id가 실제 id와 일치하는 게 하나도 없음 (직접 생성함)
                            if activity.hostID == userID {
                                TicketView(selectedItem: $selectedItem, isShowingSheet: $isShowingSheet, isAuthDone: $isAuthDone, activity: activity, userProfile: userProfile)
                            }
                        }
                    }
                }
            }
            .scrollBounceBehavior(.basedOnSize)
            
            Spacer()
        }
        .navigationBarBackButtonHidden(true)
        .sheet(isPresented: $isShowingSheet) {
            PeerAuthView(isShowingSheet: $isShowingSheet, isAuthDone: $isAuthDone, selectedItem: $selectedItem, activity: activity)
        }
        .onAppear {
            FirebaseDataManager.shared.fetchData(type: .activity) { (result: ActivityDatabaseResult) in
                switch result {
                case .success(let result):
                    activities = Array(result.values)
                case .failure(let error):
                    dump(error)
                }
            }
            
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
}

//#Preview {
//    TicketsView(isShowingSheet: .constant(false))
//}
