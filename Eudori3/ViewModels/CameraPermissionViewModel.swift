//
//  CameraPermissionViewModel.swift
//  LloydElectrofixJourney
//
//  Created by Djie Valencia Santoso on 24/06/25.
//

import Foundation
import AVFoundation
import SwiftUI

class CameraPermissionViewModel: ObservableObject {
    @Published var isCameraAuthorized: Bool = false
    @Published var shouldShowAlert: Bool = false

    func checkPermission() {
        switch AVCaptureDevice.authorizationStatus(for: .video) {
        case .authorized:
            isCameraAuthorized = true
        case .notDetermined:
            AVCaptureDevice.requestAccess(for: .video) { granted in
                DispatchQueue.main.async {
                    self.isCameraAuthorized = granted
                    self.shouldShowAlert = !granted
                }
            }
        case .denied, .restricted:
            isCameraAuthorized = false
            shouldShowAlert = true
        @unknown default:
            isCameraAuthorized = false
            shouldShowAlert = true
        }
    }
}
