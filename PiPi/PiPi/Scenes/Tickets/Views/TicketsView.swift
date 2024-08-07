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
    @State private var activities: [Activity] = []
    @State private var selectedItem: TicketType = .participant
    @State private var isShowingTicketDetailView: Bool = false
    @State private var isAuthDone: Bool = false
    @Binding var isShowingSheet: Bool
    
    private typealias DatabaseResult = Result<[String: Activity], Error>
    
    var body: some View {
        NavigationStack {
            TicketSegmentedControl(selectedItem: $selectedItem)
            
            ScrollView {
                ForEach(activities, id: \.id) { activity in
                    TicketView(selectedItem: $selectedItem, isShowingSheet: $isShowingSheet, isAuthDone: $isAuthDone, activity: activity)
                }
            }
            .scrollBounceBehavior(.basedOnSize)
            
            Spacer()
        }
        .navigationBarBackButtonHidden(true)
        .sheet(isPresented: $isShowingSheet) {
            PeerAuthView(isShowingSheet: $isShowingSheet, isAuthDone: $isAuthDone)
        }
        .onAppear {
            FirebaseDataManager.shared.fetchData(type: .activity) { (result: DatabaseResult) in
                switch result {
                case .success(let result):
                    activities = Array(result.values)
                case .failure(let error):
                    dump(error)
                }
            }
        }
    }
}

#Preview {
    TicketsView(isShowingSheet: .constant(false))
}
