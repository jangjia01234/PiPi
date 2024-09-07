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
    
    func roundingCorner(_ radius : CGFloat, corners : UIRectCorner) -> some View {
        clipShape(RoundedCorner(radius: radius, corners: corners))
    }
    
}
