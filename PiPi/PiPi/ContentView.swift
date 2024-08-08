//
//  ContentView.swift
//  PiPi
//
//  Created by 정상윤 on 7/29/24.
//

import SwiftUI

struct ContentView: View {
    
    var body: some View {
        TabView {
            HomeView()
                .tabItem {
                    Image(systemName: "map")
                    Text("홈")
                }
            
            // TODO: TicketsView 추가
            
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
    ContentView()
}
