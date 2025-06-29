//
//  PermissionManager.swift
//  Yurtify
//
//  Created by dark type on 29.06.2025.
//


import Foundation
import PhotosUI
import AVFoundation
import UIKit

@MainActor
class PermissionManager: ObservableObject {
    
    enum PermissionStatus {
        case notDetermined
        case denied
        case authorized
        case limited
    }
    
    enum PermissionType {
        case camera
        case photoLibrary
    }
    
    @Published var isShowingPermissionAlert = false
    @Published var permissionAlertMessage = ""
    
    // MARK: - Photo Library Permission (Simplified)
    
    func checkPhotoLibraryPermission() -> PermissionStatus {
        let status = PHPhotoLibrary.authorizationStatus(for: .readWrite)
        
        switch status {
        case .authorized:
            return .authorized
        case .limited:
            return .limited
        case .denied, .restricted:
            return .denied
        case .notDetermined:
            return .notDetermined
        @unknown default:
            return .denied
        }
    }
    
    func requestPhotoLibraryPermission(completion: @escaping (PermissionStatus) -> Void) {
        let currentStatus = checkPhotoLibraryPermission()
        
        switch currentStatus {
        case .authorized, .limited:
            completion(.authorized)
            return
        case .denied:
            showPermissionDeniedAlert(for: .photoLibrary)
            completion(.denied)
            return
        case .notDetermined:
            PHPhotoLibrary.requestAuthorization(for: .readWrite) { [weak self] newStatus in
                DispatchQueue.main.async {
                    switch newStatus {
                    case .authorized, .limited:
                        completion(.authorized)
                    case .denied, .restricted:
                        self?.showPermissionDeniedAlert(for: .photoLibrary)
                        completion(.denied)
                    case .notDetermined:
                        completion(.notDetermined)
                    @unknown default:
                        completion(.denied)
                    }
                }
            }
        }
    }
    
    // MARK: - Camera Permission (Simplified)
    
    func checkCameraPermission() -> PermissionStatus {
        guard UIImagePickerController.isSourceTypeAvailable(.camera) else {
            return .denied
        }
        
        let status = AVCaptureDevice.authorizationStatus(for: .video)
        
        switch status {
        case .authorized:
            return .authorized
        case .denied, .restricted:
            return .denied
        case .notDetermined:
            return .notDetermined
        @unknown default:
            return .denied
        }
    }
    
    func requestCameraPermission(completion: @escaping (PermissionStatus) -> Void) {
        guard UIImagePickerController.isSourceTypeAvailable(.camera) else {
            showCameraUnavailableAlert()
            completion(.denied)
            return
        }
        
        let currentStatus = checkCameraPermission()
        
        switch currentStatus {
        case .authorized:
            completion(.authorized)
            return
        case .denied:
            showPermissionDeniedAlert(for: .camera)
            completion(.denied)
            return
        case .notDetermined:
            AVCaptureDevice.requestAccess(for: .video) { [weak self] granted in
                DispatchQueue.main.async {
                    if granted {
                        completion(.authorized)
                    } else {
                        self?.showPermissionDeniedAlert(for: .camera)
                        completion(.denied)
                    }
                }
            }
        case .limited:
            completion(.denied)
        }
    }
    
    // MARK: - Alert Helpers (Public)
    
    func showPermissionDeniedAlert(for type: PermissionType) {
        switch type {
        case .camera:
            permissionAlertMessage = "Camera access is required to take property photos. Please enable it in Settings > Privacy & Security > Camera."
        case .photoLibrary:
            permissionAlertMessage = "Photo library access is required to select property images. Please enable it in Settings > Privacy & Security > Photos."
        }
        isShowingPermissionAlert = true
    }
    
    private func showCameraUnavailableAlert() {
        permissionAlertMessage = "Camera is not available on this device."
        isShowingPermissionAlert = true
    }
    
    func openSettings() {
        if let settingsUrl = URL(string: UIApplication.openSettingsURLString) {
            UIApplication.shared.open(settingsUrl)
        }
    }
}
