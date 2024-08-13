//
//  OnboardingTabView.swift
//  PiPi
//
//  Created by 신혜연 on 7/30/24.
//

import SwiftUI

struct OnboardingTabView: View {
    
    init() {
        UIPageControl.appearance().currentPageIndicatorTintColor = .accent
        UIPageControl.appearance().pageIndicatorTintColor = UIColor.accent.withAlphaComponent(0.2)
    }
    
    @State private var moveToProfile = false
    
    var body: some View {
        VStack {
            HStack {
                Spacer()
                Button {
                    moveToProfile = true
                } label: {
                    Text("시작하기")
                        .foregroundColor(.accent)
                        .font(.callout)
                }
            }
            .padding()
            
            TabView {
                ForEach(onboardingInfo, id: \.title) { info in
                    OnboardingPageView(imageName: info.imageName, title: info.title, subtitle: info.subtitle)
                }
            }
            .tabViewStyle(PageTabViewStyle(indexDisplayMode: .always))
            .fullScreenCover(isPresented: $moveToProfile) {
                OnboardingProfileView()
            }
        }
    }
    
}

private extension OnboardingTabView {
    
    struct OnboardingInfo {
        
        let imageName: String
        let title: String
        let subtitle: String
        
    }
    
    var onboardingInfo: [OnboardingInfo] {
        [
            OnboardingInfo(
                imageName: "onboarding1",
                title: "포피와 애피의 만남을 점으로 찍어보세요",
                subtitle: "가깝지만 먼 포스텍 피플과 애플 피플의 교집합"
            ),
            OnboardingInfo(
                imageName: "onboarding2",
                title: "우리가 같이 놀 수 있는 이벤트를 등록해요",
                subtitle: "접점을 통해 우리가 만들어가는 플레이그라운드"
            ),
            OnboardingInfo(
                imageName: "onboarding3",
                title: "맘에 드는 이벤트를\n 신청해요",
                subtitle: "다양한 카테고리로 모인 우리가 점을 찍어 만든 커넥팅 닷"
            ),
            OnboardingInfo(
                imageName: "onboarding4",
                title: "핸드폰을 가까이 대서\n활동을 인증해요",
                subtitle: "직접 만나 활동을 인증하고 우리 사이 원 만들기"
            )
        ]
    }
    
}

#Preview {
    OnboardingTabView()
}
