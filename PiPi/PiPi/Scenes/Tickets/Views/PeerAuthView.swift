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
    @ObservedObject var uwb = CBUWB()
    @Binding var isAuthenticationDone: Bool
    @State var lastValidDirections = [NIDiscoveryToken: SIMD3<Float>]()
    
    @State var isAuthenticated: Bool = false
    
    var activity: Activity
    private let userID = FirebaseAuthManager.shared.currentUser?.uid
    private let activityDataManager = FirebaseDataManager<Activity>()
    
    var body: some View {
        ZStack {
            VStack {
                if uwb.discoveredPeers.count > 0 {
                    nowInConnect
                } else {
                    readyToConnect
                }
            }
        }
//        .onAppear {
//            fetchAuthenticationStatus()
//        }
        .onReceive(uwb.$discoveredPeers) { peers in
            for peer in peers {
                if let direction = peer.direction {
                    lastValidDirections[peer.token] = direction
                }
            }
            
            // MARK: 1. 인증이 완료되면
            if uwb.discoveredPeers.count > 0 && uwb.discoveredPeers.last!.distance <= 0.2 {
                isAuthenticationDone = true
                
//                do {
//                    try activityDataManager.updateData(activity, id: activity.id)
//                    print("activityDataManager 수정 성공")
//                } catch {
//                    print("activityDataManager 수정 실패: \(error.localizedDescription)")
//                }
                
//                if let userID = userID {
//                    do {
//                        try activityDataManager.updateData(activity, id: activity.id)
//                        isAuthenticated = true
//                        print("Firebase에 인증 상태 업데이트 성공")
//                    } catch {
//                        print("Firebase 업데이트 실패: \(error.localizedDescription)")
//                    }
//                }
                
                // MARK: 2. 참가자가 자신의 id와 완료 여부를 activity에 업데이트
                // 1) 참가자의 id에 해당하는 액티비티를 찾기
                // 2) 해당 액티비티에 [id:done] 업데이트
                // 3) 해당 액티비티 최신으로 업데이트 observe
                
                if let userID = userID {
                    if userID != activity.hostID {
                        let updatedActivity = activity.updatingAuthentication(userID: userID, isDone: true)
                        
                        do {
                            try activityDataManager.updateData(updatedActivity, id: activity.id)
                            isAuthenticated = true
                            print("Firebase에 인증 상태 업데이트 성공")
                        } catch {
                            print("Firebase 업데이트 실패: \(error.localizedDescription)")
                        }
                    } else {
                        print("호스트는 인증 상태를 업데이트하지 않습니다.")
                    }
                }
                
                DispatchQueue.main.asyncAfter(deadline: .now() + 1) {
                    dismiss()
                }
            }
        }
    }
    
//    private func fetchAuthenticationStatus() {
//            guard let userID = userID else { return }
//            
//            // Firebase에서 현재 활동의 인증 상태를 가져옴
//            activityDataManager.observeSingleData(eventType: .value, id: activity.id) { result in
//                switch result {
//                case .success(let activity):
//                    // 해당 유저의 인증 상태를 가져와서 업데이트
//                    self.isAuthenticated = activity.authentication[userID] ?? false
//                case .failure(let error):
//                    print("Firebase에서 인증 상태 가져오기 실패: \(error)")
//                }
//            }
//        }
    
    private func offset(for peer: DiscoveredPeer) -> CGSize {
        guard let direction = peer.direction ?? lastValidDirections[peer.token] else {
            return CGSize.zero
        }
        let x = CGFloat(direction.x * 150)
        let y = CGFloat(direction.y * 150)
        return CGSize(width: x, height: -y)
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
            Text(isAuthenticationDone ? "인증에 성공했어요!" : "핸드폰을 가까이 대서\n인증해주세요!")
                .multilineTextAlignment(.center)
                .font(.system(size: 28))
                .fontWeight(.heavy)
            
            Image(isAuthenticationDone ? "auth_done" : "auth_ing")
                .resizable()
                .aspectRatio(contentMode: .fit)
                .frame(width: 350)
        }
    }
}
