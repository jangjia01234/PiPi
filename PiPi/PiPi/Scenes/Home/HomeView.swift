//
//  HomeView.swift
//  PiPi
//
//  Created by 정상윤 on 7/30/24.
//

import SwiftUI
import MapKit

struct HomeView: View {
    
    @Namespace private var mapScope
    @State private var activities: [Activity] = []
    @State private var activityCreateViewIsPresented = false
    @State private var selectedMarkerID: String?
    
    private typealias DatabaseResult = Result<[String: Activity], Error>
    
    var body: some View {
        NavigationStack {
            ZStack {
                Map(selection: $selectedMarkerID, scope: mapScope) {
                    ForEach(activities, id: \.id) { activity in
                        Marker(coordinate: activity.coordinates.toCLLocationCoordinate2D) {
                            Image("\(activity.category.self).white")
                            Text(activity.title)
                        }
                        .tint(.accent)
                    }
                }
                .mapControlVisibility(.hidden)
                .zIndex(1)
                
                ZStack {
                    VStack {
                        CategoryFilterView()
                        TicketProfileButtonView()
                        Spacer()
                    }
                    HStack {
                        Spacer()
                        VStack(spacing: 10) {
                            Spacer()
                            VStack(spacing: 5) {
                                MapUserLocationButton(scope: mapScope)
                                    .setSmallButtonAppearance()
                            }
                            ActivityCreateButton(isPresented: $activityCreateViewIsPresented)
                        }
                    }
                }
                .padding(.horizontal)
                .zIndex(2)
            }
            .mapScope(mapScope)
            .fullScreenCover(isPresented: $activityCreateViewIsPresented) {
                ActivityCreateView()
            }
        }
        .navigationBarBackButtonHidden(true)
        .onAppear {
            FirebaseDataManager.shared.observeData(eventType: .value, dataType: .activity) { (result: DatabaseResult) in
                switch result {
                case .success(let result):
                    activities = Array(result.values)
                case .failure(let error):
                    dump(error)
                }
            }
        }
        .onChange(of: selectedMarkerID) {
            //TODO: 활동 디테일 모달 표시
        }
    }
    
}

fileprivate extension View {
    
    func setSmallButtonAppearance() -> some View {
        self
            .frame(width: 38, height: 38)
            .tint(.accent)
            .background(.white)
            .clipShape(Circle())
            .setShadow()
    }
    
}

#Preview {
    HomeView()
}
