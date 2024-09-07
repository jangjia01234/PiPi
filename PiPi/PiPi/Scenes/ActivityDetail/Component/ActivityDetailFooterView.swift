//
//  ActivityDetailFooterView.swift
//  PiPi
//
//  Created by 정상윤 on 8/7/24.
//

import SwiftUI

struct ActivityDetailFooterView: View {
    
    @Binding var showJoinAlertView: Bool
    @Binding var showMessageView: Bool
    @Binding var enableJoinButton: Bool
    
    var body: some View {
        HStack {
            Button(action: {
                showJoinAlertView = true
            }) {
                Text("참가 신청")
                    .font(.callout)
                    .fontWeight(.bold)
                    .frame(maxWidth: .infinity)
                    .frame(height: 50)
            }
            .background(!enableJoinButton ? Color(.lightGray) : Color.accent)
            .tint(.white)
            .clipShape(RoundedRectangle(cornerRadius: 10))
            .disabled(!enableJoinButton)
            
            Button(action: {
                showMessageView = true
            }) {
                Image(systemName: "ellipsis.message")
                    .foregroundColor(.white)
                    .frame(width: 45, height: 45)
                    .background(.gray)
                    .clipShape(RoundedRectangle(cornerRadius: 10))
            }
        }
    }
    
}

#Preview {
    ActivityDetailFooterView(
        showJoinAlertView: .constant(false),
        showMessageView: .constant(false),
        enableJoinButton: .constant(false)
    )
}
