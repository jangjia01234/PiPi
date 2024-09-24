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
    @State private var showLocationAuthorizeSuccessAlert = false
    @State private var errorMessage: String? = nil
    
    let authorizer = LocationAuthorizer()
    
    var body: some View {
        ZStack {
            VStack {
                VStack {
                    VStack(spacing: 30) {
                        Text("회원가입을 위해\n포스텍 캠퍼스 내에서\n위치를 인증해주세요")
                            .multilineTextAlignment(.center)
                            .font(.title)
                            .bold()
                        
                        Text("포스텍 캠퍼스에서의 안전한 모임을 위해\n현재 위치를 인증해주세요")
                            .multilineTextAlignment(.center)
                            .font(.subheadline)
                            .foregroundStyle(.secondary)
                    }
                    Image("locationAuthorize")
                        .resizable()
                        .aspectRatio(contentMode: .fit)
                }
                VStack(spacing: 20) {
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
                    VStack {
                        Text("이미 가입을 하셨다면")
                            .font(.caption)
                            .fontWeight(.light)
                        
                        NavigationLink(destination: LoginView()) {
                            Text("로그인하러 가기")
                                .underline()
                                .foregroundStyle(.accent)
                        }
                    }
                }
            }
            
            if showProgressView {
                ProgressView()
                    .setAppearance()
            }
        }
        .padding(.horizontal)
        .alert(isPresented: $showLocationAuthorizeFailedAlert) {
            Alert(
                title: Text("인증에 실패했습니다"),
                message: Text(errorMessage ?? ""),
                dismissButton: .cancel(Text("확인"))
            )
        }
        .alert(isPresented: $showLocationAuthorizeSuccessAlert) {
            Alert(
                title: Text("인증에 성공했습니다!"),
                primaryButton: .default(Text("회원가입하기")) {
                    appRootManager.currentRoot = .signUp
                },
                secondaryButton: .cancel(Text("취소"))
            )
        }
    }
    
    private func authorizeLocation() {
        showProgressView = true
        Task {
            switch await authorizer.authorize() {
            case .success(let isValid):
                if isValid {
                    showLocationAuthorizeSuccessAlert = true
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
