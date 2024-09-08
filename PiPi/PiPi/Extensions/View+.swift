//
//  View+.swift
//  PiPi
//
//  Created by 정상윤 on 7/31/24.
//

import SwiftUI

extension View {
    
    func setShadow() -> some View {
        self
            .shadow(
                color: .black.opacity(0.1),
                radius: 3,
                x: 0,
                y: 2
            )
    }
    
    func setFieldAppearance() -> some View {
        self.font(.body)
            .padding(EdgeInsets(top: 5, leading: 10, bottom: 5, trailing: 10))
            .textFieldStyle(PlainTextFieldStyle())
            .autocapitalization(.none)
            .background(Color(.systemGray6))
            .clipShape(RoundedRectangle(cornerRadius: 8))
    }
    
    func roundingCorner(_ radius : CGFloat, corners : UIRectCorner) -> some View {
        clipShape(RoundedCorner(radius: radius, corners: corners))
    }
    
}

extension ProgressView {
    
    func setAppearance() -> some View {
        self
            .frame(width: 70, height: 70)
            .controlSize(.large)
            .tint(.white)
            .background(.secondary)
            .clipShape(RoundedRectangle(cornerRadius: 10))
    }
    
}
