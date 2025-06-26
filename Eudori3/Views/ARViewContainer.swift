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
    
//<<<<<<< HEAD
//    @ObservedObject var arViewModel = ARViewModel()
//=======
    @ObservedObject var arViewModel: ARViewModel
//>>>>>>> dev
    @ObservedObject var toolsViewModel: ToolsViewModel
    
    class Coordinator {
        var arViewModel: ARViewModel
        var toolsViewModel: ToolsViewModel
        var focusEntity: FocusEntity?
        var updateSubscription: Cancellable?
        
        init(arViewModel: ARViewModel, toolsViewModel: ToolsViewModel) {
            self.arViewModel = arViewModel
            self.toolsViewModel = toolsViewModel
        }
        
        // This function is called on every frame by the subscription.
        func onUpdate(event: SceneEvents.Update) {
            arViewModel.gameManager.performUpdate(deltaTime: Double(event.deltaTime), arViewModel: arViewModel, toolsViewModel: toolsViewModel)
            
            if arViewModel.focusEntityState == false {
                focusEntity?.isEnabled = false
            }
        }
    }

    func makeCoordinator() -> Coordinator {
        return Coordinator(arViewModel: arViewModel, toolsViewModel: toolsViewModel)
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

        //set ARView for multimeter tool
        toolsViewModel.setARView(arView)
        
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
                
//<<<<<<< HEAD
//                if arViewModel.gameManager.currentLevel == 1 {
//                    arViewModel.placeCurrentLevel(transform: focusEntity.transform, toolsViewModel: toolsViewModel)
//                }
//                
//                if arViewModel.gameManager.currentLevel == 2 {
//                    print("currentLevel is 2")
//                    arViewModel.placeCurrentLevel(transform: focusEntity.transform, toolsViewModel: toolsViewModel)
//=======
                if arViewModel.gameManager.currentLevel > 0 {
                    arViewModel.placeCurrentLevel(transform: focusEntity.transform, toolsViewModel: toolsViewModel)
//>>>>>>> dev
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
