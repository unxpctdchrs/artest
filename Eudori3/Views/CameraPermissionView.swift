//
//  CameraPermissionView.swift
//  LloydElectrofixJourney
//
//  Created by Djie Valencia Santoso on 24/06/25.
//

import SwiftUI

struct CameraPermissionView<Content: View>: View {
    @StateObject private var viewModel = CameraPermissionViewModel()
    var content: () -> Content

    var body: some View {
        ZStack {
            if viewModel.isCameraAuthorized {
                content()
            }
        }
        .onAppear {
            viewModel.checkPermission()
        }
        .alert("Izin Kamera untuk AR Diperlukan", isPresented: $viewModel.shouldShowAlert) {
            Button("Buka Pengaturan") {
                if let url = URL(string: UIApplication.openSettingsURLString) {
                    UIApplication.shared.open(url)
                }
            }
            Button("Batal", role: .cancel) {}
        } message: {
            Text("Untuk menggunakan fitur Augmented Reality, aplikasi memerlukan akses ke kamera perangkat Anda.")
        }
    }
}
