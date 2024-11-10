//
//  PeerAuthView.swift
//  PiPi
//
//  Created by Jia Jang on 8/7/24.
//

import SwiftUI
import NearbyInteraction

struct PeerAuthView: View {
    @Environment(\.dismiss) private var dismiss
    @ObservedObject var uwb: CBUWB
    
    @State var lastValidDirections = [NIDiscoveryToken: SIMD3<Float>]()
    @State var isNearbyAuthDone: Bool = false
    
    private let activity: Activity
    private let userID = FirebaseAuthManager.shared.currentUser?.uid
    private let activityDataManager = FirebaseDataManager<Activity>()
    
    init(activity: Activity) {
        self.activity = activity
        self.uwb = CBUWB(activityID: activity.id)
    }
    
    var body: some View {
        VStack {
            if uwb.discoveredPeers.count > 0 {
                nowInConnect
            } else {
                readyToConnect
            }
        }
        .onReceive(uwb.$discoveredPeers) { peers in
            for peer in peers {
                if let direction = peer.direction {
                    lastValidDirections[peer.token] = direction
                }
            }
            
            dump(uwb.discoveredPeers)
            
            // MARK: 인증이 완료되면 참가자가 자신의 id와 완료 여부를 activity에 업데이트
            if uwb.discoveredPeers.count > 0 && uwb.discoveredPeers.last!.distance <= 0.2 {
                if let userID = userID {
                    isNearbyAuthDone = true
                    
                    if userID != activity.hostID {
                        let updatedActivity = activity.updatingAuthentication(userID: userID, isDone: true)
                        
                        do {
                            try activityDataManager.updateData(updatedActivity, id: activity.id)
                            print("Firebase에 인증 상태 업데이트 성공")
                        } catch {
                            print("Firebase 업데이트 실패: \(error.localizedDescription)")
                        }
                    } else {
                        print("호스트가 인증 상태를 업데이트하지 않습니다.")
                    }
                }
                
                DispatchQueue.main.asyncAfter(deadline: .now() + 1) {
                    dismiss()
                }
            }
        }
    }
    
    private var readyToConnect: some View {
        VStack {
            Text("핸드폰을 가까이 대서\n인증해주세요!")
                .multilineTextAlignment(.center)
                .font(.system(size: 28))
                .fontWeight(.heavy)
            
            Image("auth_ing")
                .resizable()
                .aspectRatio(contentMode: .fit)
                .frame(width: 350)
        }
    }
    
    private var nowInConnect: some View {
        VStack {
            Text(isNearbyAuthDone ? "인증에 성공했어요!" : "핸드폰을 가까이 대서\n인증해주세요!")
                .multilineTextAlignment(.center)
                .font(.system(size: 28))
                .fontWeight(.heavy)
            
            Image(isNearbyAuthDone ? "auth_done" : "auth_ing")
                .resizable()
                .aspectRatio(contentMode: .fit)
                .frame(width: 350)
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
}
