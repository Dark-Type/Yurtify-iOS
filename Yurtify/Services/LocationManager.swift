//
//  LocationManager.swift
//  Yurtify
//
//  Created by dark type on 23.06.2025.
//

import CoreLocation
import Foundation
import SwiftUI

// MARK: - Separate Delegate Implementation

final class LocationManagerDelegate: NSObject, CLLocationManagerDelegate {
    var didChangeAuthorization: ((CLAuthorizationStatus) -> Void)?
    var didUpdateLocations: (([CLLocation]) -> Void)?
    var didFailWithError: ((Error) -> Void)?
    
    func locationManagerDidChangeAuthorization(_ manager: CLLocationManager) {
        let status = manager.authorizationStatus
        didChangeAuthorization?(status)
    }
    
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        didUpdateLocations?(locations)
    }
    
    func locationManager(_ manager: CLLocationManager, didFailWithError error: Error) {
        didFailWithError?(error)
    }
}

// MARK: - Main Actor Manager

@MainActor
final class LocationManager: ObservableObject {
    private let locationManager = CLLocationManager()
    private let delegate = LocationManagerDelegate()
    
    @Published var currentLocation: CLLocation?
    @Published var authStatus: CLAuthorizationStatus = .notDetermined
    
    private var permissionContinuation: CheckedContinuation<CLAuthorizationStatus, Never>?
    
    init() {
        locationManager.delegate = delegate
        locationManager.desiredAccuracy = kCLLocationAccuracyBest
        authStatus = locationManager.authorizationStatus
        
        delegate.didChangeAuthorization = { [weak self] status in
            Task { @MainActor [weak self] in
                guard let self = self else { return }
                self.authStatus = status
                
                if let continuation = self.permissionContinuation {
                    continuation.resume(returning: status)
                    self.permissionContinuation = nil
                }
                
                if status == .authorizedWhenInUse || status == .authorizedAlways {
                    self.locationManager.startUpdatingLocation()
                }
            }
        }
        
        delegate.didUpdateLocations = { [weak self] locations in
            Task { @MainActor [weak self] in
                if let location = locations.last {
                    self?.currentLocation = location
                }
            }
        }
        
        delegate.didFailWithError = { error in
            print("Location manager error: \(error.localizedDescription)")
        }
    }
    
    func requestLocationPermission() async -> CLAuthorizationStatus {
        let status = locationManager.authorizationStatus
        
        if status != .notDetermined {
            if status == .authorizedWhenInUse || status == .authorizedAlways {
                locationManager.startUpdatingLocation()
            }
            return status
        }
        
        return await withCheckedContinuation { continuation in
            self.permissionContinuation = continuation
            locationManager.requestWhenInUseAuthorization()
        }
    }
}
