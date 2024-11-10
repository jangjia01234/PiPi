//
//  TicketDetailView.swift
//  PiPi
//
//  Created by Jia Jang on 7/31/24.
//

import SwiftUI
import MapKit
import MessageUI

struct TicketDetailView: View {
    @Environment(\.dismiss) var dismiss
    @ObservedObject var viewModel: ActivityDetailViewModel
    
    @Binding var isLocationVisible: Bool
    @Binding var selectedItem: TicketType
    @Binding var showMessageView: Bool
    
    @State private var isEditing: Bool = false
    @State private var imessageReceiverEmail: String?
    @State private var showAlert = false
    @State private var hostProfile: User?
    @State private var participantProfiles: [User] = []
    @State private var isLoadingHostProfile: Bool = false
    @State private var isLoadingParticipants: Bool = true
    @State private var cameraPosition: MKCoordinateRegion = MKCoordinateRegion(
        center: .postech,
        span: MKCoordinateSpan(latitudeDelta: 0.005, longitudeDelta: 0.005)
    )
    
    private let userID = FirebaseAuthManager.shared.currentUser?.uid
    private let userDataManager = FirebaseDataManager<User>()
    
    var activity: Activity
    var userProfile: User
    
    var body: some View {
        NavigationStack { detailList }
        .onAppear {
            fetchHostProfile()
            fetchParticipantProfiles()
            updateMapRegion()
        }
        .sheet(isPresented: $isEditing) {
            ActivityCreateView(activity: activity)
        }
        .sheet(isPresented: $showMessageView) {
            if let email = imessageReceiverEmail {
                iMessageConnect(email: email)
            }
        }
    }
    
    // MARK: - Subviews
    private var detailList: some View {
        List {
            activityInfo
            activityStatus
            userInfo
            actionButton()
        }
        .navigationBarTitle("\(activity.title)", displayMode: .inline)
        .navigationBarItems(trailing: doneButton)
    }
    
    private var doneButton: some View {
        Button("완료") {
            isLocationVisible = false
            dismiss()
        }
    }
    
    private var activityInfo: some View {
        Section {
            listCell(title: "활동명", content: activity.title)
            listCell(title: "날짜", content: "\(activity.startDateTime.toString().split(separator: "\n").first ?? "")")
            listCell(title: "시간", content: "\(activity.startDateTime.toString().split(separator: "\n")[1])")
            
            // FIXME: Camera Position 적용 시 지연 발생
            NavigationLink(destination: mapView) { Text("위치") }
        } header: {
            HStack{
                Text("모임 정보")
                Spacer()
                
                if selectedItem == .organizer { editButton }
            }
        }
    }
    
    private var editButton: some View {
        Button {
            isEditing = true
        } label: {
            Image(systemName: "square.and.pencil")
                .foregroundColor(.gray)
                .font(.system(size: 18))
        }
    }
    
    private var activityStatus: some View {
        Section {
            listCell(title: "모집 상태", content: activity.status == .closed ? "모집완료" : "모집중")
            
            if let userID = userID {
                let totalParticipants = activity.authentication.count
                let completedAuthentications = activity.authentication.values.filter { $0 == true }.count
                
                // MARK: 인증 여부 확인 (참가자 / 주최자)
                if activity.participantID.contains(userID) {
                    listCell(title: "인증 여부", content: activity.authentication[userID] == true ? "완료" : "미완료")
                } else if userID == activity.hostID {
                    HStack {
                        Text("인증 완료")
                        Spacer()
                        Text("\(completedAuthentications)명 / \(totalParticipants)명 완료")
                            .foregroundColor(completedAuthentications == totalParticipants ? .accentColor : .black)
                    }
                }
            } else {
                listCell(title: "인증 여부", content: "사용자 미확인")
            }
        } header: { Text("상태") }
    }
    
    private var userInfo: some View {
        Section {
            if selectedItem == .participant {
                if let host = hostProfile {
                    HStack {
                        Text("호스트")
                        Spacer()
                        Text(host.nickname)
                        iMessageButton(email: host.email)
                    }
                } else {
                    Text("호스트 정보 없음")
                        .foregroundColor(.gray)
                }
            } else {
                if !participantProfiles.isEmpty {
                    ForEach(participantProfiles, id: \.id) { participant in
                        HStack {
                            Text(participant.nickname)
                            Spacer()
                            iMessageButton(email: participant.email)
                        }
                    }
                } else {
                    Text("참가자가 아직 없습니다.")
                        .foregroundColor(.gray)
                }
            }
        } header: {
            Text(selectedItem == .participant ? "주최자 정보" : "참가자 정보")
        }
    }
    
    private var participantsInfo: some View {
        VStack {
            if isLoadingParticipants {
                Text("참가자 정보를 불러오는 중...")
            } else if participantProfiles.isEmpty {
                Text("참가자가 아직 없습니다.")
            } else {
                ForEach(participantProfiles, id: \.id) { participant in
                    Text(participant.nickname)
                        .foregroundColor(.black)
                }
            }
        }
        .foregroundColor(.gray)
    }
    
    private var mapView: some View {
        Map(
            coordinateRegion: $cameraPosition,
            annotationItems: [activity]
        ) { activity in
            MapMarker(
                coordinate: CLLocationCoordinate2D(
                    latitude: activity.coordinates.latitude,
                    longitude: activity.coordinates.longitude
                ),
                tint: .accent
            )
        }
    }
    
    // MARK: - Subview Functions
    private func actionButton() -> some View {
        let (buttonText, alertTitle, alertMessage, primaryAction) = getButtonContent()
        
        return Button {
            showAlert = true
        } label: {
            Text(buttonText)
                .font(.callout)
                .fontWeight(.bold)
                .foregroundColor(.red)
        }
        .frame(maxWidth: .infinity, alignment: .center)
        .alert(isPresented: $showAlert) {
            Alert(
                title: Text(alertTitle),
                message: Text(alertMessage),
                primaryButton: .destructive(Text(buttonText)) {
                    primaryAction()
                },
                secondaryButton: .cancel(Text("닫기"))
            )
        }
    }
    
    private func getButtonContent() -> (String, String, String, () -> Void) {
        if selectedItem == .participant {
            return (
                "모임 참가 취소",
                "참가 취소",
                "정말 취소하시겠습니까?",
                {viewModel.deleteParticipant()}
            )
        } else {
            return (
                "모임 삭제",
                "모임 삭제",
                "모임을 삭제하면 전체 참가자에게도 삭제됩니다. 정말 삭제하시겠습니까?",
                {viewModel.deleteActivity()}
            )
        }
    }
    
    private func iMessageButton(email: String) -> some View {
        Button {
            if MFMessageComposeViewController.canSendText() {
                imessageReceiverEmail = email
                showMessageView = true
            } else { print("iMessage를 사용할 수 없습니다.") }
        } label: {
            Image(systemName: "ellipsis.message")
                .foregroundColor(.blue)
        }
    }
    
    private func listCell(title: String, content: String) -> some View {
        HStack {
            Text(title)
            Spacer()
            Text(content)
        }
    }
    
    
    // MARK: - Functions
    private func updateMapRegion() {
        let coordinate = CLLocationCoordinate2D(
            latitude: activity.coordinates.latitude,
            longitude: activity.coordinates.longitude
        )
        
        cameraPosition = MKCoordinateRegion(
            center: coordinate,
            span: MKCoordinateSpan(latitudeDelta: 0.005, longitudeDelta: 0.005)
        )
    }
    
    private func nicknameOrPlaceholder(_ nickname: String) -> String {
        return nickname.isEmpty ? "닉네임이 없습니다." : nickname
    }

    private func fetchHostProfile() {
        if activity.hostID != userProfile.id {
            isLoadingHostProfile = true
            userDataManager.observeSingleData(eventType: .value, id: activity.hostID) { result in
                switch result {
                case .success(let profile):
                    self.hostProfile = profile
                case .failure(let error):
                    print("호스트 프로필 가져오기 실패: \(error)")
                }
                self.isLoadingHostProfile = false
            }
        }
    }
    
    private func fetchParticipantProfiles() {
        isLoadingParticipants = true
        
        let group = DispatchGroup()
        var fetchedProfiles: [User] = []
        
        for id in activity.participantID {
            group.enter()
            userDataManager.observeSingleData(
                eventType: .value,
                id: id
            ) { result in
                switch result {
                case .success(let profile):
                    fetchedProfiles.append(profile)
                case .failure(let error):
                    print("참가자 프로필 가져오기 실패: \(error)")
                }
                group.leave()
            }
        }
        
        group.notify(queue: .main) {
            self.participantProfiles = fetchedProfiles
            self.isLoadingParticipants = false
        }
    }
    
    private func formatDate() -> String? {
        let activityDate = activity.startDateTime.toString()
        let formatter = DateFormatter()
        
        guard let date = formatter.date(from: activityDate) else { return nil }
        
        formatter.locale = Locale(identifier: "ko_KR")
        formatter.dateFormat = "MM/dd HH시 mm분"
        
        return formatter.string(from: date)
    }
}

#Preview {
    TicketDetailView(
        viewModel: .init(
            activityID: "1D2BF6E6-E2A3-486B-BDCF-F3A450C4A029",
            hostID: "1D2BF6E6-E2A3-486B-BDCF-F3A450C4A029"
        ),
        isLocationVisible: .constant(false),
        selectedItem: .constant(.participant),
        showMessageView: .constant(false),
        activity: Activity.sampleData,
        userProfile: User(
            nickname: "",
            affiliation: .postech,
            email: ""
        )
    )
}
