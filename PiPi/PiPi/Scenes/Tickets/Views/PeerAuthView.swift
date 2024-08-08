//
//  PeerAuthView.swift
//  PiPi
//
//  Created by Jia Jang on 8/7/24.
//

import NearbyInteraction
import SwiftUI

struct PeerAuthView: View {
    @AppStorage("userID") var userID: String?
    @Environment(\.dismiss) private var dismiss
    @ObservedObject var uwb = CBUWB()
    @State var lastValidDirections = [NIDiscoveryToken: SIMD3<Float>]()
    @State var isConfirmed: Bool = false
    @State private var showingAlert = false
    @Binding var isShowingSheet: Bool
    @Binding var isAuthDone: Bool
    
    var activity: Activity
    
    private typealias ActivityDatabaseResult = Result<[String: Activity], Error>
    
    var body: some View {
        ZStack {
            VStack {
                if uwb.discoveredPeers.count > 0 {
                    Text("거리: \(uwb.discoveredPeers.last!.distance)m")
                        .multilineTextAlignment(.center)
                        .font(.title3)
                        .padding(.bottom, 100)
                    
                    if uwb.discoveredPeers.last!.distance > 0.2 {
                        Text("아직 좀 멀어요...")
                            .multilineTextAlignment(.center)
                            .font(.title3)
                            .padding(.bottom, 100)
                    }
                } else {
                    VStack {
                        Image(systemName: "person.fill.questionmark")
                            .font(.system(size: 100))
                            .foregroundColor(.accent)
                            .padding(.bottom, 10)
                        
                        Text("발견된 Peer가 없어요")
                            .multilineTextAlignment(.center)
                            .font(.title3)
                            .padding(.bottom, 100)
                    }
                }
            }
        }
        .alert(isPresented: $showingAlert) {
            Alert(
                title: Text("인증 완료"),
                message: Text("참가자 인증이 완료되었어요"),
                dismissButton: .default(Text("확인"), action: {
                    isAuthDone = true
                    saveAuthStatus()
                    dismiss()
                })
            )
        }
        .onReceive(uwb.$discoveredPeers) { peers in
            for peer in peers {
                if let direction = peer.direction {
                    self.lastValidDirections[peer.token] = direction
                }
            }
            
            if uwb.discoveredPeers.count > 0 &&
                uwb.discoveredPeers.last!.distance < 0.2 {
                isConfirmed = true
                showingAlert = true
            }
        }
    }
    
    private func offset(for peer: DiscoveredPeer) -> CGSize {
        guard let direction = peer.direction ?? lastValidDirections[peer.token] else {
            return CGSize.zero
        }
        
        let x = CGFloat(direction.x * 150)
        let y = CGFloat(direction.y * 150)
        
        return CGSize(width: x, height: -y)
    }
    
    private func saveAuthStatus() {
        guard let userID = userID else { return }
        
        let activity = Activity(
            id: userID,
            hostID: activity.hostID,
            title: activity.title,
            description: activity.description,
            maxPeopleNumber: activity.maxPeopleNumber,
            participantID: activity.participantID,
            category: activity.category,
            startDateTime: activity.startDateTime,
            estimatedTime: activity.estimatedTime,
            coordinates: activity.coordinates
            
            // TODO: 인증 상태 가져와야함 (Activity 코드 업뎃 후 반영 예정)
            // authentication: activity.authentication
        )
        
        do {
            try FirebaseDataManager.shared.updateData(activity, type: .activity, id: activity.id)
            print("activity status 수정 성공")
        } catch {
            print("activity status 수정 실패: \(error.localizedDescription)")
        }
    }
}

//#Preview {
//    PeerAuthView(isShowingSheet: .constant(false), isAuthDone: .constant(false))
//}
