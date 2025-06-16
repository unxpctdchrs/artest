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

struct ARViewContainer: UIViewRepresentable {
    @Binding var modelConfirmedForPlacement: Model?
    
    // Setup focus entity
    class Coordinator {
        var focusEntity: FocusEntity?
    }

    func makeCoordinator() -> Coordinator {
        return Coordinator()
    }
    
    func makeUIView(context: Context) -> ARView {
        let arView = ARView(frame: .zero)
        
        // Track the horizont for placing object
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
        
        // Add FocusEntity
        context.coordinator.focusEntity = FocusEntity(on: arView, style: .classic(color: .red))

        return arView
    }
    
    func updateUIView(_ uiView: ARView, context: Context) {
        
        guard let model = self.modelConfirmedForPlacement,
              let modelEntity = model.modelEntity,
              let focusEntity = context.coordinator.focusEntity else {
            // If any of these are nil, we can't proceed.
            return
        }

        print("DEBUG: Adding model to scene - \(model.modelName)")

        let clonedEntity = modelEntity.clone(recursive: true)
        clonedEntity.generateCollisionShapes(recursive: true)
        uiView.installGestures([.translation, .rotation, .scale], for: clonedEntity)

        let anchorEntity = AnchorEntity()
        anchorEntity.transform = focusEntity.transform
        
        anchorEntity.addChild(clonedEntity)
        uiView.scene.addAnchor(anchorEntity)

        DispatchQueue.main.async {
            self.modelConfirmedForPlacement = nil
        }
        
        // Example: Attach the capacitor after 3 seconds
        DispatchQueue.main.asyncAfter(deadline: .now() + 3.0) {
            if let socketEntity = modelEntity.findEntity(named: "capacitor_socket_1") {
                
                print("Socket 'capacitor_socket_1' found!")

                // 3. Attach the capacitor as a child of the socket
                // This automatically gives it the correct position and orientation.
                if let capacitor = modelEntity.findEntity(named: "capacitor") {
                    socketEntity.addChild(capacitor)
                }

            } else {
                print("ERROR: Could not find entity named 'capacitor_socket_1' in the model.")
            }
        }
        
        switch context.coordinator.focusEntity?.state {
        case .tracking:
            
            print("currently tracking a surface")

        default:
            print("Cannot place object: FocusEntity is not tracking a surface.")
        }
    }
}
