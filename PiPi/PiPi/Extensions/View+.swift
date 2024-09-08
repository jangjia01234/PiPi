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
