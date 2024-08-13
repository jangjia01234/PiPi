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
    @State private var showTicketDetailView: Bool = false
    @State private var isLocationVisible: Bool = false
    @State private var isPresentingPeerAuthView = false
    @Binding var selectedItem: TicketType
    
    // MARK: - 🔥
    // (State 선언부에서) 확인 및 네이밍 개선 필요
    @Binding var isShowingSheet: Bool

    @Binding var authSuccess: Bool
    
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
            // MARK: - PeerView 시트 표시
            .sheet(isPresented: $isPresentingPeerAuthView) {
                PeerAuthView(
                    selectedItem: $selectedItem,
                    authSuccess: $authSuccess,
                    activity: activity
                )
            }
        }
        .navigationBarBackButtonHidden(true)
    }
}

fileprivate extension TicketView {
    func header() -> some View {
        VStack {
            HStack(alignment: .top) {
                // MARK: - 심볼
                // 🔥 TODO: 조건에 따라 심볼 바꿔줘야됨
                symbolItem(name: "figure.run.circle.fill", font: .title2, color: .white)
                textItem(content: activity.title, font: .title2, weight: .bold)
                
                Spacer()
                
                VStack(alignment: .trailing) {
                    ticketInfoItem(align: .trailing, title: "날짜", content: "\(activity.startDateTime.toString())")
                }
            }
        }
        .padding(.top, 10)
    }
    
    func ticketDetailSection(selectedItem: TicketType) -> some View {
        VStack(alignment: .leading) {
            HStack {
                VStack(alignment: .leading) {
                    ticketInfoItem(align: .leading, title: selectedItem == .participant ? "주최자" : "참가자", content: selectedItem == .organizer ? "리스트" : "닉네임", isText: false)
                }
                
                Spacer()
            }
            .padding(.bottom, 10)
            
            ticketInfoItem(title: "장소", content: "위치 확인", isText: false)
        }
    }
    
    func authenticationSection() -> some View {
        HStack(alignment: .bottom) {
            // MARK: - 소요시간
            // 🔥 FIXME: 시작 시간은 merge하고 반영
            VStack(alignment: .leading) {
                ticketInfoItem(title: "시작시간", content: "\(activity.startDateTime.toString())시간")
                    .padding(.bottom, 10)
                
                ticketInfoItem(title: "소요시간", content: "\(activity.estimatedTime ?? 0)시간")
            }
            
            Spacer()
            
            // MARK: - 인증 버튼
            // 🔥 FIXME: 인증 상태 반영 필요
            ZStack {
                RoundedRectangle(cornerRadius: 10)
                    .frame(width: 60, height: 60)
                
                Button(action: {
                    isPresentingPeerAuthView = true
                }, label: {
                    // 인증되면 색상O / 안되면 그레이
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
            return
        default:
            showTicketDetailView = true
            break
        }
    }
}
