//
//  MultimeterViewModel.swift
//  Eudori3
//
//  Created by Tubagus Ariq Naufal on 24/06/25.
//

import Foundation
import RealityKit

class MultimeterViewModel: ObservableObject {
    @Published var isMultimeterActive = false
    @Published var focusedEntityName: String = ""
    @Published var isFocusing: Bool = false
    @Published var focusProgress: Double = 0.0
    
    let focusController: MultimeterManager
    
    init(arView: ARView) {
        self.focusController = MultimeterManager(arView: arView)
        
        focusController.onFocusDetected = { [weak self] entity in
            DispatchQueue.main.async {
                self?.focusedEntityName = entity.name
                self?.isFocusing = true
            }
        }
        
        focusController.onFocusProgressUpdate = { [weak self] progress in
            DispatchQueue.main.async {
                self?.focusProgress = progress
                self?.isFocusing = progress > 0.0
            }
        }
    }
    
    func toggleMultimeter() {
        isMultimeterActive.toggle()
        if isMultimeterActive {
            focusController.activate()
        } else {
            focusController.deactivate()
            focusedEntityName = ""
            focusProgress = 0.0
            isFocusing = false
        }
    }}
