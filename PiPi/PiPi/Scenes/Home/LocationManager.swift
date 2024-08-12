//
//  LocationManager.swift
//  PiPi
//
//  Created by 정상윤 on 8/13/24.
//

import MapKit

final class LocationManager: NSObject, CLLocationManagerDelegate {
    
    private let manager = CLLocationManager()
    
    override init() {
        super.init()
        
        manager.delegate = self
    }
    
    func locationManagerDidChangeAuthorization(_ manager: CLLocationManager) {
        switch manager.authorizationStatus {
        case .denied, .notDetermined, .restricted:
            manager.requestWhenInUseAuthorization()
        default:
            break
        }
    }
    
}
