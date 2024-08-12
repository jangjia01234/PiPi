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
    @State var lastValidDirections = [NIDiscoveryToken: SIMD3<Float>]()
    @Binding var selectedItem: TicketType
    @Binding var authSuccess: Bool
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
                authSuccess = true
                DispatchQueue.main.asyncAfter(deadline: .now() + 1) {
                    dismiss()
                }
            }
        }
    }
    
    private var selectedItemColor: String {
        return selectedItem == .participant ? "purple" : "orange"
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
            Text("더 가까이 가보세요!")
                .multilineTextAlignment(.center)
                .font(.title3)
                .bold()
            
            Image("link_\(selectedItemColor)")
                .resizable()
                .aspectRatio(contentMode: .fit)
                .frame(width: 200)
        }
    }
    
    private var nowInConnect: some View {
        VStack {
            Text(authSuccess ? "인증에 성공했어요!" : "더 가까이 가보세요!")
                .multilineTextAlignment(.center)
                .font(.title3)
                .bold()
            
            Image(authSuccess ? "success_\(selectedItemColor)" : "link_\(selectedItemColor)")
                .resizable()
                .aspectRatio(contentMode: .fit)
                .frame(width: 200)
                .onAppear {
                    if uwb.discoveredPeers.last!.distance <= 0.2 {
                        authSuccess = true
                        DispatchQueue.main.asyncAfter(deadline: .now() + 1) {
                            dismiss()
                        }
                    }
                }
        }
    }
}
