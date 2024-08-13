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
    var userProfile: UserProfile
    
    @State private var hostProfile: UserProfile?
    @State private var isLoadingHostProfile: Bool = false
    
    var body: some View {
        NavigationStack {
            VStack {
                // FIXME: 위치 확인 문제 해결 필요
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
            if activity.hostID == userProfile.id {
                if activity.participantID.count > 0 {
                    participantListView
                } else {
                    Text("참가자가 아직 없습니다.")
                }
            } else {
                if let hostProfile = hostProfile {
                    Text("주최자 닉네임: \(nicknameOrPlaceholder(hostProfile.nickname))")
                }
            }
        }
    }
    
    private var participantListView: some View {
        Form {
            ForEach(activity.participantID, id: \.self) { participant in
                if participant == userProfile.id {
                    Text(userProfile.nickname)
                }
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
}
