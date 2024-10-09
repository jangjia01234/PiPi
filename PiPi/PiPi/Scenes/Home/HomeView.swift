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
            .onMapCameraChange { context in
                let currentCoordinate = context.camera.centerCoordinate
                let currentDistance = context.camera.distance

                // MARK: 대한민국의 경계 좌표 (남서쪽과 북동쪽)
                let southWest = CLLocationCoordinate2D(latitude: 33.0, longitude: 126.0) // 남서쪽 경계
                let northEast = CLLocationCoordinate2D(latitude: 38.5, longitude: 130.0) // 북동쪽 경계
                
                let maxZoomOutDistance: CLLocationDistance = 1600000

                var clampedCoordinate = currentCoordinate
                
                clampedCoordinate.latitude = min(max(currentCoordinate.latitude, southWest.latitude), northEast.latitude)
                clampedCoordinate.longitude = min(max(currentCoordinate.longitude, southWest.longitude), northEast.longitude)

                if currentDistance > maxZoomOutDistance {
                    let desiredLatitude: CLLocationDegrees = 35.946239360942876
                    let desiredLongitude: CLLocationDegrees = 127.73839221769023
                    
                    cameraPosition = .camera(.init(centerCoordinate: CLLocationCoordinate2D(latitude: desiredLatitude, longitude: desiredLongitude), distance: maxZoomOutDistance))
                } else {
                    cameraPosition = .camera(.init(centerCoordinate: clampedCoordinate, distance: currentDistance))
                }
            }
            
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
            activitiesToShow = activities.filter { $0.status == .open }
        }
        .onChange(of: selectedCategory) {
            selectedMarkerActivity = nil
            
            if let selectedCategory {
                activitiesToShow = activities.filter { ($0.category == selectedCategory) && ($0.status == .open) }
            } else {
                activitiesToShow = activities.filter { $0.status == .open }
            }
        }
    }
    
}

#Preview {
    HomeView()
}
