//
//  PeerAuthView.swift
//  PiPi
//
//  Created by Jia Jang on 8/7/24.
//

import NearbyInteraction
import SwiftUI

struct PeerAuthView: View {
    @Environment(\.dismiss) private var dismiss
    @ObservedObject var uwb = CBUWB()
    @State var lastValidDirections = [NIDiscoveryToken: SIMD3<Float>]()
    @State var isConfirmed: Bool = false
    @State private var showingAlert = false
    @Binding var isShowingSheet: Bool
    @Binding var isAuthDone: Bool
    
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
                dismissButton: .default(Text("확인"), action: { dismiss() })
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
}

#Preview {
    PeerAuthView(isShowingSheet: .constant(false), isAuthDone: .constant(false))
}
