//
//  ActivityDetailView.swift
//  PiPi
//
//  Created by Byeol Kim on 7/30/24.
//

import SwiftUI
import MapKit
import CoreLocation
import Firebase
import FirebaseDatabase

struct ActivityDetailView: View {
    
    @AppStorage("userID") private var userID: String?
    
    @StateObject private var viewModel: ActivityDetailViewModel
    
    @State private var showJoinAlertView = false
    @State private var showMessageView = false
    @State private var showLocationView = false
    @State private var showActivityIndicator = true
    @State private var disableJoinButton = false
    
    init(activityID: String, hostID: String) {
        _viewModel = StateObject(wrappedValue: ActivityDetailViewModel(activityID: activityID, hostID: hostID))
    }
    
    var body: some View {
        if let activity = viewModel.activity,
           let host = viewModel.host {
            VStack {
                ActivityDetailHeaderView(
                    activity: $viewModel.activity
                )
                .padding([.top, .horizontal])
                
                Form {
                    ActivityInformationSectionView(
                        activity: activity,
                        showLocationView: $showLocationView
                    )
                    HostInformationSectionView(host: host)
                }
                .scrollContentBackground(.hidden)
                .scrollBounceBehavior(.basedOnSize)
                .sheet(isPresented: $showLocationView) {
                    if let activity = viewModel.activity {
                        SelectedMapView(coordinate: activity.coordinates)
                    }
                }
                .sheet(isPresented: $showMessageView) {
                    if let host = viewModel.host {
                        iMessageConnect(email: host.email)
                    }
                }
            }
            ActivityDetailFooterView(
                showJoinAlertView: $showJoinAlertView,
                showMessageView: $showMessageView,
                disableJoinButton: $disableJoinButton
            )
            .padding(.horizontal)
            .alert(isPresented: $showJoinAlertView) {
                let firstButton = Alert.Button.cancel(Text("취소")) {}
                let secondButton = Alert.Button.default(Text("신청")) {
                    viewModel.addParticipant()
                }
                return Alert(
                    title: Text("신청하시겠습니까?"),
                    message: Text("신청이 완료된 이벤트는 티켓에 추가됩니다."),
                    primaryButton: firstButton, secondaryButton: secondButton
                )
            }
            .onChange(of: viewModel.activity) {
                disableJoinButton = !viewModel.canJoin()
            }
        } else {
            ProgressView()
        }
    }
    
}

#Preview {
    ActivityDetailView(
        activityID: "689C0C05-B7A0-4115-ADE0-97C8EF0C9920",
        hostID: "5D9BCEA9-5BA2-4464-94FA-6F574DA1BBD4"
    )
}
