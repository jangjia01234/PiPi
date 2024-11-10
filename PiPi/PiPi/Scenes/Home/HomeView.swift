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
    
    private let minPresentationDetents = PresentationDetent.height(150)
    private let maxPresentationDetents = PresentationDetent.height(600)
    private let locationManager = LocationManager()
    private let activityDataManager = FirebaseDataManager<Activity>()
    
    var body: some View {
        ZStack {
            Map(
                position: $cameraPosition,
                bounds: .init(
                    centerCoordinateBounds: .cameraBoundary,
                    minimumDistance: 500,
                    maximumDistance: 3000000
                ),
                interactionModes: [.zoom, .pan, .rotate],
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
                        MapUserLocationButton(scope: mapScope)
                            .background(.white)
                            .tint(.accent)
                            .clipShape(Circle())
                            .setShadow()
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
            activityDataManager.observeAllData(eventType: .value) { result in
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
            let currentDate = Date()
            activitiesToShow = activities.filter {
                $0.status == .open &&
                $0.startDateTime >= currentDate
            }
        }
        .onChange(of: selectedCategory) {
            selectedMarkerActivity = nil
            let currentDate = Date()
            activitiesToShow = activities.filter { activity in
                activity.status == .open &&
                activity.startDateTime >= currentDate &&
                (selectedCategory == nil || activity.category == selectedCategory)
            }
            
        }
    }
}

#Preview {
    HomeView()
}
