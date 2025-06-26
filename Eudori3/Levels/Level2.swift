//
//  Level2.swift
//  Eudori3
//
//  Created by Vigo on 22/06/25.
//

import RealityKit
import Foundation

class Level2: Level {
    var id: Int = 2
    
    var model: Model
    
    private var level2IsActive: Bool = false
    
    init() {
        self.model = Model()
    }
    
    func setupLevel(in arView: ARView, with anchorTransform: Transform, arViewModel: ARViewModel, toolsViewModel: ToolsViewModel) {
        guard let circuit = try? Entity.load(named: "emptyCircuit") else {
            print("Failed to load models in level2.")
            return
        }
        
        self.model.circuitEntity = circuit
        circuit.generateCollisionShapes(recursive: true)
        
        let anchor = AnchorEntity()
        anchor.transform = anchorTransform
        anchor.addChild(circuit)
        
        arView.scene.addAnchor(anchor)
        
        DispatchQueue.main.async {
            self.level2IsActive = true
            print("Level 2 setup complete. onUpdate logic is now active.")
        }
    }
    
    func update(deltaTime: Double, arViewModel: ARViewModel) {
        guard level2IsActive else { return }
        
        print("level 2 update")
    }
    
    func cleanupLevel(in arView: ARView, arViewModel: ARViewModel) {
        print("cleanup")
    }
}
