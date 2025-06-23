//
//  Level1.swift
//  Eudori3
//
//  Created by Vigo on 21/06/25.
//

import Foundation
import RealityKit

class Level1: Level {
    let id: Int = 1
    
    var model: Model
    var lamp: [ModelEntity] = []
    
    private var level1IsActive: Bool = false
    private var isCapacitorAttached: Bool = false
    private var attachmentTimer: Double = 0.0
    private let attachmentDelay: Double = 3.0
    
    init() {
        self.model = Model()
    }
    
    func setupLevel(in arView: ARView, with anchorTransform: Transform, arViewModel: ARViewModel) {
        guard let circuit = try? Entity.load(named: "testboard_6"), let capacitor = try? ModelEntity.loadModel(named: "capacitor_1.usdz") else {
            print("Failed to load models in level1.")
            return
        }
        
        self.model.circuitEntity = circuit
        self.model.capacitorEntity = capacitor
        
        circuit.generateCollisionShapes(recursive: true)
        capacitor.generateCollisionShapes(recursive: true)
        arView.installGestures([.translation, .rotation], for: capacitor)

        let anchor = AnchorEntity()
        anchor.transform = anchorTransform
        anchor.addChild(circuit)
        
        capacitor.position.x = 0.1
        
        anchor.addChild(capacitor)
        
        for i in 1...5 {
            if let socketEntity = circuit.findEntity(named: "line_path\(i)") {
                print("Socket 'line_path\(i)' found!")
                let lamp = ModelEntity()
                let lampMesh = MeshResource.generateSphere(radius: 0.01)
                let lampMaterial = SimpleMaterial(color: .gray, isMetallic: true)
                lamp.components.set(ModelComponent(mesh: lampMesh, materials: [lampMaterial]))
                lamp.position = [socketEntity.position.x + 0.5, 0.0, 0.0]
                anchor.addChild(lamp)
                self.lamp.append(lamp)
            }
        }
        
        arView.scene.addAnchor(anchor)
        
        DispatchQueue.main.async {
            arViewModel.focusEntityState = false
            self.level1IsActive = true
            print("Level 1 setup complete. onUpdate logic is now active.")
        }
    }
    
    func update(deltaTime: Double, arViewModel: ARViewModel) {
        guard level1IsActive else { return }
        
        if isCapacitorAttached {
            animateLamp()
        } else {
            attachmentTimer += deltaTime
            if attachmentTimer >= attachmentDelay {
                guard let circuit = self.model.circuitEntity, let capacitor = self.model.capacitorEntity else { return }

                // Call the corrected attach function
                self.attachCapacitor(socket: circuit, capacitor: capacitor)

                // Mark as attached so this code doesn't run again.
                self.isCapacitorAttached = true
            }
        }

        if let capacitor = self.model.capacitorEntity {
            let rotation = simd_quatf(angle: .pi / 180, axis: [0, 1, 0])
            capacitor.transform.rotation *= rotation
        }
    }
    
    func cleanupLevel(in arView: ARView, arViewModel: ARViewModel) {
        print("Cleaning up Level 1...")
        self.model.circuitEntity?.removeFromParent()
        self.model.capacitorEntity?.removeFromParent()
        self.lamp.forEach { $0.removeFromParent() }
        stopLampAnimation()
        level1IsActive = false
        isCapacitorAttached = false
        attachmentTimer = 0.0
        // Clear references within the model struct
        self.model.circuitEntity = nil
        self.model.capacitorEntity = nil
        self.lamp = []
    }
    
    func attachCapacitor(socket: Entity, capacitor: ModelEntity) {
        if let socketEntity = socket.findEntity(named: "capacitor_socket_1") {
            
            print("Socket 'capacitor_socket_1' found!")
            print("capacitor.position: \(capacitor.position)", "socketEntity.position: \(socketEntity.position)")
            capacitor.position.x = socketEntity.position.x + 0.5
            
            print("capacitor pos: \(capacitor.position)")
        } else {
            print("ERROR: Could not find entity named 'capacitor_socket_1' in the model.")
        }
    }
    
    func animateLamp() {
        guard !self.lamp.isEmpty else {
            print("No lamps to animate.")
            return
        }

        let yellowMaterial = SimpleMaterial(color: .yellow, isMetallic: true)
        let grayMaterial = SimpleMaterial(color: .gray, isMetallic: true) // Assuming initial state is gray

        let totalLamps = self.lamp.count
        let lampOnDuration: TimeInterval = 0.3 // How long each lamp stays yellow
        let lampOffDuration: TimeInterval = 0.1 // How long each lamp stays gray AFTER being yellow, before the NEXT lamp turns on
        let cycleRestartDelay: TimeInterval = 0.8 // Delay before the entire animation cycle restarts

        let animationActive = true // Local flag to control the recursion

        // A flag to ensure only one animation sequence is running at a time
        // You might want to make this a property of the owning class if you call animateLamp multiple times
        // For now, it's local to ensure a fresh start

        if isAnimatingFlag { // Assume isAnimatingFlag is a property of 'self'
            print("Animation already active, not starting new one.")
            return
        }
        isAnimatingFlag = true // Set to true when starting

        // Reset all lamps to gray initially
        for lamp in self.lamp {
            lamp.model?.materials = [grayMaterial]
        }

        func animateLampRecursive(index: Int) {
            guard animationActive && isAnimatingFlag else { // Check both flags
                isAnimatingFlag = false // Ensure flag is reset if animation stops prematurely
                return
            }

            // Base case: If we've gone through all lamps
            if index >= totalLamps {
                // All lamps have been cycled through.
                // Reset all lamps to gray (if not already done by individual steps)
                // This is useful if the animation stops here or you want a clear "all off" state
                // before the next full cycle.
                DispatchQueue.main.asyncAfter(deadline: .now() + lampOffDuration) { [weak self] in
                    guard let self = self, animationActive && isAnimatingFlag else { return }
                    for lamp in self.lamp {
                        lamp.model?.materials = [grayMaterial]
                    }
                    // Schedule the restart of the entire cycle
                    DispatchQueue.main.asyncAfter(deadline: .now() + cycleRestartDelay) { [weak self] in
                        guard let self = self, animationActive && isAnimatingFlag else { return }
                        animateLampRecursive(index: 0) // Restart animation from the beginning
                    }
                }
                return
            }

            // Get the current lamp to animate
            let currentLamp = self.lamp[index]

            // 1. Turn the current lamp yellow
            currentLamp.model?.materials = [yellowMaterial]

            // 2. Schedule turning it back to gray after 'lampOnDuration'
            DispatchQueue.main.asyncAfter(deadline: .now() + lampOnDuration) { [weak self] in
                guard let self = self, animationActive && isAnimatingFlag else { return }

                // Turn the current lamp back to gray
                currentLamp.model?.materials = [grayMaterial] // This happens *after* it's been yellow for lampOnDuration

                // 3. Schedule the animation for the next lamp after 'lampOffDuration'
                // This delay is crucial to give the *current* lamp time to be gray
                // before the *next* lamp turns yellow.
                DispatchQueue.main.asyncAfter(deadline: .now() + lampOffDuration) { [weak self] in
                    guard let self = self, animationActive && isAnimatingFlag else { return }
                    animateLampRecursive(index: index + 1) // Call for the next lamp
                }
            }
        }
            // Start the animation from the first lamp (index 0)
            animateLampRecursive(index: 0)
    }

    // Add this to the class that contains animateLamp()
    // It helps prevent starting multiple animation loops concurrently
    private var isAnimatingFlag: Bool = false

    // You might also want a way to stop it:
    func stopLampAnimation() {
        isAnimatingFlag = false // This will cause subsequent recursive calls to guard out
        // Optionally reset all lamps to gray immediately upon stopping
        let grayMaterial = SimpleMaterial(color: .gray, isMetallic: true)
        for lamp in self.lamp {
            lamp.model?.materials = [grayMaterial]
        }
    }
    
}
