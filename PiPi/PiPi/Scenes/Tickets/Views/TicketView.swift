//
//  TicketView.swift
//  PiPi
//
//  Created by Jia Jang on 7/31/24.
//

import SwiftUI
import CodeScanner
import Firebase
import FirebaseDatabase

// TODO: 분리 예정 (기존 코드 활용 후 삭제)
class ActivityViewModel: ObservableObject {
    @Published var activity: Activity?
    
    private var ref: DatabaseReference!
    
    init() {
        ref = Database.database().reference()
        fetchActivityData()
    }
    
    func fetchActivityData() {
        let activityID = "10790E3E-B2AA-4AAF-9C17-43F30BF54B4A"
        
        ref.child("activities/\(activityID)").observeSingleEvent(of: .value) { snapshot in
            guard let value = snapshot.value as? [String: Any] else {
                return
            }
            
            do {
                let jsonData = try JSONSerialization.data(withJSONObject: value)
                let activity = try JSONDecoder().decode(Activity.self, from: jsonData)
                DispatchQueue.main.async {
                    self.activity = activity
                }
            } catch let error {
                print("Error decoding activity data: \(error.localizedDescription)")
            }
        }
    }
}

struct TicketView: View {
    @State private var activities: [Activity] = []
    @State private var isShowingTicketDetailView: Bool = false
    @State private var isParticipantTicket: Bool = false
    @State private var isLocationVisible: Bool = false
    @State private var isPresentingPeerAuthView = false
    @Binding var selectedItem: TicketType
    @Binding var isShowingSheet: Bool
    @Binding var isAuthDone: Bool
    
    private typealias DatabaseResult = Result<[String: Activity], Error>
    
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
            .sheet(isPresented: $isShowingTicketDetailView) {
                TicketDetailView(
                    isParticipantList: $isParticipantTicket,
                    isLocationVisible: $isLocationVisible
                )
            }
            .sheet(isPresented: $isPresentingPeerAuthView) {
                PeerAuthView(isShowingSheet: $isShowingSheet, isAuthDone: $isAuthDone)
            }
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
        .navigationBarBackButtonHidden(true)
    }
}

fileprivate extension TicketView {
    func header() -> some View {
        VStack {
            if let activity = activities.first {
                HStack(alignment: .top) {
                    symbolItem(name: "figure.run.circle.fill", font: .title2, color: .white)
                    textItem(content: activity.title, font: .title2, weight: .bold)
                    
                    Spacer()
                    
                    VStack(alignment: .trailing) {
                        ticketInfoItem(align: .trailing, title: "날짜", content: "\(activity.startDateTime.toString())")
                        
                        // TODO: 인증여부에 따른 상태관리 예정 (참가자/주최자 모두에게 실시간 상태 반영)
                        symbolItem(name: "checkmark.circle.fill", color: isAuthDone ? .yellow : .white)
                            .padding(.top, 2)
                    }
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
            if let activity = activities.first {
                ticketInfoItem(title: "소요시간", content: "\(activity.estimatedTime ?? 0)분")
                
                Spacer()
                
                if selectedItem == .organizer {
                    ZStack {
                        RoundedRectangle(cornerRadius: 10)
                            .frame(width: 60, height: 60)
                        
                        Button(action: {
                            isPresentingPeerAuthView = true
                        }, label: {
                            symbolItem(name: "camera.fill", font: .title, color: .black)
                        })
                    }
                }
            }
        }
    }
    
    func ticketInfoItem(align: HorizontalAlignment = .leading, title: String, content: String, isText: Bool = true) -> some View {
        VStack(alignment: align) {
            textItem(content: title, font: .caption, weight: .bold, color: Color.lightGray)
            
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

// TODO: Color Extension 'Color+' 파일로 분리
fileprivate extension Color {
    static var lightPurple: Color {
        return Color(Color(red: 166 / 255, green: 111 / 255, blue: 255 / 255))
    }
    
    static var lightOrange: Color {
        return Color(Color(red: 255 / 255, green: 135 / 255, blue: 109 / 255))
    }
    
    static var lightGray: Color {
        return Color(Color(red: 215 / 255, green: 215 / 255, blue: 215 / 255))
    }
}

#Preview {
    TicketView(selectedItem: .constant(.participant), isShowingSheet: .constant(false), isAuthDone: .constant(false))
}
