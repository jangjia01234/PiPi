//
//  PeerAuthView.swift
//  PiPi
//
//  Created by Jia Jang on 8/7/24.
//

import NearbyInteraction
import SwiftUI

struct PeerAuthView: View {
    // MARK: - 유저의 앱스토리지 ID 선언
    // 매번 불러와야 하나?
    @AppStorage("userID") var userID: String?
    
    // MARK: - dismiss를 위한 환경변수 선언
    @Environment(\.dismiss) private var dismiss
    
    // MARK: - Nearby Interaction을 위한 코드: UWB 선언
    @ObservedObject var uwb = CBUWB()
    
    // MARK: - Nearby Interaction을 위한 코드: ?
    @State var lastValidDirections = [NIDiscoveryToken: SIMD3<Float>]()
    
    // MARK: - 🔥
    // 확인 및 네이밍 개선 필요
    @State var isConfirmed: Bool = false
    @State private var showingAlert = false
    
    // MARK: - 🔥
    // 확인 및 네이밍 개선 필요
    @Binding var isShowingSheet: Bool
    
    // MARK: - 🔥
    // 확인 및 네이밍 개선 필요
    @Binding var isAuthDone: Bool
    
    var activity: Activity
    
    // MARK: - 🫥 확인 필요
    private typealias ActivityDatabaseResult = Result<[String: Activity], Error>
    
    var body: some View {
        ZStack {
            VStack {
                // 거리가 0 이상일 때
                if uwb.discoveredPeers.count > 0 {
                    // 거리는 이 정도입니다
                    Text("거리: \(uwb.discoveredPeers.last!.distance)m")
                        .multilineTextAlignment(.center)
                        .font(.title3)
                        .padding(.bottom, 100)
                    
                    // 아직 거리 범위 안에 안들어왔을 때
                    if uwb.discoveredPeers.last!.distance > 0.2 {
                        Text("아직 좀 멀어요...")
                            .multilineTextAlignment(.center)
                            .font(.title3)
                            .padding(.bottom, 100)
                    }
                } else {
                    // MARK: - 인증 중 화면
                    // 인증 완료되기 전에 뜨는 심볼
                    VStack {
                        Image(systemName: "person.fill.questionmark")
                            .font(.system(size: 100))
                            .foregroundColor(.accent)
                            .padding(.bottom, 10)
                        
                        // 인증 완료되기 전에 뜨는 텍스트
                        Text("발견된 Peer가 없어요")
                            .multilineTextAlignment(.center)
                            .font(.title3)
                        .padding(.bottom, 100)
                    }
                }
            }
        }
        // MARK: - 인증 완료되면 뜨는 alert
        .alert(isPresented: $showingAlert) {
            Alert(
                title: Text("인증 완료"),
                message: Text("참가자 인증이 완료되었어요"),
                dismissButton: .default(Text("확인"), action: {
                    isAuthDone = true
//                    saveAuthStatus()
                    dismiss()
                })
            )
        }
        // MARK: - Peer 감지 관련 코드
        .onReceive(uwb.$discoveredPeers) { peers in
            for peer in peers {
                if let direction = peer.direction {
                    self.lastValidDirections[peer.token] = direction
                }
            }
            
            // 발견된 Peer가 있고 + 거리가 0.2 미만이면 실행
            if uwb.discoveredPeers.count > 0 &&
                uwb.discoveredPeers.last!.distance < 0.2 {
                isConfirmed = true
                showingAlert = true
            }
        }
    }
    
    // MARK: - Nearby Interaction 계산 로직 (나도 잘 모름..)
    private func offset(for peer: DiscoveredPeer) -> CGSize {
        guard let direction = peer.direction ?? lastValidDirections[peer.token] else {
            return CGSize.zero
        }
        
        let x = CGFloat(direction.x * 150)
        let y = CGFloat(direction.y * 150)
        
        return CGSize(width: x, height: -y)
    }
}

// MARK: - 에러를 없애기 위해 프리뷰 주석처리
//#Preview {
//    PeerAuthView(isShowingSheet: .constant(false), isAuthDone: .constant(false))
//}
