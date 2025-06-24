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
    
    @ObservedObject var arViewModel = ARViewModel()
    
    class Coordinator {
        var arViewModel: ARViewModel
        var focusEntity: FocusEntity?
        var updateSubscription: Cancellable?
        
        init(arViewModel: ARViewModel) {
            self.arViewModel = arViewModel
        }
        
        // This function is called on every frame by the subscription.
        func onUpdate(event: SceneEvents.Update) {
            arViewModel.gameManager.performUpdate(deltaTime: Double(event.deltaTime), arViewModel: arViewModel)
            
            if arViewModel.focusEntityState == false {
                focusEntity?.isEnabled = false
            }
        }
    }

    func makeCoordinator() -> Coordinator {
        return Coordinator(arViewModel: arViewModel)
    }
    
    func makeUIView(context: Context) -> ARView {
        let arView = ARView(frame: .zero)
        self.arViewModel.arView = arView
        
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
    
    // this code is called when there is an update to a state
    func updateUIView(_ uiView: ARView, context: Context) {
        
        if arViewModel.isPlacingObject {
            print("this isPlacingObject is true, so the rest of code is called")
            
            switch context.coordinator.focusEntity?.state {
            case .tracking:
                
                guard let focusEntity = context.coordinator.focusEntity else {
                    return
                }
                print("currently tracking a surface")
                
                if arViewModel.gameManager.currentLevel == 1 {
                    arViewModel.placeCurrentLevel(transform: focusEntity.transform)
                }
                
                if arViewModel.gameManager.currentLevel == 2 {
                    print("currentLevel is 2")
                    arViewModel.placeCurrentLevel(transform: focusEntity.transform)
                }

            default:
                print("Cannot place object: FocusEntity is not tracking a surface.")
            }
        }
        
        DispatchQueue.main.async {
            arViewModel.isPlacingObject = false
        }
    }
    
    static func dismantleUIView(_ uiView: ARView, coordinator: Coordinator) {
        coordinator.updateSubscription?.cancel()
        coordinator.updateSubscription = nil
        print("ARViewContainer dismantled. updateSubscription cancelled.")
    }
}
