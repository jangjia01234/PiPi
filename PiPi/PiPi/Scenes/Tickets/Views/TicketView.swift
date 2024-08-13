//
//  TicketView.swift
//  PiPi
//
//  Created by Jia Jang on 7/31/24.
//

import SwiftUI
import Firebase
import FirebaseDatabase

struct TicketView: View {
    @AppStorage("userID") var userID: String?
    @State private var hostNickname: String = ""
    @State private var showTicketDetailView: Bool = false
    @State private var isLocationVisible: Bool = false
    @State private var isPresentingPeerAuthView = false
    @Binding var selectedItem: TicketType
    @Binding var isShowingSheet: Bool
    @Binding var authSuccess: Bool
    
    private let databaseManager = FirebaseDataManager.shared
    
    var activity: Activity
    var userProfile: UserProfile
    
    var body: some View {
        NavigationStack {
            ZStack {
                RoundedRectangle(cornerRadius: 20)
                    .fill(selectedItem == .participant ? Color.lightPurple : Color.lightOrange)
                
                VStack(alignment: .leading) {
                    header()
                    ticketDetailSection(selectedItem: selectedItem)
                    Spacer()
                    authenticationSection()
                }
                .foregroundColor(.white)
                .padding()
            }
            .frame(height: 350)
            .padding(.horizontal, 15)
            .padding(.bottom, 10)
            .sheet(isPresented: $showTicketDetailView) {
                TicketDetailView(
                    isLocationVisible: $isLocationVisible,
                    activity: activity,
                    userProfile: userProfile
                )
            }
            .sheet(isPresented: $isPresentingPeerAuthView) {
                PeerAuthView(
                    selectedItem: $selectedItem,
                    authSuccess: $authSuccess,
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
    func header() -> some View {
        VStack {
            HStack(alignment: .top) {
                // 🔥 TODO: 조건에 따라 심볼 바꿔줘야됨
                symbolItem(name: "figure.run.circle.fill", font: .title2, color: .white)
                textItem(content: activity.title, font: .title2, weight: .bold)
                
                Spacer()
                
                VStack(alignment: .trailing) {
                    ticketInfoItem(align: .trailing, title: "날짜", content: "\(activity.startDateTime.toString().split(separator: "\n").first ?? "")")
                }
            }
        }
        .padding(.top, 10)
    }
    
    func ticketDetailSection(selectedItem: TicketType) -> some View {
        VStack(alignment: .leading) {
            HStack {
                VStack(alignment: .leading) {
                    if selectedItem == .participant {
                        ticketInfoItem(align: .leading, title: "주최자", content:  "\(hostNickname)")
                    } else {
                        ticketInfoItem(align: .leading, title: "참가자", content:  "리스트", isText: false)
                    }
                }
                
                Spacer()
            }
            .padding(.bottom, 10)
            
            ticketInfoItem(title: "장소", content: "위치 확인", isText: false)
        }
    }
    
    func authenticationSection() -> some View {
        HStack(alignment: .bottom) {
            VStack(alignment: .leading) {
                ticketInfoItem(title: "시작시간", content: "\(activity.startDateTime.toString().split(separator: "\n").last ?? "")")
                    .padding(.bottom, 10)
                
                ticketInfoItem(title: "소요시간", content: "\(activity.estimatedTime ?? 0)시간")
            }
            
            Spacer()
            
            ZStack {
                RoundedRectangle(cornerRadius: 10)
                    .frame(width: 60, height: 60)
                
                Button(action: {
                    isPresentingPeerAuthView = true
                }, label: {
                    symbolItem(name: "link", font: .title, color: .gray)
                })
            }
        }
    }
    
    func ticketInfoItem(align: HorizontalAlignment = .leading, title: String, content: String, isText: Bool = true) -> some View {
        VStack(alignment: align) {
            textItem(content: title, font: .caption, weight: .bold, color: Color.lightGray)
            
            Group {
                if isText {
                    textItem(content: content, font: .callout)
                } else {
                    Button(action: { handleModalStatus(content: content) }) {
                        textItem(content: content, font: .callout)
                    }
                    .buttonStyle(.borderedProminent)
                    .tint(selectedItem == .participant ? .accentColor : Color("SubColor"))
                }
            }
        }
    }
    
    func textItem(content: String, font: Font = .body, weight: Font.Weight = .regular, color: Color = .white) -> some View {
        Text(content)
            .font(font)
            .fontWeight(weight)
            .foregroundColor(color)
    }
    
    func symbolItem(name: String, font: Font = .body, color: Color = .gray) -> some View {
        Image(systemName: name)
            .font(font)
            .foregroundColor(color)
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
        databaseManager.fetchData(type: .user, dataID: hostID) { (result: Result<UserProfile, Error>) in
            switch result {
            case .success(let profile):
                DispatchQueue.main.async {
                    self.hostNickname = profile.nickname
                }
            case .failure(let error):
                DispatchQueue.main.async {
                    print("Error fetching host profile: \(error.localizedDescription)")
                }
            }
        }
    }
}
