//
//  ActivityDetailViewModel.swift
//  PiPi
//
//  Created by 정상윤 on 8/12/24.
//

import Foundation

final class ActivityDetailViewModel: ObservableObject {
    
    @Published var activity: Activity? = nil
    @Published var host: UserProfile? = nil
    @Published var canJoin = false
    
    private let userID: String
    private var activityID: String
    private var hostID: String
    
    init(activityID: String, hostID: String) {
        guard let userID = UserDefaults.standard.string(forKey: "userID") else {
            fatalError("User ID not found!!!")
        }
        self.activityID = activityID
        self.userID = userID
        self.hostID = hostID
        
        observeActivityData()
        observeHostData()
    }
    
    deinit {
        removeAllObservers()
    }
    
    func addParticipant() {
        guard let activity else { return }
        
        if !activity.participantID.contains(userID) {
            let newActivity = activity.addingParticipant(userID)
            
            do {
                try FirebaseDataManager.shared.updateData(newActivity, type: .activity, id: activityID)
            } catch {
                print("Error updating activity: \(error.localizedDescription)")
            }
        }
    }
    
    func refresh(newActivityID: String, newHostID: String) {
        removeAllObservers()
        
        self.activityID = newActivityID
        self.hostID = newHostID
        
        observeActivityData()
        observeHostData()
    }
    
    private func observeActivityData() {
        FirebaseDataManager.shared.observeData(
            eventType: .value,
            dataType: .activity,
            dataID: activityID
        ) { [weak self] (result: Result<Activity, Error>) in
            guard let self else { return }
            
            DispatchQueue.main.async {
                switch result {
                case .success(let fetchedActivity):
                    self.activity = fetchedActivity
                    self.canJoin = (fetchedActivity.hostID != self.userID) && (fetchedActivity.status == .open) && (!fetchedActivity.participantID.contains(self.userID))
                case .failure(let error):
                    dump("Activity data not found: \(error)")
                }
            }
        }
    }
    
    private func observeHostData() {
        FirebaseDataManager.shared.observeData(
            eventType: .value,
            dataType: .user,
            dataID: hostID
        ) { [weak self] (result: Result<UserProfile, Error>) in
            DispatchQueue.main.async {
                switch result {
                case .success(let fetchedUser):
                    self?.host = fetchedUser
                case .failure(let error):
                    dump("Host data not found: \(error)")
                }
            }
        }
    }
    
    private func removeAllObservers() {
        FirebaseDataManager.shared.removeObserver(dataType: .activity, dataID: activityID)
        FirebaseDataManager.shared.removeObserver(dataType: .user, dataID: userID)
    }
    
}
