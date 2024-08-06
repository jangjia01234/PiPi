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
    
    private typealias DatabaseResult = Result<[String: Activity], Error>
    
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
                        Map() {
                            // TODO: Level 조절 필요 (더 멀리)
                            Marker("약속 장소", coordinate: CLLocationCoordinate2D(latitude: activity.coordinates.latitude, longitude: activity.coordinates.longitude))
                                .tint(.accent)
                        }
                    } else {
                        Text("주최자 닉네임: \(activity.hostID)")
                    }
                }
            }
            .navigationBarTitle("상세정보", displayMode: .inline)
            .navigationBarItems(trailing: Button("완료", action: {
                dismiss()
            }))
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
        .foregroundColor(.black)
    }
}

#Preview {
    TicketDetailView(isParticipantList: .constant(false), isLocationVisible: .constant(false))
}
