//
//  Level2.swift
//  Eudori3
//
//  Created by Vigo on 22/06/25.
//

import RealityKit
import Foundation
import UIKit

class Level2: Level {
    func getCapacitor() -> Entity? {
        return Entity()
    }
    
    var id: Int = 3
    
    var model: Model
    
    private var level2IsActive: Bool = false
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
        guard let circuit = try? Entity.load(named: "emptyCircuit"), let capacitor = try? ModelEntity.loadModel(named: "capacitor.usdz"), let multimeter = try? ModelEntity.loadModel(named: "multimeter.usdz") else {
            print("Failed to load models in level2.")
            return
        }
        
        let probe_plus = createFloatingProbe("+", 1)
        let probe_minus = createFloatingProbe("-", 2)
        
        self.probePlusEntity = probe_plus
        self.probeMinusEntity = probe_minus
        
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
        self.model.multimeter = multimeter
        circuit.generateCollisionShapes(recursive: true)
        multimeter.generateCollisionShapes(recursive: true)
        probe_plus.generateCollisionShapes(recursive: true)
        probe_minus.generateCollisionShapes(recursive: true)
        
        // Register tap gesture
        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(handleTap(_:)))
        arView.addGestureRecognizer(tapGesture)
        
        let anchor = AnchorEntity()
        anchor.transform = anchorTransform
        anchor.addChild(circuit)
        
        multimeter.position.x = 0.7
        
        let label = createFloatingText("Kapasitansi: 300 μF")
        label.generateCollisionShapes(recursive: true)
        multimeter.addChild(label)
        
        anchor.addChild(capacitor)
        anchor.addChild(multimeter)
        
        anchor.addChild(probe_plus)
        anchor.addChild(probe_minus)
        
        arView.scene.addAnchor(anchor)
        
        DispatchQueue.main.async {
            let cablePlus = self.drawCable(from: multimeter, to: probe_plus, in: arView, isCableColorReversed: false)
            let cableMinus = self.drawCable(from: multimeter, to: probe_minus, in: arView, isCableColorReversed: false)
            self.cableProbePlusEntity = cablePlus
            self.cableProbeMinusEntity = cableMinus
            
            cablePlus.generateCollisionShapes(recursive: true)
            cableMinus.generateCollisionShapes(recursive: true)
            
            anchor.addChild(cablePlus)
            anchor.addChild(cableMinus)
            
            cablePlus.isEnabled = true
            cableMinus.isEnabled = true
            self.probePlusEntity?.isEnabled = true
            self.probeMinusEntity?.isEnabled = true
        }
        
        DispatchQueue.main.async {
            self.level2IsActive = true
            print("Level 2 setup complete. onUpdate logic is now active.")
        }
    }
    
    func update(deltaTime: Double, arViewModel: ARViewModel, toolsViewModel: ToolsViewModel) {
        guard level2IsActive else { return }
        guard let toolsViewModel = self.toolsViewModel,
              let multimeter = self.model.multimeter,
              let capacitor = self.model.capacitorEntity,
              let circuit = self.model.circuitEntity,
              let probePlusEntity = self.probePlusEntity,
              let probeMinusEntity = self.probeMinusEntity,
              var cableProbePlusEntity = self.cableProbePlusEntity,
              var cableProbeMinusEntity = self.cableProbeMinusEntity,
              let arView = arViewModel.arView,
              let anchor = arView.scene.anchors.first
        else { return }
        
        // Syarat untuk tampilkan floatingText
        if toolsViewModel.isMultimeterActive {
            self.probePlusEntity?.isEnabled = true
            self.probeMinusEntity?.isEnabled = true
            
            if toolsViewModel.isFocusing {
                print("MASUK")
                switch (toolsViewModel.isProbePlusActive, toolsViewModel.isProbeMinusActive) {
                case (true, false):
                    print("PLUS ACTIVE ONLY -> CORRECT WAY")
                    isCableAttachCorrect = true
                    if !isPlusCableAttached {
                        cableProbePlusEntity = drawCable(from: multimeter, to: probePlusEntity, in: arView, isCableColorReversed: true)
                        anchor.addChild(cableProbePlusEntity)
                        isPlusCableAttached = true
                    }
                case (false, true):
                    print("MINUS ACTIVE ONLY -> WRONG WAY -> MUST PLUS FIRST")
                    isCableAttachCorrect = false
                    if !isMinusCableAttached {
                        cableProbeMinusEntity = drawCable(from: multimeter, to: probeMinusEntity, in: arView, isCableColorReversed: true)
                        anchor.addChild(cableProbeMinusEntity)
                        isMinusCableAttached = true
                    }
                case (true, true):
                    print("BOTH ACTIVE")
                    print("isCableAttachCorrect: \(isCableAttachCorrect)")
                    print("isplusCableAttached: \(isPlusCableAttached)")
                    print("isMinusCableAttached: \(isMinusCableAttached)")
                    isPlusCableAttached = true
                    isMinusCableAttached = true
                    if(isPlusCableAttached) {
                        cableProbeMinusEntity = drawCable(from: multimeter, to: probeMinusEntity, in: arView, isCableColorReversed: true)
                        anchor.addChild(cableProbeMinusEntity)
                    } else if (isMinusCableAttached) {
                        print("COMING IN")
                        cableProbePlusEntity = drawCable(from: multimeter, to: probeMinusEntity, in: arView, isCableColorReversed: true)
                        anchor.addChild(cableProbePlusEntity)
                    }
                    if floatingTextEntity == nil &&
                        !toolsViewModel.focusedEntityName.isEmpty {
                        //                    var label = createFloatingText("0")
                        let label = createFloatingText("15 μF")
                        
                        label.position = [multimeter.position.x - 0.1, multimeter.position.y + 0.1, multimeter.position.z - 0.15]
                        label.transform = Transform(
                            rotation: simd_quatf(angle: -.pi / 2, axis: [1.0, 0, 0]), // rotasi 90° ke atas
                            translation: [0.61, 0.1, -0.08] // posisi ke atas dalam ruang dunia
                        )
                        //                label.position = [0.1, 0.1, 0] // relatif ke multimeter (naik 5 cm)
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
            cableProbePlusEntity.isEnabled = false
            cableProbeMinusEntity.isEnabled = false
            cableProbePlusEntity.removeFromParent()
            cableProbeMinusEntity.removeFromParent()
            
            print("level 2 update")
        }
    }
    
    func cleanupLevel(in arView: ARView, arViewModel: ARViewModel) {
        print("cleanup")
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
        
        let material = SimpleMaterial(color: .yellow, isMetallic: false)
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
