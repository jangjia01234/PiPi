//
//  CLLocationCoordinate2D+.swift
//  PiPi
//
//  Created by 정상윤 on 8/1/24.
//

import MapKit

extension CLLocationCoordinate2D {
    
    init(_ coordinates: Coordinates) {
        self.init(
            latitude: coordinates.latitude,
            longitude: coordinates.longitude
        )
    }
    
}
