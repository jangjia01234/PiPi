//
//  PeerAuthView.swift
//  PiPi
//
//  Created by Jia Jang on 8/7/24.
//

import SwiftUI
import NearbyInteraction

struct PeerAuthView: View {
    @AppStorage("userID") var userID: String?
    @Environment(\.dismiss) private var dismiss
    @ObservedObject var uwb = CBUWB()
    
    @Binding var isAuthenticationDone: Bool
    @State var lastValidDirections = [NIDiscoveryToken: SIMD3<Float>]()
    
    var activity: Activity
    
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
        .onReceive(uwb.$discoveredPeers) { peers in
            for peer in peers {
                if let direction = peer.direction {
                    lastValidDirections[peer.token] = direction
                }
            }
            
            if uwb.discoveredPeers.count > 0 && uwb.discoveredPeers.last!.distance <= 0.2 {
                isAuthenticationDone = true
                
                DispatchQueue.main.asyncAfter(deadline: .now() + 1) {
                    dismiss()
                }
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
                .onAppear {
                    if uwb.discoveredPeers.last!.distance <= 0.2 {
                        isAuthenticationDone = true
                        
                        DispatchQueue.main.asyncAfter(deadline: .now() + 1) {
                            dismiss()
                        }
                    }
                }
        }
    }
}
