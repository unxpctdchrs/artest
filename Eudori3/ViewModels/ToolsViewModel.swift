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
    @Published var isThermalGlassActive: Bool = false {
        didSet {
            print("isThermalGlassActive changed to: \(isThermalGlassActive)")
        }
    }
    @Published var firstFocusedEntity: Entity?
    @Published var secondFocusedEntity: Entity?
    @Published var isProbeEntityActive: Bool = false
    
    var gameManager: GameManager
    
    init(gameManager: GameManager) {
        self.gameManager = gameManager
    }
    
    @Published var focusProgress: Double = 0.0
    @Published var focusedEntityName: String = ""
    @Published var isFocusing: Bool = false
    
    @Published var isProbePlusActive = false
    @Published var isProbeMinusActive = false
    
    private var multimeterManager: MultimeterManager?
    @Published var isMultimeterActive: Bool = false {
        didSet {
            if isMultimeterActive {
                isProbeEntityActive.toggle()
                multimeterManager?.activate()
            } else {
                isProbeEntityActive.toggle()
                multimeterManager?.deactivate()
                focusProgress = 0
                isFocusing = false
                focusedEntityName = ""
                isProbePlusActive = false
                isProbeMinusActive = false
            }
        }
    }
    
    func setARView(_ arView: ARView) {
        print("Multimeter status on setARView toolsVM: \(isMultimeterActive)")
        multimeterManager = MultimeterManager(arView: arView)
        multimeterManager?.onFocusDetected = { [weak self] entity in
            DispatchQueue.main.async {
//                if( entity.name.hasPrefix("probe_plus")) {
//                    self?.isProbePlusActive.toggle()
//                }
//                if entity.name.hasPrefix( "probe_minus" ) {
//                    self?.isProbeMinusActive.toggle()
//                }
                if(self?.isProbePlusActive == true && self?.isProbeMinusActive == true) {
                    if let cap = entity.components[CapacitanceComponent.self] as? CapacitanceComponent {
                        self?.focusedEntityName = "\(entity.name): \(cap.value)"
                    } else {
                        self?.focusedEntityName = entity.name
                    }
                }
                self?.isFocusing = true
            }
        }
        multimeterManager?.onFocusProbeType = { [weak self] probeType in
            DispatchQueue.main.async {
                if( probeType == "probe_plus" ) {
                    self?.isProbePlusActive = true
                } else {
                    self?.isProbeMinusActive = true
                }
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
