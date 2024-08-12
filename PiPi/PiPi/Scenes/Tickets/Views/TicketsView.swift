//
//  TicketsView.swift
//  PiPi
//
//  Created by Jia Jang on 7/31/24.
//

import SwiftUI

struct TicketsView: View {
    // MARK: - 유저의 앱스토리지 ID 선언
    // 매번 불러와야 하나?
    @AppStorage("userID") var userID: String?
    
    // MARK: - 🤔 활동 리스트 담을 배열 선언
    // 왜 이렇게 선언해야 하지? 꼭 필요한가?
    @State private var activities: [Activity] = []
    
    // MARK: - 🤔 유저 프로필 선언 및 초기화
    // 왜 이렇게 선언해야 하지? 꼭 필요한가?
    @State private var userProfile: UserProfile = UserProfile(
            id: "6F0457BD-1AC9-4368-926A-634853569179",
            nickname: "",
            affiliation: "",
            email: "",
            level: 1
        )
    
    // MARK: - ✅ 티켓 타입별로 선택된 아이템 (기본 설정: 참가자)
    @State private var selectedItem: TicketType = .participant
    
    // MARK: - 🤔 TicketDetailView 시트의 상태
    // 어떤 식으로 관리되고 있는지 확인 필요
    @State private var isShowingTicketDetailView: Bool = false
    
    // MARK: - 🔥
    // 확인 및 네이밍 개선 필요
    @State private var isAuthDone: Bool = false
    
    // MARK: - 🔥
    // 확인 및 네이밍 개선 필요
    @Binding var isShowingSheet: Bool
    
    // MARK: - 🤔 Activity 타입의 변수 선언
    // 왜 이렇게 선언해야 하지? 꼭 필요한가?
    var activity: Activity
    
    // MARK: - 🫥 확인 필요
    private typealias ActivityDatabaseResult = Result<[String: Activity], Error>
    private typealias UserDatabaseResult = Result<UserProfile, Error>
    
    var body: some View {
        NavigationStack {
            // MARK: - 상단 탭바 (참가자/주최자)
            TicketSegmentedControl(selectedItem: $selectedItem)
            
            // MARK: - 티켓 리스트
            ScrollView {
                // ForEach로 activities 리스트를 받아와서 여러 티켓 나열
                ForEach(activities, id: \.id) { activity in
                    // userID 언래핑
                    if let userID = userID {
                        // 선택된 탭이 참가자 / 주최자 중 어느 쪽인지 확인
                        if selectedItem == .participant {
                            // participantID 리스트 중 userID와 일치하는 게 있을 때
                            if activity.participantID.contains(userID) {
                                // TicketView 보여주기
                                TicketView(selectedItem: $selectedItem, isShowingSheet: $isShowingSheet, isAuthDone: $isAuthDone, activity: activity, userProfile: userProfile)
                            }
                        } else {
                            // 주최자의 ID와 유저 ID가 일치할 때
                            if activity.hostID == userID {
                                // TicketView 보여주기
                                TicketView(selectedItem: $selectedItem, isShowingSheet: $isShowingSheet, isAuthDone: $isAuthDone, activity: activity, userProfile: userProfile)
                            }
                        }
                    }
                }
            }
            // MARK: - 🤔 ScrollView 관련 설정 (확인 필요, 우선순위 낮음)
            .scrollBounceBehavior(.basedOnSize)
            
            // MARK: - 티켓 리스트가 위쪽에 뜨게 배치
            Spacer()
        }
        // MARK: - 뒤로가기 버튼 숨김
        .navigationBarBackButtonHidden(true)
        // MARK: - PeerAuthView 시트 상태관리
        .sheet(isPresented: $isShowingSheet) {
            PeerAuthView(isShowingSheet: $isShowingSheet, isAuthDone: $isAuthDone, activity: activity)
        }
        // MARK: - Firebase RDB에서 데이터 불러오기 (최초 1회)
        .onAppear {
            // MARK: - Activity 데이터 불러오기
            FirebaseDataManager.shared.fetchData(type: .activity) { (result: ActivityDatabaseResult) in
                switch result {
                case .success(let result):
                    activities = Array(result.values)
                case .failure(let error):
                    dump(error)
                }
            }
            
            // MARK: - User 데이터 불러오기
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

// MARK: - 티켓의 타입: 참가자 / 주최자
// 별도로 분리 필요
enum TicketType : String, CaseIterable {
    case participant = "참가자"
    case organizer = "주최자"
}

// MARK: - 에러를 없애기 위해 프리뷰 주석처리
//#Preview {
//    TicketsView(isShowingSheet: .constant(false))
//}
