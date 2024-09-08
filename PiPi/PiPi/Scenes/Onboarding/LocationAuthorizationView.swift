//
//  LocationAuthorizationView.swift
//  PiPi
//
//  Created by 정상윤 on 9/7/24.
//

import SwiftUI

struct LocationAuthorizationView: View {
    
    @EnvironmentObject private var appRootManager: AppRootManager
    @State private var showProgressView = false
    @State private var showLocationAuthorizeFailedAlert = false
    @State private var errorMessage: String? = nil
    
    let authorizer = LocationAuthorizer()
    
    var body: some View {
        ZStack {
            VStack {
                VStack(spacing: 70) {
                    VStack(spacing: 30) {
                        Text("포스텍 캠퍼스 내에서\n위치를 인증해주세요")
                            .multilineTextAlignment(.center)
                            .font(.title)
                            .bold()
                        
                        VStack(spacing: 15) {
                            Text("포스텍 캠퍼스에서의 안전한 모임을 위해\n현재 위치를 인증해주세요")
                                .multilineTextAlignment(.center)
                                .font(.subheadline)
                                .foregroundStyle(.secondary)
                        }
                    }
                    Image("locationAuthorize")
                }
                .padding(.bottom, 125)
                
                Button(action: {
                    authorizeLocation()
                }) {
                    Text("위치 인증하기")
                        .fontWeight(.bold)
                        .frame(maxWidth: .infinity, maxHeight: 58)
                        .foregroundStyle(.white)
                        .background(.accent)
                        .clipShape(RoundedRectangle(cornerRadius: 10))
                }
            }
            
            if showProgressView {
                ProgressView()
                    .setAppearance()
            }
        }
        .padding()
        .alert(isPresented: $showLocationAuthorizeFailedAlert) {
            Alert(
                title: Text("인증에 실패했습니다"),
                message: Text(errorMessage ?? ""),
                dismissButton: .cancel(Text("확인"))
            )
        }
    }
    
    private func authorizeLocation() {
        showProgressView = true
        Task {
            switch await authorizer.authorize() {
            case .success(let isValid):
                if isValid {
                    appRootManager.currentRoot = .signUp
                } else {
                    errorMessage = "포스텍 캠퍼스 내에서 다시 시도해주세요!"
                    showLocationAuthorizeFailedAlert = true
                }
            case .failure(let error):
                errorMessage = error.localizedDescription
                showLocationAuthorizeFailedAlert = true
            }
            showProgressView = false
        }
    }
    
}

#Preview {
    LocationAuthorizationView()
}
