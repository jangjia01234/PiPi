//
//  TicketDetailView.swift
//  PiPi
//
//  Created by Jia Jang on 7/31/24.
//

import SwiftUI
import MapKit
import MessageUI

struct TicketDetailView: View {
    @Environment(\.dismiss) var dismiss
    
    @Binding var isLocationVisible: Bool
    @Binding var selectedItem: TicketType
    @Binding var showMessageView: Bool
    @Binding var isAuthenticationDone: Bool
    
    @State private var hostProfile: User?
    @State private var participantProfiles: [User] = []
    @State private var isLoadingHostProfile: Bool = false
    @State private var isLoadingParticipants: Bool = true
    @State private var cameraPosition: MKCoordinateRegion = MKCoordinateRegion(
        center: .postech,
        span: MKCoordinateSpan(latitudeDelta: 0.005, longitudeDelta: 0.005)
    )
    
    private let userDataManager = FirebaseDataManager<User>()
    
    var activity: Activity
    var userProfile: User
    
    var body: some View {
        NavigationStack {
            List {
                activityInfo
                activityStatus
                userInfo
            }
            .foregroundColor(.black)
            .navigationBarTitle("\(activity.title)", displayMode: .inline)
            .navigationBarItems(trailing: doneButton)
        }
        // TODO: 아이메세지 전송 Sheet 추가 예정
        //        .sheet(isPresented: $showMessageView) {
        //            if let email = hostEmail {
        //                iMessageConnect(email: email)
        //            }
        //        }
        .onAppear {
            if activity.hostID != userProfile.id {
                fetchHostProfile()
            }
            
            fetchParticipantProfiles()
            updateMapRegion()
            
            if let isAuthenticated = activity.authentication[userProfile.id] {
                isAuthenticationDone = isAuthenticated
            } else {
                isAuthenticationDone = false
            }
        }
    }
    
    private var doneButton: some View {
        Button("완료") {
            isLocationVisible = false
            dismiss()
        }
    }
    
    private var activityInfo: some View {
        Section {
            listCell(title: "날짜", content: "\(activity.startDateTime.toString().split(separator: "\n").first ?? "")")
            
            listCell(title: "시간", content: "\(activity.startDateTime.toString().split(separator: "\n")[1])")
            
            // FIXME: Camera Position 적용 시 지연 발생
            NavigationLink(destination: mapView) {
                Text("위치")
            }
        } header: {
            Text("모임 정보")
        }
    }
    
    private var activityStatus: some View {
        Section {
            listCell(title: "모집 상태", content: activity.status == .closed ? "모집완료" : "모집중")
            
            listCell(title: "인증 여부", content: isAuthenticationDone ? "완료" : "미완료")
        } header: {
            Text("상태")
        }
    }
    
    private var userInfo: some View {
            Section {
                if selectedItem == .participant {
                    if !userProfile.nickname.isEmpty {
                        HStack {
                            Text("닉네임")
                            
                            Spacer()
                            
                            // FIXME: 실제 주최자의 닉네임으로 변경 필요
                            Text(userProfile.nickname)
                            
                            // FIXME: 문의하기 버튼 탭할 경우 시트가 올라오지 않는 에러 발생
                            Button(action: {
                                showMessageView = true
                            }) {
                                Image(systemName: "ellipsis.message")
                                    .foregroundColor(.gray)
                                    .frame(width: 30, height: 30)
                                    .clipShape(RoundedRectangle(cornerRadius: 10))
                            }
                        }
                    } else {
                        Text("주최자 정보 없음")
                            .foregroundColor(.gray)
                    }
                } else {
                    if !activity.participantID.isEmpty {
                        participantsInfo
                    } else {
                        Text("참가자가 아직 없습니다.")
                            .foregroundColor(.gray)
                    }
                }
            } header: {
                Text(selectedItem == .participant ? "주최자 정보" : "참가자 정보")
            }
    }
    
    private func listCell(title: String, content: String) -> some View {
        HStack {
            Text(title)
            Spacer()
            Text(content)
        }
    }
    
    private var participantsInfo: some View {
        VStack {
            if isLoadingParticipants {
                Text("참가자 정보를 불러오는 중...")
                    .foregroundColor(.gray)
            } else if participantProfiles.isEmpty {
                Text("참가자가 아직 없습니다.")
                    .foregroundColor(.gray)
            } else {
                Form {
                    ForEach(participantProfiles, id: \.id) { participant in
                        Text(participant.nickname)
                    }
                }
            }
        }
    }
    
    private var mapView: some View {
        Map(
            coordinateRegion: $cameraPosition,
            annotationItems: [activity]
        ) { activity in
            MapMarker(
                coordinate: CLLocationCoordinate2D(
                    latitude: activity.coordinates.latitude,
                    longitude: activity.coordinates.longitude
                ),
                tint: .accent
            )
        }
    }
    
    private func updateMapRegion() {
        let coordinate = CLLocationCoordinate2D(
            latitude: activity.coordinates.latitude,
            longitude: activity.coordinates.longitude
        )
        
        cameraPosition = MKCoordinateRegion(
            center: coordinate,
            span: MKCoordinateSpan(latitudeDelta: 0.005, longitudeDelta: 0.005)
        )
    }
    
    private func nicknameOrPlaceholder(_ nickname: String) -> String {
        return nickname.isEmpty ? "닉네임이 없습니다." : nickname
    }
    
    private func fetchHostProfile() {
        isLoadingHostProfile = true
        userDataManager.observeSingleData(eventType: .value, id: activity.hostID) { result in
            switch result {
            case .success(let profile):
                self.hostProfile = profile
            case .failure(let error):
                print("호스트 프로필 가져오기 실패: \(error)")
            }
            self.isLoadingHostProfile = false
        }
    }
    
    private func fetchParticipantProfiles() {
        isLoadingParticipants = true
        let participantEmail = activity.participantID
        
        let group = DispatchGroup()
        var fetchedProfiles: [User] = []
        
        for email in participantEmail {
            group.enter()
            userDataManager.observeSingleData(
                eventType: .value,
                id: email
            ) { result in
                switch result {
                case .success(let profile):
                    fetchedProfiles.append(profile)
                case .failure(let error):
                    print("참가자 프로필 가져오기 실패: \(error)")
                }
                group.leave()
            }
        }
        
        group.notify(queue: .main) {
            self.participantProfiles = fetchedProfiles
            self.isLoadingParticipants = false
        }
    }
}

struct TicketDetailView_Previews: PreviewProvider {
    static var previews: some View {
        TicketDetailView(
            isLocationVisible: .constant(false),
            selectedItem: .constant(.organizer),
            showMessageView: .constant(false),
            isAuthenticationDone: .constant(false),
            activity: Activity(
                hostID: "1D2BF6E6-E2A3-486B-BDCF-F3A450C4A029",
                title: "배드민턴 번개",
                description: "오늘 저녁에 배드민턴 치실 분!",
                maxPeopleNumber: 10,
                category: .alcohol,
                startDateTime: Date(),
                estimatedTime: 2,
                coordinates: Coordinates(latitude: 37.7749, longitude: -122.4194)
            ),
            userProfile: User(
                nickname: "",
                affiliation: .postech,
                email: "sample@example.com"
            )
        )
    }
}
