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
    @State private var cameraPosition: MapCameraPosition = .defaultPosition
    
    var activity: Activity
    var userProfile: User
    
    @State private var hostProfile: User?
    @State private var participantProfiles: [User] = []
    @State private var isLoadingHostProfile: Bool = false
    @State private var isLoadingParticipants: Bool = true
    
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
            }
        }
    }
    
    private var mapView: some View {
        Map(
            position: $cameraPosition,
            bounds: .init(
                centerCoordinateBounds: .cameraBoundary,
                minimumDistance: 500,
                maximumDistance: 3000
            )
        ) {
            Marker("\(activity.title)", coordinate: CLLocationCoordinate2D(latitude: activity.coordinates.latitude, longitude: activity.coordinates.longitude))
                .tint(.accent)
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
    
    private func nicknameOrPlaceholder(_ nickname: String) -> String {
        return nickname.isEmpty ? "닉네임이 없습니다." : nickname
    }
    
    private func fetchHostProfile() {
        isLoadingHostProfile = true
        FirebaseDataManager.shared.fetchData(type: .user, dataID: activity.hostID) { (result: Result<UserProfile, Error>) in
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
        let participantIDs = activity.participantID
        
        let group = DispatchGroup()
        var fetchedProfiles: [UserProfile] = []
        
        for participantID in participantIDs {
            group.enter()
            FirebaseDataManager.shared.observeData(
                eventType: .value,
                dataType: .user,
                dataID: participantID
            ) { (result: Result<UserProfile, Error>) in
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
