//
//  TicketDetailView.swift
//  PiPi
//
//  Created by Jia Jang on 7/31/24.
//

import SwiftUI
import MapKit

struct TicketDetailView: View {
    @Environment(\.dismiss) var dismiss
    @Binding var isLocationVisible: Bool
    @State private var cameraPosition: MKCoordinateRegion = MKCoordinateRegion(
        center: .postech,
        span: MKCoordinateSpan(latitudeDelta: 0.005, longitudeDelta: 0.005)
    )
    
    var activity: Activity
    var userProfile: User
    
    @State private var hostProfile: User?
    @State private var participantProfiles: [User] = []
    @State private var isLoadingHostProfile: Bool = false
    @State private var isLoadingParticipants: Bool = true
    
    private let userDataManager = FirebaseDataManager<User>()
    
    var body: some View {
        NavigationStack {
            VStack {
                if isLocationVisible {
                    mapView
                } else {
                    detailsView
                }
            }
            .foregroundColor(.black)
            .navigationBarTitle("상세정보", displayMode: .inline)
            .navigationBarItems(trailing: doneButton)
            .onAppear {
                if activity.hostID != userProfile.id {
                    fetchHostProfile()
                }
                fetchParticipantProfiles()
                updateMapRegion()
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
    
    private var detailsView: some View {
        VStack {
            if isLoadingParticipants {
                Text("참가자 정보를 불러오는 중...")
                    .foregroundColor(.gray)
            } else if participantProfiles.isEmpty {
                Text("참가자가 아직 없습니다.")
                    .foregroundColor(.gray)
            } else {
                participantListView
            }
        }
    }
    
    private var participantListView: some View {
        Form {
            ForEach(participantProfiles, id: \.id) { participant in
                Text(participant.nickname)
            }
        }
    }
    
    private var doneButton: some View {
        Button("완료") {
            isLocationVisible = false
            dismiss()
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
            isLocationVisible: .constant(true),
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
                nickname: "Sample User",
                affiliation: .postech,
                email: "sample@example.com"
            )
        )
    }
}
