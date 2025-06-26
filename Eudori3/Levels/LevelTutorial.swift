//
//  LevelTutorial.swift
//  Eudori3
//
//  Created by Vigo on 24/06/25.
//

import Foundation
import RealityKit

class LevelTutorial: Level {
    var id: Int = 1
    
    var model: Model
    
    private var anchor: AnchorEntity?
    
    init() {
        self.model = Model()
    }
    
    func setupLevel(in arView: ARView, with anchorTransform: Transform, arViewModel: ARViewModel) {
        guard let circuit = try? Entity.load(named: "tutorial_circuit") else {
            print("Error loading model")
            return
        }
        
        self.model.circuitEntity = circuit
        circuit.generateCollisionShapes(recursive: true)
        circuit.scale /= 30
        
        let anchor = AnchorEntity()
        anchor.transform = anchorTransform
        anchor.addChild(circuit)
        arView.scene.addAnchor(anchor)
        self.anchor = anchor
        
        DispatchQueue.main.async {
            arViewModel.focusEntityState = false
        }
    }
    
    func update(deltaTime: Double, arViewModel: ARViewModel, toolsViewModel: ToolsViewModel) {
        guard let currentCapacitor = getCapacitor() else { return }
        if toolsViewModel.isThermalGlassActive {
//            currentCapacitor.position.z += 0.001
            let lamp = ModelEntity()
            let lampMesh = MeshResource.generateSphere(radius: 0.01)
            let lampMaterial = SimpleMaterial(color: .gray, isMetallic: true)
            lamp.components.set(ModelComponent(mesh: lampMesh, materials: [lampMaterial]))
            lamp.position = [0.0, 0.0, 0.0]
            anchor?.addChild(lamp)
        }
    }
    
    func cleanupLevel(in arView: ARView, arViewModel: ARViewModel) {
        
    }
    
    func getCapacitor() -> Entity? {
        guard let capacitorEntity = self.model.circuitEntity?.findEntity(named: "capacitor") else {
            print("capacitor not found")
            return nil
        }
        
        return capacitorEntity
    }
}
