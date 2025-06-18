//
//  ARViewContainer.swift
//  Eudori3
//
//  Created by Vigo on 11/06/25.
//

import RealityKit
import ARKit
import SwiftUI
import FocusEntity
import Combine

struct ARViewContainer: UIViewRepresentable {
    @Binding var modelConfirmedForPlacement: Model?
    @Binding var isPlacingObject: Bool
    @Binding var currentLevel: Int
    
    class Coordinator {
        var focusEntity: FocusEntity?
        var updateSubscription: Cancellable?
        
        var circuitEntity: Entity?
        var capacitorEntity: ModelEntity?
        
        var level1IsActive: Bool = false
        
        var isCapacitorAttached = false
        var attachmentTimer: Double = 0.0
        let attachmentDelay: Double = 3.0
        
        // --- SCENE UPDATE LOGIC ---
        // This function is called on every frame by the subscription.
        func onUpdate(event: SceneEvents.Update) {
            guard level1IsActive else { return }
            
            if isCapacitorAttached {
                print("Capacitor attached!")
            } else {
                attachmentTimer += event.deltaTime
                if attachmentTimer >= attachmentDelay {
                    
                    guard let circuit = self.circuitEntity, let capacitor = self.capacitorEntity else { return }
                    
                    // Call the corrected attach function
                    self.attachCapacitor(socket: circuit, capacitor: capacitor)
                    
                    // Mark as attached so this code doesn't run again.
                    self.isCapacitorAttached = true
                }
            }
            
//            if let capacitor = self.capacitorEntity {
//                let rotation = simd_quatf(angle: .pi / 180, axis: [0, 1, 0])
//                capacitor.transform.rotation *= rotation
//            }
        }
        
        func attachCapacitor(socket: Entity, capacitor: ModelEntity) {
            if let socketEntity = socket.findEntity(named: "capacitor_socket_1") {
                
                print("Socket 'capacitor_socket_1' found!")

                // Attach the capacitor as a child of the socket
                socketEntity.addChild(capacitor, preservingWorldTransform: true)
                capacitor.move(to: .identity, relativeTo: socketEntity, duration: 0.25, timingFunction: .easeInOut)
            } else {
                print("ERROR: Could not find entity named 'capacitor_socket_1' in the model.")
            }
        }
    }

    func makeCoordinator() -> Coordinator {
        return Coordinator()
    }
    
    func makeUIView(context: Context) -> ARView {
        let arView = ARView(frame: .zero)
        
        let config = ARWorldTrackingConfiguration()
        config.environmentTexturing = .automatic
        config.planeDetection = [.horizontal, .vertical]
            
        if ARWorldTrackingConfiguration.supportsSceneReconstruction(.mesh) {
            print("DEBUG: Device supports Object Occlusion (Scene Reconstruction).")
            config.sceneReconstruction = .mesh
        } else {
            print("DEBUG: Device does not support Object Occlusion.")
        }
        
        if ARWorldTrackingConfiguration.supportsFrameSemantics(.personSegmentation) {
            print("DEBUG: Device supports People Occlusion.")
            config.frameSemantics.insert(.personSegmentationWithDepth)
        } else {
            print("DEBUG: Device does not support People Occlusion.")
        }
        
        arView.session.run(config)
        
        context.coordinator.updateSubscription = arView.scene.subscribe(to: SceneEvents.Update.self) { event in
            context.coordinator.onUpdate(event: event)
        }
        
        // Add FocusEntity
        context.coordinator.focusEntity = FocusEntity(on: arView, style: .classic(color: .red))

        return arView
    }
    
    func updateUIView(_ uiView: ARView, context: Context) {
        
        if self.isPlacingObject {
            print("this isPlacingObject is true, so the rest of code is called")
            
            switch context.coordinator.focusEntity?.state {
            case .tracking:
                
                guard let focusEntity = context.coordinator.focusEntity else {
                    return
                }
                print("currently tracking a surface")
                
                if self.currentLevel == 1 {
                    level1(transform: focusEntity.transform, arView: uiView, coordinator: context.coordinator)
                }
                
                if self.currentLevel == 2 {
                    print("currentLevel is 2")
                }

            default:
                print("Cannot place object: FocusEntity is not tracking a surface.")
            }
        }
        
        DispatchQueue.main.async {
            self.isPlacingObject = false
        }

    }
    
    func level1(transform: Transform, arView: ARView, coordinator: Coordinator) {
        
        guard !coordinator.level1IsActive else { return }
        
        // Load the circuit board and capacitor models
        guard let circuit = try? Entity.load(named: "testboard_3"), let capacitor = try? ModelEntity.loadModel(named: "capacitor_1.usdz") else {
            print("Failed to load models in level1.")
            return
        }
        
        coordinator.circuitEntity = circuit
        coordinator.capacitorEntity = capacitor
        
        circuit.generateCollisionShapes(recursive: true)
        capacitor.generateCollisionShapes(recursive: true)
        arView.installGestures([.translation, .rotation], for: capacitor)

        let anchor = AnchorEntity()
        anchor.transform = transform
        anchor.addChild(circuit)
        
        capacitor.position.x = 0.1
        
        anchor.addChild(capacitor)
        arView.scene.addAnchor(anchor) 
        
        // Now that the entities exist, we can tell onUpdate it's safe to run.
        coordinator.level1IsActive = true
        print("Level 1 setup complete. onUpdate logic is now active.")
    }
}
