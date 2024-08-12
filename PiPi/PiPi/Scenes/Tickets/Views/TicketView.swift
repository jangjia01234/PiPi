//
//  TicketView.swift
//  PiPi
//
//  Created by Jia Jang on 7/31/24.
//

import SwiftUI
import Firebase
import FirebaseDatabase

// TODO: 데이터 연결 예정 (현재 목업 데이터로 구성)
struct TicketView: View {
    @State private var showTicketDetailView: Bool = false
    
    // MARK: - 🔥
    // 위치가 보이는지? (이것도 확인 필요)
    @State private var isLocationVisible: Bool = false
    
    // MARK: - 🤔 PeerAuthView 시트의 상태
    @State private var isPresentingPeerAuthView = false
    
    @Binding var selectedItem: TicketType
    
    // MARK: - 🔥
    // (State 선언부에서) 확인 및 네이밍 개선 필요
    @Binding var isShowingSheet: Bool
    
    // MARK: - 🔥
    // (State 선언부에서) 확인 및 네이밍 개선 필요
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
            
            // MARK: - TicketDetailView 시트의 상태관리
            .sheet(isPresented: $showTicketDetailView) {
                TicketDetailView(
                    isLocationVisible: $isLocationVisible,
                    activity: activity,
                    userProfile: userProfile
                )
            }
            // MARK: - PeerView 시트 표시
            .sheet(isPresented: $isPresentingPeerAuthView) {
                PeerAuthView(selectedItem: $selectedItem, isShowingSheet: $isShowingSheet, authSuccess: $authSuccess, activity: activity)
            }
        }
        .navigationBarBackButtonHidden(true)
    }
}

// MARK: - Ticket View 관련 코드 분리
fileprivate extension TicketView {
    // MARK: - 상단 헤더 (카테고리 심볼 / 타이틀 / 날짜 / 상태관리)
    func header() -> some View {
        VStack {
            HStack(alignment: .top) {
                // MARK: - 심볼
                // 🔥 TODO: 조건에 따라 심볼 바꿔줘야됨
                symbolItem(name: "figure.run.circle.fill", font: .title2, color: .white)
                // MARK: - 타이틀
                textItem(content: activity.title, font: .title2, weight: .bold)
                
                Spacer()
                
                // MARK: - 날짜
                VStack(alignment: .trailing) {
                    ticketInfoItem(align: .trailing, title: "날짜", content: "\(activity.startDateTime.toString())")
                    
                    // MARK: - 상태관리
                    // TODO: 인증여부에 따른 상태관리 예정 (참가자/주최자 모두에게 실시간 상태 반영)
                    // symbolItem(name: "checkmark.circle.fill", color: isAuthDone ? .yellow : .white)
                    // .padding(.top, 2)
                }
            }
        }
        .padding(.top, 10)
    }
    
    // MARK: - 세부 정보
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
    
    // MARK: - 하단 섹션
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
                    // 🔥 FIXME: 인증 상태 반영 필요
                    // 인증되면 색상O / 안되면 그레이
                    symbolItem(name: "link", font: .title, color: .gray)
                })
            }
        }
    }
    
    // MARK: - 텍스트 레이아웃 템플릿
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
    
    // MARK: - 한 텍스트 아이템
    func textItem(content: String, font: Font = .body, weight: Font.Weight = .regular, color: Color = .white) -> some View {
        Text(content)
            .font(font)
            .fontWeight(weight)
            .foregroundColor(color)
    }
    
    // MARK: - 심볼 구성
    func symbolItem(name: String, font: Font = .body, color: Color = .gray) -> some View {
        Image(systemName: name)
            .font(font)
            .foregroundColor(color)
    }
    
    // 🔥 MARK: - 모달 상태관리 switch문 (확인 필요)
    func handleModalStatus(content: String) {
        switch content {
        case "리스트":
            showTicketDetailView = true
            isLocationVisible = false
            return
        case "위치 확인":
            showTicketDetailView = true
            isLocationVisible = true
            return
        default:
            showTicketDetailView = true
            isLocationVisible = false
            break
        }
    }
}

// MARK: - 에러를 없애기 위해 프리뷰 주석처리
//#Preview {
//    TicketView()
//}
