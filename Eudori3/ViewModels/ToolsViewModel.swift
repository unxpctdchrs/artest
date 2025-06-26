//
//  ToolsViewModel.swift
//  Eudori3
//
//  Created by Vigo on 14/06/25.
//

import SwiftUI
import RealityKit

class ToolsViewModel: ObservableObject {

    @Published var isMagnifyingGlassActive: Bool = false
    @Published var isThermalGlassActive: Bool = false
    
    @Published var focusProgress: Double = 0.0
    @Published var focusedEntityName: String = ""
    @Published var isFocusing: Bool = false
    
    private var multimeterManager: MultimeterManager?
    @Published var isMultimeterActive: Bool = false {
            didSet {
                if isMultimeterActive {
                    multimeterManager?.activate()
                } else {
                    multimeterManager?.deactivate()
                    focusProgress = 0
                    isFocusing = false
                    focusedEntityName = ""
                }
            }
        }
    
    func setARView(_ arView: ARView) {
        print("Multimeter status on setARView toolsVM: \(isMultimeterActive)")
        multimeterManager = MultimeterManager(arView: arView)
        multimeterManager?.onFocusDetected = { [weak self] entity in
            DispatchQueue.main.async {
                if let cap = entity.components[CapacitanceComponent.self] as? CapacitanceComponent {
                    self?.focusedEntityName = "\(entity.name): \(cap.value)"
                } else {
                    self?.focusedEntityName = entity.name
                }
                self?.isFocusing = true
            }
        }
        
        multimeterManager?.onFocusProgressUpdate = { [weak self] progress in
            DispatchQueue.main.async {
                self?.focusProgress = progress
                self?.isFocusing = progress > 0
            }
        }
        
        multimeterManager?.onNoEntityFocused = { [weak self] in
            DispatchQueue.main.async {
                self?.focusProgress = 0
                self?.isFocusing = false
                self?.focusedEntityName = ""
            }
        }
        
        if isMultimeterActive {
            print("Multimeter activated on setARView toolsVM: \(isMultimeterActive)")
            multimeterManager?.activate()
        }
    }
    
    func toggleMultimeter() {
        isMultimeterActive.toggle()
        if isMultimeterActive {
            multimeterManager?.activate()
        } else {
            multimeterManager?.deactivate()
            focusProgress = 0
            isFocusing = false
            focusedEntityName = ""
        }
    }
}
