//
//  TicketDetailView.swift
//  PiPi
//
//  Created by Jia Jang on 7/31/24.
//

import SwiftUI
import FirebaseDatabase
import MapKit

struct TicketDetailView: View {
    @Environment(\.dismiss) var dismiss
    @State private var activities: [Activity] = []
    @Binding var isParticipantList: Bool
    @Binding var isLocationVisible: Bool
    
    // TODO: 머지 후 주석 해제 (지도 코드 활용)
    // @Namespace private var mapScope
    // @State private var cameraPosition: MapCameraPosition = .defaultPosition
    
    var activity: Activity
    var userProfile: UserProfile
    
    private typealias ActivityDatabaseResult = Result<[String: Activity], Error>
    private typealias UserDatabaseResult = Result<UserProfile, Error>
    
    var body: some View {
        NavigationStack {
            VStack {
                if let activity = activities.first {
                    if isParticipantList {
                        if activity.participantID.count > 0 {
                            Form {
                                ForEach(activity.participantID, id: \.self) { participant in
                                    Text(participant)
                                }
                            }
                        } else {
                            Text("참가자가 아직 없습니다.")
                        }
                    } else if isLocationVisible {
                        // TODO: 머지 후 주석 해제 (지도 코드 활용)
//                        Map(
//                            position: $cameraPosition,
//                            bounds: .init(
//                                centerCoordinateBounds: .cameraBoundary,
//                                minimumDistance: 500,
//                                maximumDistance: 3000
//                            ),
//                            scope: mapScope
//                        ) {
//                            Marker("\(activity.title)", coordinate: CLLocationCoordinate2D(latitude: activity.coordinates.latitude, longitude: activity.coordinates.longitude))
//                                .tint(.accent)
//                        }
                    } else {
                        if activity.hostID == userProfile.id {
                            Text("주최자 닉네임: \(userProfile.nickname)")
                        }
                    }
                }
            }
            .navigationBarTitle("상세정보", displayMode: .inline)
            .navigationBarItems(trailing: Button("완료", action: {
                dismiss()
            }))
        }
        .foregroundColor(.black)
        .onAppear {
            FirebaseDataManager.shared.observeData(eventType: .value, dataType: .activity) { (result: Result<[String: Activity], Error>) in
                switch result {
                case .success(let result):
                    dump(result)
                case .failure(let error):
                    dump(error)
                }
            }
        }
    }
}

//#Preview {
//    TicketDetailView(isParticipantList: .constant(false), isLocationVisible: .constant(false))
//}
