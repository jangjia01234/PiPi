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
    // MARK: - 🤔 활동 리스트 담을 배열 선언
    // 왜 이렇게 선언해야 하지? 꼭 필요한가?
    // 매번 State로 새로 선언해야하나? 내려주면 안되나?
    @State private var activities: [Activity] = []
    
    // MARK: - 🤔 TicketDetailView 시트의 상태
    // 어떤 식으로 관리되고 있는지 확인 필요
    // 매번 State로 새로 선언해야하나? 내려주면 안되나?
    @State private var isShowingTicketDetailView: Bool = false
    
    // MARK: - 🔥
    // 참가자의 티켓인지 여부 (이게 뭐더라.. 어디서 쓰였는지 확인 필요)
    @State private var isParticipantTicket: Bool = false
    
    // MARK: - 🔥
    // 위치가 보이는지? (이것도 확인 필요)
    @State private var isLocationVisible: Bool = false
    
    // MARK: - 🤔 PeerAuthView 시트의 상태
    @State private var isPresentingPeerAuthView = false
    
    // MARK: - ✅ 티켓 타입별로 선택된 아이템 Binding
    @Binding var selectedItem: TicketType
    
    // MARK: - 🔥
    // (State 선언부에서) 확인 및 네이밍 개선 필요
    @Binding var isShowingSheet: Bool
    
    // MARK: - 🔥
    // (State 선언부에서) 확인 및 네이밍 개선 필요
    @Binding var isAuthDone: Bool
    
    var activity: Activity
    var userProfile: UserProfile
    
    // MARK: - 🫥 확인 필요
    private typealias ActivityDatabaseResult = Result<[String: Activity], Error>
    private typealias UserDatabaseResult = Result<UserProfile, Error>
    
    var body: some View {
        // MARK: - 다른 화면으로 이동하기 위해 NavigationStack으로 감싸기
        NavigationStack {
            // MARK: - 카드 뷰를 위해 ZStack으로 구성
            ZStack {
                // MARK: - 카드의 밑바탕이 되는 사각형 선언
                RoundedRectangle(cornerRadius: 20)
                    .fill(selectedItem == .participant ? Color.lightPurple : Color.lightOrange)
                
                // MARK: - 사각형 위에 올라가는 정보들
                VStack(alignment: .leading) {
                    header()
                    ticketDetailSection(selectedItem: selectedItem)
                    Spacer()
                    authenticationSection()
                }
                .foregroundColor(.white)
                .padding()
            }
            // MARK: - 한 카드의 전체 레이아웃
            .frame(height: 350)
            .padding(.horizontal, 15)
            .padding(.bottom, 10)
            // MARK: - TicketDetailView 시트의 상태관리
            .sheet(isPresented: $isShowingTicketDetailView) {
                // MARK: - TicketDetailView 보여주기
                TicketDetailView(
                    isLocationVisible: $isLocationVisible,
                    activity: activity,
                    userProfile: userProfile
                )
            }
            // MARK: - PeerView 시트 표시
            .sheet(isPresented: $isPresentingPeerAuthView) {
                PeerAuthView(isShowingSheet: $isShowingSheet, isAuthDone: $isAuthDone, activity: activity)
            }
        }
        // MARK: - 뒤로가기 버튼 숨김
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
                    // MARK: - 주최자 / 참가자
                    ticketInfoItem(align: .leading, title: selectedItem == .participant ? "주최자" : "참가자", content: selectedItem == .organizer ? "리스트" : "닉네임", isText: false)
                }
                
                Spacer()
            }
            .padding(.bottom, 10)
            
            // MARK: - 장소
            ticketInfoItem(title: "장소", content: "위치 확인", isText: false)
        }
    }
    
    // MARK: - 하단 섹션
    func authenticationSection() -> some View {
        HStack(alignment: .bottom) {
            // MARK: - 소요시간
            // 🔥 FIXME: 일반 시간도 있어야 함 (?)
            ticketInfoItem(title: "소요시간", content: "\(activity.estimatedTime ?? 0)시간")
            
            Spacer()
            
            // MARK: - 인증 버튼
            // FIXME: 인증 테스트용 주석 처리
//            if selectedItem == .organizer {
                ZStack {
                    RoundedRectangle(cornerRadius: 10)
                        .frame(width: 60, height: 60)
                    
                    Button(action: {
                        isPresentingPeerAuthView = true
                    }, label: {
                        // 🔥 FIXME: 카메라 말고 다른, 인증을 나타내는 심볼 필요
                        symbolItem(name: "camera.fill", font: .title, color: .black)
                    })
//                }
            }
        }
    }
    
    // MARK: - 텍스트 레이아웃 템플릿
    func ticketInfoItem(align: HorizontalAlignment = .leading, title: String, content: String, isText: Bool = true) -> some View {
        VStack(alignment: align) {
            // 타이틀
            textItem(content: title, font: .caption, weight: .bold, color: Color.lightGray)
            
            // 내용 (텍스트 or 버튼)
            if isText {
                textItem(content: content, font: .callout)
            } else {
                Button {
                    if !isText {
                        handleModalStatus(content: content)
                    }
                } label: {
                    textItem(content: content, font: .callout)
                }
                .buttonStyle(.borderedProminent)
                .tint(selectedItem == .participant ? .accentColor : Color("SubColor"))
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
            isShowingTicketDetailView = true
            isParticipantTicket = true
            isLocationVisible = false
            return
        case "위치 확인":
            isShowingTicketDetailView = true
            isParticipantTicket = false
            isLocationVisible = true
            return
        default:
            isShowingTicketDetailView = true
            isParticipantTicket = false
            isLocationVisible = false
            break
        }
    }
}

// MARK: - 에러를 없애기 위해 프리뷰 주석처리
//#Preview {
//    TicketView()
//}
