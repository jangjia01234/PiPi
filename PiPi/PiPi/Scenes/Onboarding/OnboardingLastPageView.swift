//
//  OnboardingLastPageView.swift
//  PiPi
//
//  Created by 신혜연 on 7/31/24.
//

import SwiftUI

struct OnboardingLastPageView: View {
    
    @State private var isFirstLaunching = true
    let imageName: String
    let title: String
    let subtitle: String
    @Binding var navigateToProfile: Bool
    
    var body: some View {
        NavigationStack {
            ZStack {
                VStack {
                    Spacer()
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
                    Spacer()
                }
                .padding(.bottom, 20)
                
                Button {
                    //버튼을 누르면 OnboardingProfileView로 이동
                    navigateToProfile = true
                } label: {
                    Text("시작하기")
                        .fontWeight(.bold)
                        .foregroundColor(.white)
                        .frame(width: 332, height: 48)
                        .background(.accent)
                        .cornerRadius(10)
                }
                .padding(.top, 600)
                Button {
                    //버튼을 누르면 OnboardingProfileView로 이동
                    navigateToProfile = true
                } label: {
                    Text("건너뛰기")
                        .foregroundColor(.accent)
                        .font(.system(size: 16))
                }
                .padding(.bottom, 720)
                .padding(.leading, 280)
            }
            .navigationDestination(isPresented: $navigateToProfile) {
                OnboardingProfileView()
            }
        }
    }
}
