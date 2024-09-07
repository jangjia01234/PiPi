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
        ZStack{
            VStack {
                Spacer()
                Text(title)
                    .multilineTextAlignment(.center)
                    .font(.title)
                    .fontWeight(.bold)
                    .padding(.bottom, 26)
                Text(subtitle)
                    .multilineTextAlignment(.center)
                    .font(.system(size: 14))
                    .foregroundColor(.gray)
                    .padding(.bottom, 50)
                Image(imageName)
                    .resizable()
                    .frame(width: 396, height: 298)
                    .padding(.bottom, 36)
                Spacer()
            }
            .padding(.bottom, 20)
        }
    }
    
}
