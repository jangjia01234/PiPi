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
    @AppStorage("userID") var userID: String?
    
    @Binding var selectedItem: TicketType
    @Binding var isShowingSheet: Bool
    
    @State private var hostNickname: String = ""
    @State private var hostEmail: String? = nil
    @State private var showTicketDetailView: Bool = false
    @State private var isLocationVisible: Bool = false
    @State private var isPresentingPeerAuthView = false
    @State private var showMessageView = false
    @State var isAuthenticationDone: Bool = false
    
    private let userDataManager = FirebaseDataManager<User>()
    
    var activity: Activity
    var userProfile: User
    
    var body: some View {
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
                    isLocationVisible: $isLocationVisible,
                    selectedItem: $selectedItem,
                    showMessageView: $showMessageView,
                    isAuthenticationDone: $isAuthenticationDone,
                    activity: activity,
                    userProfile: userProfile
                )
            }
            .sheet(isPresented: $isPresentingPeerAuthView) {
                PeerAuthView(
                    isAuthenticationDone: $isAuthenticationDone,
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
                    .fill(selectedItem == .participant ? Color.lightPurple : Color.lightOrange)
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
                
                // FIXME: Symbol은 디자인이 확정되지 않아 임시로 코드만 작성해둠
//                Image("\(activity.category.self).accent")
//                    .resizable()
//                    .frame(width: 20, height: 20)
            }
            
            VStack(alignment: .leading) {
                Text("\(activity.startDateTime.toString().split(separator: "\n").first ?? "")")
                Text("\(activity.estimatedTime ?? 0)시간")
            }
            .foregroundColor(.gray)
        }
        .frame(width: 180)
    }
    
    func authButton() -> some View {
        VStack {
            Button(action: {
                isPresentingPeerAuthView = true
            }, label: {
                Text("인증")
            })
            .buttonStyle(.borderedProminent)
            .tint(selectedItem == .participant ? Color.lightPurple : Color.lightOrange)
            
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
    
    private func loadHostProfile(hostID: String) {
        userDataManager.observeSingleData(eventType: .value, id: hostID) { result in
            switch result {
            case .success(let profile):
                DispatchQueue.main.async {
                    self.hostNickname = profile.nickname
                    self.hostEmail = profile.email
                }
            case .failure(let error):
                DispatchQueue.main.async {
                    print("Error fetching host profile: \(error.localizedDescription)")
                }
            }
        }
    }
}

struct TicketView_Previews: PreviewProvider {
    static var previews: some View {
        TicketView(
            selectedItem: .constant(.participant),
            isShowingSheet: .constant(false),
            activity: Activity(
                hostID: "1D2BF6E6-E2A3-486B-BDCF-F3A450C4A029",
                title: "배드민턴 번개",
                description: "A description of the event.",
                maxPeopleNumber: 10,
                category: .alcohol,
                startDateTime: Date(),
                estimatedTime: 2,
                coordinates: Coordinates(latitude: 37.7749, longitude: -122.4194)
            ),
            userProfile: User(
                nickname: "Sample User",
                affiliation: .postech,
                email: "sample@example.com"
            )
        )
    }
}
