//
//  GameService.swift
//  Eudori3
//
//  Created by Vigo on 21/06/25.
//

import RealityKit

protocol Level {
    var id: Int { get }
    var model: Model { get set }
    
//<<<<<<< HEAD
    func setupLevel(in arView: ARView, with anchorTransform: Transform, arViewModel: ARViewModel, toolsViewModel: ToolsViewModel)
    func update(deltaTime: Double, arViewModel: ARViewModel)
//=======
//    func setupLevel(in arView: ARView, with anchorTransform: Transform, arViewModel: ARViewModel)
//    func update(deltaTime: Double, arViewModel: ARViewModel, toolsViewModel: ToolsViewModel)
//>>>>>>> dev
    func cleanupLevel(in arView: ARView, arViewModel: ARViewModel)
    
    func getCapacitor() -> Entity? 
}
