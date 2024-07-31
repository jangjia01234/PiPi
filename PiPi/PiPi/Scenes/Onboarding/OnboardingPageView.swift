//
//  OnboardingPageView.swift
//  PiPi
//
//  Created by 신혜연 on 7/30/24.
//

import SwiftUI

struct OnboardingPageView: View {
    let imageName: String
    let title: String
    let subtitle: String
    
    var body: some View {
        VStack {
            // 이미지로 변경
            Image(imageName)
                .resizable()
                .frame(width: 288, height: 290)
                .padding(.bottom, 36)
            Text(title)
                .multilineTextAlignment(.center)
                .font(.title)
                .fontWeight(.bold)
                .padding(.bottom, 26)
            Text(subtitle)
                .multilineTextAlignment(.center)
                .font(.footnote)
                .foregroundColor(.gray)
        }
        .padding(.bottom, 20)
    }
}
