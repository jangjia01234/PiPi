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
    
    func getLocationCoordinate() -> CLLocationCoordinate2D? {
        manager.requestLocation()
        return manager.location?.coordinate
    }
    
    func locationManagerDidChangeAuthorization(_ manager: CLLocationManager) {
        switch manager.authorizationStatus {
        case .denied, .notDetermined, .restricted:
            manager.requestWhenInUseAuthorization()
        default:
            break
        }
    }
    
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {}
    
    func locationManager(_ manager: CLLocationManager, didFailWithError error: any Error) {
        dump(error)
    }
    
}
