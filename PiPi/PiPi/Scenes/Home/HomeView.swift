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
    @State private var cameraPosition: MapCameraPosition = .defaultPosition
    @State private var activityCreateViewIsPresented = false
    @State private var selectedMarkerActivity: Activity?
    @State private var showActivityDetail = false
    @State private var selectedCategory: Activity.Category? = nil
    @State private var activities: [Activity] = []
    @State private var activitiesToShow: [Activity] = []
    
    private typealias DatabaseResult = Result<[String: Activity], Error>
    
    private let minPresentationDetents = PresentationDetent.height(150)
    private let maxPresentationDetents = PresentationDetent.height(600)
    
    var body: some View {
        ZStack {
            Map(
                position: $cameraPosition,
                interactionModes: [.zoom, .pan],
                selection: $selectedMarkerActivity,
                scope: mapScope
            ) {
                ForEach(activitiesToShow, id: \.self) { activity in
                    Marker(coordinate: CLLocationCoordinate2D(activity.coordinates)) {
                        Image("\(activity.category.self).white")
                        Text(activity.title)
                            .font(.callout)
                            .fontWeight(.regular)
                    }
                    .tint(.accent)
                }
            }
            .mapControlVisibility(.hidden)
            .zIndex(1)
            
            ZStack {
                VStack {
                    CategoryFilterView(selectedCategory: $selectedCategory)
                    Spacer()
                }
                HStack {
                    Spacer()
                    VStack {
                        Spacer()
                        ActivityCreateButton(isPresented: $activityCreateViewIsPresented)
                    }
                }
            }
            .padding([.horizontal, .bottom], 10)
            .zIndex(2)
        }
        .mapScope(mapScope)
        .fullScreenCover(isPresented: $activityCreateViewIsPresented) {
            ActivityCreateView()
        }
        .sheet(isPresented: $showActivityDetail) {
            if let selectedActivity = selectedMarkerActivity {
                ActivityDetailView(
                    activityID: selectedActivity.id,
                    hostID: selectedActivity.hostID
                )
                .background(Color(.white))
                .presentationDetents([minPresentationDetents, maxPresentationDetents])
                .presentationDragIndicator(.visible)
                .presentationBackgroundInteraction(.enabled(upThrough: minPresentationDetents))
                .onDisappear {
                    selectedMarkerActivity = nil
                }
            }
        }
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
        .onChange(of: selectedMarkerActivity) {
            showActivityDetail = (selectedMarkerActivity != nil)
        }
        .onChange(of: activities) {
            activitiesToShow = activities.filter { $0.status == .open }
        }
        .onChange(of: selectedCategory) {
            guard let selectedCategory else {
                activitiesToShow = activities.filter { $0.status == .open }
                return
            }
            activitiesToShow = activities.filter { ($0.category == selectedCategory) && ($0.status == .open) }
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
