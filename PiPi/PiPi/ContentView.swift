//
//  ContentView.swift
//  PiPi
//
//  Created by 정상윤 on 7/29/24.
//

import SwiftUI

struct ContentView: View {
    @Binding var isShowingSheet: Bool
    var activity: Activity
    
    var body: some View {
        TabView {
            HomeView()
                .tabItem {
                    Image(systemName: "map")
                    Text("홈")
                }
            
            TicketsView(isShowingSheet: $isShowingSheet, activity: activity)
                .tabItem {
                    Image(systemName: "ticket.fill")
                    Text("내 예약")
                }
            
            ProfileView()
                .tabItem {
                    Image(systemName: "person")
                    Text("프로필")
                }
        }
        .tint(.accent)
    }
    
}

#Preview {
    ContentView(isShowingSheet: .constant(false), activity: Activity.sampleData)
}
