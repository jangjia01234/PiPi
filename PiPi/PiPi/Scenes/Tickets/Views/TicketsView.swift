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
    @State private var selectedItem: TicketType = .participant
    @State private var isShowingTicketDetailView: Bool = false
    @State private var isAuthDone: Bool = false
    @Binding var isShowingSheet: Bool
    
    var body: some View {
        NavigationStack {
            TicketSegmentedControl(selectedItem: $selectedItem)
            
            ScrollView {
                TicketView(selectedItem: $selectedItem, isShowingSheet: $isShowingSheet, isAuthDone: $isAuthDone)
            }
            .scrollBounceBehavior(.basedOnSize)
            
            Spacer()
        }
        .navigationBarBackButtonHidden(true)
        .sheet(isPresented: $isShowingSheet) {
            PeerAuthView(isShowingSheet: $isShowingSheet, isAuthDone: $isAuthDone)
        }
    }
}

#Preview {
    TicketsView(isShowingSheet: .constant(false))
}
