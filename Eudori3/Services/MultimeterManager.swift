//
//  MultimeterManager.swift
//  Eudori3
//
//  Created by Tubagus Ariq Naufal on 24/06/25.
//

import Foundation
import RealityKit
import Combine
import SwiftUI

class MultimeterManager: ObservableObject {
    weak var arView: ARView?
    private var updateCancellable: Cancellable?
    
    var onFocusDetected: ((Entity) -> Void)?
    var onFocusProgressUpdate: ((Double) -> Void)?
    var onNoEntityFocused: (() -> Void)?
    var onFocusProbePlus: ((String) -> Void)?
    var onFocusProbeMinus: ((String) -> Void)?
    var onFocusProbeType: ((String) -> Void)?
    
    private var focusTimer: Double = 0
    private let focusThreshold: Double = 1.5
    private var lastEntity: Entity?
    
    private var toolsViewModel: ToolsViewModel?
    
    init(arView: ARView) {
        self.arView = arView
    }
    
    func activate() {
        guard let arView = arView else { return }
        print("ACTIVATED!!!")
        updateCancellable = arView.scene.subscribe(to: SceneEvents.Update.self) { [weak self] event in
            self?.detectFocusedEntity(deltaTime: event.deltaTime)
        }
    }
    
    func deactivate() {
        updateCancellable?.cancel()
        updateCancellable = nil
        focusTimer = 0
        lastEntity = nil
    }
    
    private func detectFocusedEntity(deltaTime: Double) {
        guard let arView = arView
        else {
            onNoEntityFocused?()
            return
        }
        let toolsViewModel = self.toolsViewModel
        let center = CGPoint(x: arView.bounds.midX, y: arView.bounds.midY)
        
        if let entity = arView.entity(at: center),
           let model = getModelEntity(from: entity) {
            print("GET MODEL \(model)")
            
            if model != lastEntity {
                focusTimer = 0
                lastEntity = model
            } else {
                focusTimer += deltaTime
            }
            
            let progress = min(focusTimer / focusThreshold, 1.0)
            onFocusProgressUpdate?(progress)
            
            if focusTimer >= focusThreshold {
                onFocusProbeType?(model.name)
                onFocusDetected?(model)
            
            }
        } else {
            focusTimer = 0
            lastEntity = nil
            onFocusProgressUpdate?(0.0)
            onNoEntityFocused?()
            print("CANT GET MODEL")
        }
    }
    
    private func getModelEntity(from entity: Entity?) -> ModelEntity? {
        var current = entity
        while current != nil {
            if let model = current as? ModelEntity, model.name.hasPrefix("probe") {
                return model
            }
            current = current?.parent
        }
        return nil
    }
    
    deinit {
        updateCancellable?.cancel()
    }
    
    func createFloatingText(_ text: String, above entity: ModelEntity) -> ModelEntity {
        let mesh = MeshResource.generateText(
            text,
            extrusionDepth: 0.01,
            font: .systemFont(ofSize: 0.15),
            containerFrame: .zero,
            alignment: .center,
            lineBreakMode: .byWordWrapping
        )

        let material = UnlitMaterial(color: .white)
        let textEntity = ModelEntity(mesh: mesh, materials: [material])
        textEntity.name = "FloatingText"
        textEntity.position = [0, entity.visualBounds(relativeTo: nil).extents.y + 0.02, 0]
//        textEntity.components.set(BillboardComponent(worldFacing: .camera))
        return textEntity
    }

}

