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
    
    let activityID: String
    let hostID: String
    
    @State private var activity: Activity?
    @State private var host: UserProfile?
    
    @State private var showJoinAlertView = false
    @State private var showMessageView = false
    @State private var showLocationView = false
    @State private var showActivityIndicator = true
    @State private var disableJoinButton = false
    @State private var errorMessage: String?
    
    var body: some View {
        if let activity,
           let host {
            VStack {
                ActivityDetailHeaderView(
                    activity: $activity
                )
                .padding([.top, .horizontal])
                
                Form {
                    ActivityInformationSectionView(
                        startDateTime: activity.startDateTime,
                        estimatedTime: activity.estimatedTime,
                        maxPeopleNumber: activity.maxPeopleNumber,
                        currentPeopleNumber: activity.participantID.count,
                        category: activity.category,
                        showLocationView: $showLocationView
                    )
                    
                    HostInformationSectionView(
                        nickname: host.nickname,
                        level: host.level
                    )
                }
                .scrollContentBackground(.hidden)
                .scrollBounceBehavior(.basedOnSize)
                .sheet(isPresented: $showLocationView) {
                    SelectedMapView(coordinate: activity.coordinates.toCLLocationCoordinate2D)
                }
                .sheet(isPresented: $showMessageView) {
                    iMessageConnect(email: host.email)
                }
            }
        }
        ActivityDetailFooterView(
            showJoinAlertView: $showJoinAlertView,
            showMessageView: $showMessageView,
            disableJoinButton: $disableJoinButton,
            addParticipant: addParticipant
        )
        .padding(.horizontal)
        .alert(isPresented: $showJoinAlertView) {
            let firstButton = Alert.Button.cancel(Text("취소")) {}
            let secondButton = Alert.Button.default(Text("신청")) {
                addParticipant()
            }
            return Alert(
                title: Text("신청하시겠습니까?"),
                message: Text("신청이 완료된 이벤트는 티켓에 추가됩니다."),
                primaryButton: firstButton, secondaryButton: secondButton
            )
        }
        .overlay {
            ProgressView()
                .opacity(showActivityIndicator ? 1 : 0)
        }
        .onAppear {
            fetchData()
        }
        .onChange(of: activity) {
            showActivityIndicator = (activity == nil) || (host == nil)
            disableJoinButton = !canJoin()
        }
        .onChange(of: host) {
            showActivityIndicator = (activity == nil) || (host == nil)
        }
    }
    
    private func fetchData() {
        FirebaseDataManager.shared.observeData(
            eventType: .value,
            dataType: .activity,
            dataID: activityID
        ) { (result: Result<Activity, Error>) in
            switch result {
            case .success(let fetchedActivity):
                activity = fetchedActivity
            case .failure(let error):
                errorMessage = error.localizedDescription
            }
        }
        
        FirebaseDataManager.shared.fetchData(
            type: .user,
            dataID: hostID
        ) { (result: Result<UserProfile, Error>) in
            switch result {
            case .success(let fetchedUser):
                host = fetchedUser
            case .failure(let error):
                errorMessage = error.localizedDescription
            }
        }
    }
    
    private func canJoin() -> Bool {
        guard let activity,
              let userID else { return false }
        
        return (activity.hostID != userID) && (activity.status == .open) && (!activity.participantID.contains(userID))
    }
    
    private func addParticipant() {
        guard let userID else { fatalError("userID missing!") }
        guard let activity else { return }
        
        if !activity.participantID.contains(userID) {
            let newActivity = activity.addingParticipant(userID)
            
            do {
                try FirebaseDataManager.shared.updateData(newActivity, type: .activity, id: activityID)
                disableJoinButton = true
            } catch {
                print("Error updating activity: \(error.localizedDescription)")
            }
        }
    }
    
}

#Preview {
    ActivityDetailView(
        activityID: "689C0C05-B7A0-4115-ADE0-97C8EF0C9920",
        hostID: "5D9BCEA9-5BA2-4464-94FA-6F574DA1BBD4"
    )
}
