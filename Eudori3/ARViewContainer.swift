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
        
        if ARWorldTrackingConfiguration.supportsFrameSemantics(.personSegmentationWithDepth) {
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
        if let model = self.modelConfirmedForPlacement {
        if let modelEntity = model.modelEntity,
                   let focusEntity = context.coordinator.focusEntity {

                    print("DEBUG: Adding model to scene - \(model.modelName)")
            
                    let clonedEntity = modelEntity.clone(recursive: true)
            
                    clonedEntity.generateCollisionShapes(recursive: true)
                    uiView.installGestures([.translation, .rotation, .scale], for: clonedEntity)

                    // Get transform from FocusEntity
                    let anchorEntity = AnchorEntity(world: focusEntity.position)

                    anchorEntity.addChild(clonedEntity)
                    uiView.scene.addAnchor(anchorEntity)
                }
                
                
                DispatchQueue.main.async {
                    self.modelConfirmedForPlacement = nil
                }
            }
    }
}
