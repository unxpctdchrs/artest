//
//  LevelTutorial.swift
//  Eudori3
//
//  Created by Vigo on 24/06/25.
//

import Foundation
import RealityKit
import SwiftUICore
import UIKit

class LevelTutorial: Level {
    var id: Int = 1
    
    var model: Model
    
    private var anchor: AnchorEntity?
    
    private var hasThermalGlassActionBeenPerformed: Bool = false
    
    private var lamp: Entity?
    
    private var toolsViewModel: ToolsViewModel?
    
    init() {
        self.model = Model()
    }
    
    func setupLevel(in arView: ARView, with anchorTransform: Transform, arViewModel: ARViewModel, toolsViewModel: ToolsViewModel) {
        
        self.toolsViewModel = toolsViewModel
        
        guard let circuit = try? Entity.load(named: "tutorial_circuit"), let thermalGlass = try? ModelEntity.loadModel(named: "thermal_camera") else {
            print("Error loading model")
            return
        }
        
        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(handleTap(_:)))
        arView.addGestureRecognizer(tapGesture)
        
        self.model.circuitEntity = circuit
        circuit.generateCollisionShapes(recursive: true)
        circuit.scale /= 30
        
        self.model.thermalGlassEntity = thermalGlass
        thermalGlass.generateCollisionShapes(recursive: true)
        thermalGlass.scale /= 2
        thermalGlass.position.x = -0.2
        let rotation = simd_quatf(angle: .pi / 2.4, axis: [0, 1, 0])
        thermalGlass.transform.rotation = rotation
        
        let anchor = AnchorEntity()
        anchor.transform = anchorTransform
        
        anchor.addChild(circuit)
        anchor.addChild(thermalGlass)
        
        arView.scene.addAnchor(anchor)
        self.anchor = anchor
        
        DispatchQueue.main.async {
            arViewModel.focusEntityState = false
        }
    }
    
    func update(deltaTime: Double, arViewModel: ARViewModel, toolsViewModel: ToolsViewModel) {
        guard let currentCapacitor = getCapacitor() else { return }
        if toolsViewModel.isThermalGlassActive && !hasThermalGlassActionBeenPerformed {
            
            self.model.thermalGlassEntity?.isEnabled = false
            
            let lampPosition: SIMD3<Float> = [
                currentCapacitor.position.x - 0.0185,
                currentCapacitor.position.y + 0.008,
                currentCapacitor.position.z - 0.008
            ]
            
            let lampEntity = Entity()
            lampEntity.position = lampPosition
            
            var redGlow = PointLightComponent()
            redGlow.color = .red
            redGlow.intensity = 100
            redGlow.attenuationRadius = 0.1
            
            self.lamp = lampEntity
            
            lampEntity.components.set(redGlow)
            
            anchor?.addChild(lampEntity)
            
            hasThermalGlassActionBeenPerformed = true
        } else if !toolsViewModel.isThermalGlassActive && hasThermalGlassActionBeenPerformed {
            self.model.thermalGlassEntity?.isEnabled = true
            self.lamp?.removeFromParent()
            hasThermalGlassActionBeenPerformed = false
        }
    }
    
    //TODO: Fix level cleanup
    func cleanupLevel(in arView: ARView, arViewModel: ARViewModel) {
        if let circuitAnchor = self.anchor {
            circuitAnchor.removeFromParent()
        }
    }
    
    func getCapacitor() -> Entity? {
        guard let capacitorEntity = self.model.circuitEntity?.findEntity(named: "capacitor") else {
            print("capacitor not found")
            return nil
        }
        
        return capacitorEntity
    }
    
    @objc func handleTap(_ sender: UITapGestureRecognizer) {
        guard let arView = sender.view as? ARView else { return }
        
        let location = sender.location(in: arView)
        
        guard let tappedEntity = arView.entity(at: location), let thermalGlass = model.thermalGlassEntity else { return }
        
        if isDescendant(of: thermalGlass, tappedEntity: tappedEntity) {
            print("✅ thermal camera tapped")
            toolsViewModel?.isThermalGlassActive.toggle()
        }
    }
    
    func isDescendant(of parent: Entity?, tappedEntity: Entity) -> Bool {
        var current: Entity? = tappedEntity
        while let c = current {
            if c == parent {
                return true
            }
            current = c.parent
        }
        return false
    }
}
