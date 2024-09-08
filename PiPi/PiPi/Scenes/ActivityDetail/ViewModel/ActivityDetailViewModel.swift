//
//  ActivityDetailViewModel.swift
//  PiPi
//
//  Created by 정상윤 on 8/12/24.
//

import Foundation

final class ActivityDetailViewModel: ObservableObject {
    
    @Published var activity: Activity? = nil
    @Published var host: User? = nil
    @Published var canJoin = false
    
    private let userID: String
    private var activityID: String
    private var hostID: String
    
    private var activityDataManager = FirebaseDataManager<Activity>()
    private var userDataManager = FirebaseDataManager<User>()
    
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
    
    func addParticipant() {
        guard let activity else { return }
        
        if !activity.participantID.contains(userID) {
            let newActivity = activity.addingParticipant(userID)
            
            do {
                try activityDataManager.updateData(newActivity, id: activityID)
            } catch {
                print("Error updating activity: \(error.localizedDescription)")
            }
        }
    }
    
    
    //🔔참가자 지우기 기능 추가
    func deleteParticipant() {
        guard let activity else {
            print("Activity 없음")
            return
        }
        
        if activity.participantID.contains(userID) {
            let updatedActivity = activity.removeParticipant(userID)
            
            do {
                try activityDataManager.updateData(updatedActivity, id: activityID)
                print("참가 취소 성공")  // 🔔 성공 로그 추가
            } catch {
                print("참가 취소 실패: \(error.localizedDescription)")  // 🔔 실패 로그 추가
            }
        } else {
            print("참가자 목록에 사용자가 포함되지 않음")  // 🔔 로그 추가
        }
    }
    
    // 🔔 모임 삭제 기능 추가
    func deleteActivity() {
        activityDataManager.deleteData(id: activityID) { result in
            switch result {
            case .success:
                print("Activity deleted successfully.")
            case .failure(let error):
                print("Error deleting activity: \(error.localizedDescription)")
            }
        }
    }
    
    func refresh(newActivityID: String, newHostID: String) {
        self.activityID = newActivityID
        self.hostID = newHostID
        
        activityDataManager = FirebaseDataManager<Activity>()
        userDataManager = FirebaseDataManager<User>()
        
        observeActivityData()
        observeHostData()
    }
    
    private func observeActivityData() {
        activityDataManager.observeSingleData(
            eventType: .value,
            id: activityID
        ) { [weak self] (result: Result<Activity, Error>) in
            guard let self else { return }
            
            DispatchQueue.main.async {
                switch result {
                case .success(let fetchedActivity):
                    self.activity = fetchedActivity
                    self.canJoin = (fetchedActivity.hostID != self.userID)
                    && (fetchedActivity.status == .open)
                    && (!fetchedActivity.participantID.contains(self.userID))
                case .failure(let error):
                    dump("Activity data not found: \(error)")
                }
            }
        }
    }
    
    private func observeHostData() {
        userDataManager.observeSingleData(
            eventType: .value,
            id: hostID
        ) { [weak self] (result: Result<User, Error>) in
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
    
}
