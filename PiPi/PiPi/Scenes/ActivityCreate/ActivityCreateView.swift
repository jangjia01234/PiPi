//
//  ActivityCreateView.swift
//  PiPi
//
//  Created by 정상윤 on 7/31/24.
//

import SwiftUI

struct ActivityCreateView: View {
    
    @AppStorage("userID") private var userID: String = ""
    
    @Environment(\.dismiss) private var dismiss
    @FocusState private var isFocused
    
    @State private var title = ""
    @State private var description = ""
    @State private var maxPeopleNumber = 1
    @State private var category: Activity.Category = .meal
    @State private var startDateTime = Date()
    @State private var estimatedTime: Int? = nil
    @State private var location: Coordinates? = nil
    
    @State private var needValueFilledAlertIsPresented = false
    @State private var registerAlertIsPresented = false
    
    private var allRequestedValuesFilled: Bool {
        !title.isEmpty && !description.isEmpty && location != nil
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
            .navigationTitle("활동 등록")
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
            .alert("신청하시겠습니까?", isPresented: $registerAlertIsPresented) {
                Button("취소") {}
                Button(action: {
                    registerActivity()
                    dismiss()
                }) {
                    Text("확인")
                }
            } message: {
                Text("이벤트를 직접 개설한 후에는 수정할 수 없습니다.")
            }
        }
        .onAppear {
            if userID.isEmpty {
                fatalError("userID is empty!!")
            }
        }
    }
    
    private func registerActivity() {
        guard let location else { return }
        
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
            try FirebaseDataManager.shared.addData(
                activity,
                type: .activity,
                id: activity.id
            )
        } catch {
            dump(error)
        }
    }
    
}

#Preview {
    ActivityCreateView()
}
