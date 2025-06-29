//
//  Level1.swift
//  Eudori3
//
//  Created by Vigo on 21/06/25.
//

import Foundation
import RealityKit
import UIKit

class Level1: Level {
    func getCapacitor() -> Entity? {
        return Entity()
    }
    
    let id: Int = 2
    
    var model: Model
    var lamp: [ModelEntity] = []
    
    private var level1IsActive: Bool = false
    private var isCapacitorAttached: Bool = false
    private var attachmentTimer: Double = 0.0
    private let attachmentDelay: Double = 3.0
    
    private var hasShownFloatingText = false
    private var toolsViewModel: ToolsViewModel?
    private var floatingTextEntity: ModelEntity?
    
    private var probePlusEntity: ModelEntity?
    private var probeMinusEntity: ModelEntity?
    private var cableProbePlusEntity: ModelEntity?
    private var cableProbeMinusEntity: ModelEntity?
    
    private var isCableAttachCorrect: Bool = false
    private var isPlusCableAttached: Bool = false
    private var isMinusCableAttached: Bool = false
    
    init() {
        self.model = Model()
    }
    
    func setupLevel(in arView: ARView, with anchorTransform: Transform, arViewModel: ARViewModel, toolsViewModel: ToolsViewModel) {
        guard let circuit = try? Entity.load(named: "testboard_6"), let capacitor = try? ModelEntity.loadModel(named: "capacitor_1.usdz"), let multimeter = try? ModelEntity.loadModel(named: "multimeter.usdz") else {
            print("Failed to load models in level1.")
            return
        }
        
        let probe_plus = createFloatingProbe("+", 1)
        let probe_minus = createFloatingProbe( "-", 2)
        
        self.probePlusEntity = probe_plus
        self.probeMinusEntity = probe_minus
        
        
        probe_plus.name = "probe_plus"
        probe_minus.name = "probe_minus"
        
        
        probe_plus.position = [capacitor.position.x - 0.00, capacitor.position.y + 0.0, capacitor.position.z - 0.0]
        probe_plus.transform = Transform(
            rotation: simd_quatf(angle: -.pi / 2, axis: [1.0, 0, 0]), // rotasi 90° ke atas
            translation: [-0.05, 0.05, 0.0] // posisi ke atas dalam ruang dunia
        )
        probe_minus.position = [capacitor.position.x - 0.0, capacitor.position.y + 0.0, capacitor.position.z - 0.0]
        probe_minus.transform = Transform(
            rotation: simd_quatf(angle: -.pi / 2, axis: [1.0, 0, 0]), // rotasi 90° ke atas
            translation: [0.05, 0.05, 0.0] // posisi ke atas dalam ruang dunia
        )
        
        self.toolsViewModel = toolsViewModel
        
        self.model.circuitEntity = circuit
        self.model.capacitorEntity = capacitor
        self.model.multimeter = multimeter
        
        capacitor.name = "Capacitor"
        capacitor.components.set(CapacitanceComponent(value: "100 μF"))
        circuit.generateCollisionShapes(recursive: true)
        capacitor.generateCollisionShapes(recursive: true)
        multimeter.generateCollisionShapes(recursive: true)
        
        probe_plus.generateCollisionShapes(recursive: true)
        probe_minus.generateCollisionShapes(recursive: true)
        
        arView.installGestures([.translation, .rotation], for: capacitor)
        //        arView.installGestur([.translation, .rotation], for: multimeter)
        
        // Register tap gesture
        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(handleTap(_:)))
        arView.addGestureRecognizer(tapGesture)
        
        let anchor = AnchorEntity()
        anchor.transform = anchorTransform
        anchor.addChild(circuit)
        
        //        capacitor.position.x = 0.1
        multimeter.position.x = 0.7
        
        let label = createFloatingText("Kapasitansi: 100 μF")
        label.generateCollisionShapes(recursive: true)
        //        label.position.x = 2.0
        multimeter.addChild(label)
        
        
        anchor.addChild(capacitor)
        anchor.addChild(multimeter)
        
        anchor.addChild(probe_plus)
        anchor.addChild(probe_minus)
        
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
        
        arView.scene.anchors.append(anchor)
        
        DispatchQueue.main.async {
            self.probePlusEntity?.isEnabled = true
            self.probeMinusEntity?.isEnabled = true
        }
        
//        DispatchQueue.main.async {
//            let cablePlus = self.drawCable(from: multimeter, to: probe_plus, in: arView, isCableColorReversed: false)
//            let cableMinus = self.drawCable(from: multimeter, to: probe_minus, in: arView, isCableColorReversed: false)
//            self.cableProbePlusEntity = cablePlus
//            self.cableProbeMinusEntity = cableMinus
//            
//            cablePlus.generateCollisionShapes(recursive: true)
//            cableMinus.generateCollisionShapes(recursive: true)
//            
//            anchor.addChild(cablePlus)
//            anchor.addChild(cableMinus)
//            
//            cablePlus.isEnabled = true
//            cableMinus.isEnabled = true
//            self.probePlusEntity?.isEnabled = true
//            self.probeMinusEntity?.isEnabled = true
//        }
        
        DispatchQueue.main.async {
            arViewModel.focusEntityState = false
            self.level1IsActive = true
            print("Level 1 setup complete. onUpdate logic is now active.")
        }
    }
    
    func update(deltaTime: Double, arViewModel: ARViewModel, toolsViewModel: ToolsViewModel) {
        guard level1IsActive else { return }
        guard let toolsViewModel = self.toolsViewModel,
              let multimeter = self.model.multimeter,
              let capacitor = self.model.capacitorEntity,
              let circuit = self.model.circuitEntity,
              let probePlusEntity = self.probePlusEntity,
              let probeMinusEntity = self.probeMinusEntity,
//              var cableProbePlusEntity = self.cableProbePlusEntity,
//              var cableProbeMinusEntity = self.cableProbeMinusEntity,
              let arView = arViewModel.arView,
              let anchor = arView.scene.anchors.first
        else { return }
        
        
        // Syarat untuk tampilkan floatingText
        if toolsViewModel.isMultimeterActive  {
            self.probePlusEntity?.isEnabled = true
            self.probeMinusEntity?.isEnabled = true
            
            if toolsViewModel.isFocusing {
                print("MASUK")
                switch (toolsViewModel.isProbePlusActive, toolsViewModel.isProbeMinusActive) {
                case (true, false):
                    print("PLUS ACTIVE ONLY -> CORRECT WAY")
                    isCableAttachCorrect = true
                    if !isPlusCableAttached && cableProbePlusEntity == nil {
                        let cable = drawCable(from: multimeter, to: probePlusEntity, in: arView, isCableColorReversed: true)
                        print("CABLEEE! \(cable)")
                        anchor.addChild(cable)
                        cableProbePlusEntity = cable
                        isPlusCableAttached = true
                    }
                case (false, true):
                    print("MINUS ACTIVE ONLY -> WRONG WAY -> MUST PLUS FIRST")
                    isCableAttachCorrect = false
                    if !isMinusCableAttached && cableProbeMinusEntity == nil {
                        let cable = drawCable(from: multimeter, to: probeMinusEntity, in: arView, isCableColorReversed: true)
                        anchor.addChild(cable)
                        cableProbeMinusEntity = cable
                        isMinusCableAttached = true
                    }
                case (true, true):
                    print("BOTH ACTIVE")
                    if(isPlusCableAttached && !isMinusCableAttached) {
                        let cable = drawCable(from: multimeter, to: probeMinusEntity, in: arView, isCableColorReversed: true)
                        anchor.addChild(cable)
                        cableProbeMinusEntity = cable
                        isMinusCableAttached = true
                    } else if (isMinusCableAttached && !isPlusCableAttached) {
                        print("COMING IN")
                        let cable = drawCable(from: multimeter, to: probePlusEntity, in: arView, isCableColorReversed: true)
                        anchor.addChild(cable)
                        cableProbePlusEntity = cable
                        isPlusCableAttached = true
                    }
                    if floatingTextEntity == nil &&
                        !toolsViewModel.focusedEntityName.isEmpty {
                        let label = createFloatingText("15 μF")
                        
                        label.position = [multimeter.position.x - 0.1, multimeter.position.y + 0.1, multimeter.position.z - 0.15]
                        label.transform = Transform(
                            rotation: simd_quatf(angle: -.pi / 2, axis: [1.0, 0, 0]), // rotasi 90° ke atas
                            translation: [0.61, 0.1, -0.08] // posisi ke atas dalam ruang dunia
                        )
                        anchor.addChild(label)
                        floatingTextEntity = label
                    }
                case (false, false):
                    print("ALL PROBES ARE FALSE!")
                default:
                    break
                }
                floatingTextEntity?.isEnabled = true
            }
        } else if(!toolsViewModel.isMultimeterActive) {
            floatingTextEntity?.removeFromParent()
            floatingTextEntity?.isEnabled = false
            floatingTextEntity = nil
            probePlusEntity.isEnabled = false
            probeMinusEntity.isEnabled = false
            cableProbePlusEntity?.removeFromParent()
            cableProbeMinusEntity?.removeFromParent()
            cableProbePlusEntity?.isEnabled = false
            cableProbeMinusEntity?.isEnabled = false
            cableProbePlusEntity = nil
            cableProbeMinusEntity = nil
            isPlusCableAttached = false
            isMinusCableAttached = false
        }
        
        
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
            //            print("Animation already active, not starting new one.")
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
    
    func createFloatingText(_ text: String) -> ModelEntity {
        let mesh = MeshResource.generateText(
            text,
            extrusionDepth: 0.01,
            font: .systemFont(ofSize: 0.05),
            containerFrame: .zero,
            alignment: .center,
            lineBreakMode: .byWordWrapping
        )
        
        let material = SimpleMaterial(color: .green, isMetallic: false)
        let entity = ModelEntity(mesh: mesh, materials: [material])
        entity.name = "FloatingText"
        //        entity.components.set(BillboardComponent(worldFacing: .camera))
        return entity
    }
    
    @objc func handleTap(_ sender: UITapGestureRecognizer) {
        guard let arView = sender.view as? ARView else { return }
        
        let location = sender.location(in: arView)
        
        guard let tappedEntity = arView.entity(at: location),
              let multimeter = model.multimeter else { return }
        
        if isDescendant(of: multimeter, tappedEntity: tappedEntity) {
            print("✅ Multimeter tapped")
            toolsViewModel?.isMultimeterActive.toggle()
        }
    }
    func isDescendant(of parent: Entity?, tappedEntity: Entity) -> Bool {
        var current: Entity? = tappedEntity
        while let c = current {
            if c == parent {
                return true
            }
            current = c.parent
        }
        return false
    }
    
    func drawCable(from: Entity, to: Entity, in arView: ARView?, isCableColorReversed: Bool) -> ModelEntity {
        guard let anchor = arView?.scene.anchors.first else { return ModelEntity() }
        
        
        let start = from.position(relativeTo: anchor)
        let end = to.position(relativeTo: anchor)
        
        let cable = createCableEntity(from: start, to: end, probeType: to.name, isCableColorReversed: isCableColorReversed)
        
        return cable
    }
    
    func createCableEntity(from start: SIMD3<Float>, to end: SIMD3<Float>, radius: Float = 0.004, probeType: String, isCableColorReversed: Bool) -> ModelEntity {
        let direction = normalize(end - start)
        let height = distance(start, end)
        
        // Buat silinder sesuai panjang antar 2 titik
        let mesh = MeshResource.generateCylinder(height: height, radius: radius)
        
        let material = SimpleMaterial(color: probeType == "probe_plus" ? .red : .black, isMetallic: true)
        
        let entity = ModelEntity(mesh: mesh, materials: [material])
        
        // Tempatkan silinder di tengah antara start dan end
        entity.position = (start + end) / 2
        
        // Rotasi agar arah silinder mengikuti vektor start → end
        let up = SIMD3<Float>(0, 1, 0)
        let axis = cross(up, direction)
        let angle = acos(dot(up, direction))
        
        if angle != 0 {
            entity.orientation = simd_quatf(angle: angle, axis: normalize(axis))
        }
        
        return entity
    }
    
    func createFloatingProbe(_ text: String, _ id: Int) -> ModelEntity {
        // Buat sphere transparan
        let mesh = MeshResource.generateSphere(radius: 0.015)
        let transparentMaterial = UnlitMaterial(color: id == 1 ? .red.withAlphaComponent(0.1) : .black.withAlphaComponent(0.1)) // transparan & tidak casting shadow
        
        let sphereEntity = ModelEntity(mesh: mesh, materials: [transparentMaterial])
        sphereEntity.name = "probe_sphere"
        
        // Buat text di dalam sphere
        let textMesh = MeshResource.generateText(
            text,
            extrusionDepth: 0.001,
            font: .systemFont(ofSize: 0.1),
            containerFrame: .zero,
            alignment: .center,
            lineBreakMode: .byClipping
        )
        let textMaterial = UnlitMaterial(color: id == 1 ? .red :.black) // pakai unlit biar ga tergantung pencahayaan
        let textEntity = ModelEntity(mesh: textMesh, materials: [textMaterial])
        textEntity.name = "sign"
        textEntity.position = SIMD3<Float>(-0.03, 0, 0.005) // nyaris tepat di pusat bola
        
        // Gabungkan teks ke dalam sphere
        sphereEntity.addChild(textEntity)
        
        return sphereEntity
    }
}
