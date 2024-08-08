//
//  Constants.swift
//  PiPi
//
//  Created by 정상윤 on 8/7/24.
//

import SwiftUI
import MapKit

extension CLLocationCoordinate2D {
    
    static let postech = CLLocationCoordinate2D(
        latitude: 36.015501,
        longitude: 129.322548
    )
    
}

extension MKCoordinateRegion {
    
    static let cameraBoundary = MKCoordinateRegion(
        center: .postech,
        latitudinalMeters: 4000,
        longitudinalMeters: 4000
    )
    
}

extension MapCameraPosition {
    
    static let defaultPosition: Self = .camera(.init(centerCoordinate: .postech, distance: 1500))
    
}
