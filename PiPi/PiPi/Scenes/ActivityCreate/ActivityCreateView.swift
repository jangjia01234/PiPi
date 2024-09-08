//
//  ActivityCreateView.swift
//  PiPi
//
//  Created by 정상윤 on 7/31/24.
//

import SwiftUI

struct ActivityCreateView: View {
    
    @Environment(\.dismiss) private var dismiss
    @FocusState private var isFocused
    
    @State private var title: String
    @State private var description: String
    @State private var maxPeopleNumber: Int
    @State private var category: Activity.Category
    @State private var startDateTime: Date
    @State private var estimatedTime: Int?
    @State private var location: Coordinates?
    @State private var needValueFilledAlertIsPresented = false
    @State private var registerAlertIsPresented = false
    
    var activity: Activity?
    var isEditing: Bool
    
    private let userID = FirebaseAuthManager.shared.currentUser?.uid
    private let activityDataManager = FirebaseDataManager<Activity>()
    
    private var allRequestedValuesFilled: Bool {
        !title.isEmpty && !description.isEmpty && location != nil
    }
    
    init(activity: Activity? = nil) {
        self.activity = activity
        self.title = activity?.title ?? ""
        self.description = activity?.description ?? ""
        self.maxPeopleNumber = activity?.maxPeopleNumber ?? 2
        self.category = activity?.category ?? .meal
        self.startDateTime = activity?.startDateTime ?? Date()
        self.estimatedTime = activity?.estimatedTime ?? nil
        self.location = activity?.coordinates ?? nil
        self.isEditing = (activity != nil)
    }
    
    var body: some View {
        NavigationStack {
            ActivityInformationFormView(
                title: $title,
                description: $description,
                maxPeopleNumber: $maxPeopleNumber,
                category: $category,
                startDateTime: $startDateTime,
                estimatedTime: $estimatedTime,
                location: $location
            )
            .padding(.top)
            .background(Color(.secondarySystemBackground))
            .navigationTitle(isEditing ? "활동 수정" : "활동 등록")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .topBarLeading) {
                    Button("취소") {
                        dismiss()
                    }
                }
                
                ToolbarItem(placement: .topBarTrailing) {
                    Button("완료") {
                        if allRequestedValuesFilled {
                            registerAlertIsPresented = true
                        } else {
                            needValueFilledAlertIsPresented = true
                        }
                    }
                }
            }
            .alert("필요한 정보를 모두 채워주세요!", isPresented: $needValueFilledAlertIsPresented) {
                Button("확인") {}
            }
            .alert(isEditing ? "수정하시겠습니까?" : "등록하시겠습니까?", isPresented: $registerAlertIsPresented) {
                Button("취소") {}
                Button(action: {
                    if isEditing {
                        updateActivity()
                    } else {
                        registerActivity()
                    }
                    dismiss()
                }) {
                    Text("확인")
                }
            }
        }
    }
    
    private func registerActivity() {
        guard let location else { return }
        guard let userID else { fatalError("userID doesn't exist!!") }
        
        let activity = Activity(
            hostID: userID,
            title: title,
            description: description,
            maxPeopleNumber: maxPeopleNumber,
            participantID: [],
            category: category,
            startDateTime: startDateTime,
            estimatedTime: estimatedTime,
            coordinates: location
        )
        
        do {
            try activityDataManager.addData(
                activity,
                id: activity.id
            )
        } catch {
            dump(error)
        }
    }
    
    private func updateActivity() {
        guard let activity = activity,
              let location = location else { return }
        
        let updatedActivity = Activity(
            id: activity.id,
            hostID: activity.hostID,
            title: title,
            description: description,
            maxPeopleNumber: maxPeopleNumber,
            participantID: activity.participantID,
            category: category,
            startDateTime: startDateTime,
            estimatedTime: estimatedTime,
            coordinates: location,
            authentication: activity.authentication
        )
        
        do {
            try activityDataManager.updateData(
                updatedActivity,
                id: updatedActivity.id
            )
        } catch {
            dump(error)
        }
    }
    
}

#Preview {
    ActivityCreateView(activity: Activity.sampleData)
}
