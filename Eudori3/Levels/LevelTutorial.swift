//
//  LevelTutorial.swift
//  Eudori3
//
//  Created by Vigo on 24/06/25.
//

import Foundation
import RealityKit
import SwiftUICore
import UIKit

class LevelTutorial: Level {
    var id: Int = 1
    var model: Model
    var capacitor: Entity?
    private var anchor: AnchorEntity?
    private var hasThermalGlassActionBeenPerformed: Bool = false
    private var lamp: Entity?
    private var toolsViewModel: ToolsViewModel?
    
    //multimeter stuff
    private var hasShownFloatingText: Bool = false
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
        
        self.toolsViewModel = toolsViewModel
        
        guard let circuit = try? Entity.load(named: "tutorial_circuit"),
            let thermalGlass = try? ModelEntity.loadModel(named: "thermal_camera"),
            let multimeter = try? ModelEntity.loadModel(named: "multimeter_2")
        else {
            print("Error loading model")
            return
        }
        
        // register tap gesture
        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(handleTap(_:)))
        arView.addGestureRecognizer(tapGesture)
        
        // circuits
        self.model.circuitEntity = circuit
        circuit.generateCollisionShapes(recursive: true)
        circuit.scale /= 30
    
        guard let capacitor = getCapacitor() else { return }
        self.capacitor = capacitor
        self.model.capacitor = capacitor
        
        // thermalcam
        self.model.thermalGlassEntity = thermalGlass
        thermalGlass.generateCollisionShapes(recursive: true)
        thermalGlass.scale /= 2
        thermalGlass.position.x = -0.2
        let thermalGlassrotation = simd_quatf(angle: .pi / 2.4, axis: [0, 1, 0])
        thermalGlass.transform.rotation = thermalGlassrotation
        
        // multimeter
        self.model.multimeter = multimeter
        multimeter.generateCollisionShapes(recursive: true)
        multimeter.position.x = 0.26
        multimeter.scale *= 1.5
        let multimeterRotation = simd_quatf(angle: .pi / 90, axis: [0, 0, 1])
        multimeter.transform.rotation = multimeterRotation
        
        let probe_plus = createFloatingProbe("+", 1)
        let probe_minus = createFloatingProbe( "-", 2)
        
        self.probePlusEntity = probe_plus
        self.probeMinusEntity = probe_minus
        probe_plus.name = "probe_plus"
        probe_minus.name = "probe_minus"
        
        probe_plus.position = [capacitor.position.x - 0.0, capacitor.position.y - 0.1, capacitor.position.z - 0.03]
        probe_plus.transform = Transform(
            rotation: simd_quatf(angle: -.pi / 2, axis: [1, 0, 0]), // rotasi 90° ke atas
            translation: [-0.018, 0.004, -0.014] // posisi ke atas dalam ruang dunia
        )
        probe_plus.scale /= 5
        
        probe_minus.position = [capacitor.position.x - 0.0, capacitor.position.y - 0.1, capacitor.position.z - 0.03]
        probe_minus.transform = Transform(
            rotation: simd_quatf(angle: .pi / 2, axis: [1, 0, 0]), // rotasi 90° ke atas
            translation: [-0.018, 0.004, 0.0] // posisi ke atas dalam ruang dunia
        )
        probe_minus.scale /= 5
        
        capacitor.name = "Capacitor"
        capacitor.components.set(CapacitanceComponent(value: "100 μF"))
        capacitor.generateCollisionShapes(recursive: true)
        probe_plus.generateCollisionShapes(recursive: true)
        probe_minus.generateCollisionShapes(recursive: true)
        
        // anchor
        let anchor = AnchorEntity()
        anchor.transform = anchorTransform
        
        anchor.addChild(circuit)
        anchor.addChild(thermalGlass)
        anchor.addChild(multimeter)
        anchor.addChild(probe_plus)
        anchor.addChild(probe_minus)
        
        arView.scene.addAnchor(anchor)
        self.anchor = anchor
        
        DispatchQueue.main.async {
            arViewModel.focusEntityState = false
        }
    }
    
    func update(deltaTime: Double, arViewModel: ARViewModel, toolsViewModel: ToolsViewModel) {
        guard let currentCapacitor = self.capacitor else { return }
        if toolsViewModel.isThermalGlassActive && !hasThermalGlassActionBeenPerformed {
            
            self.model.thermalGlassEntity?.isEnabled = false
            
            let lampPosition: SIMD3<Float> = [
                currentCapacitor.position.x - 0.0185,
                currentCapacitor.position.y + 0.008,
                currentCapacitor.position.z - 0.008
            ]
            
            let lampEntity = Entity()
            lampEntity.position = lampPosition
            
            var redGlow = PointLightComponent()
            redGlow.color = .red
            redGlow.intensity = 100
            redGlow.attenuationRadius = 0.1
            
            self.lamp = lampEntity
            
            lampEntity.components.set(redGlow)
            
            anchor?.addChild(lampEntity)
            
            hasThermalGlassActionBeenPerformed = true
        } else if !toolsViewModel.isThermalGlassActive && hasThermalGlassActionBeenPerformed {
            self.model.thermalGlassEntity?.isEnabled = true
            self.lamp?.removeFromParent()
            hasThermalGlassActionBeenPerformed = false
        }
        
        // multimeter
        guard let multimeter = self.model.multimeter,
              let probePlusEntity = self.probePlusEntity,
              let probeMinusEntity = self.probeMinusEntity,
              let arView = arViewModel.arView,
              let anchor = self.anchor
        else {
            print("failed")
            return
        }
        
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
                            translation: [0.225, 0.025, -0.065] // posisi ke atas dalam ruang dunia
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
            else {
                print("isfocusing is: \(toolsViewModel.isFocusing)")
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
    }
    
    //TODO: Fix level cleanup
    func cleanupLevel(in arView: ARView, arViewModel: ARViewModel) {
        if let circuitAnchor = self.anchor {
            circuitAnchor.removeFromParent()
        }
    }
    
    func getCapacitor() -> Entity? {
        guard let capacitorEntity = self.model.circuitEntity?.findEntity(named: "capacitor") else {
            print("capacitor not found")
            return nil
        }
        
        return capacitorEntity
    }
    
    @objc func handleTap(_ sender: UITapGestureRecognizer) {
        guard let arView = sender.view as? ARView else { return }
        
        let location = sender.location(in: arView)
        
        guard let tappedEntity = arView.entity(at: location), let thermalGlass = model.thermalGlassEntity, let multimeter = model.multimeter else { return }
        
        if isDescendant(of: thermalGlass, tappedEntity: tappedEntity) {
            print("✅ thermal camera tapped")
            toolsViewModel?.isThermalGlassActive.toggle()
        }
        
        if isDescendant(of: tappedEntity, tappedEntity: multimeter) {
            print("✅ multimeter tapped")
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
    
    // multimeter stuff
    func createFloatingText(_ text: String) -> ModelEntity {
        let mesh = MeshResource.generateText(
            text,
            extrusionDepth: 0.01,
            font: .systemFont(ofSize: 0.025),
            containerFrame: .zero,
            alignment: .center,
            lineBreakMode: .byWordWrapping
        )
        
        let material = SimpleMaterial(color: .white, isMetallic: false)
        let entity = ModelEntity(mesh: mesh, materials: [material])
        entity.name = "FloatingText"
        //        entity.components.set(BillboardComponent(worldFacing: .camera))
        return entity
    }
    
    func drawCable(from: Entity, to: Entity, in arView: ARView?, isCableColorReversed: Bool) -> ModelEntity {
        guard let anchor = arView?.scene.anchors.first else { return ModelEntity() }
        
        let start = from.position(relativeTo: anchor)
        let end = to.position(relativeTo: anchor)
        
        let cable = createCableEntity(from: start, to: end, probeType: to.name, isCableColorReversed: isCableColorReversed)
        
        return cable
    }
    
    func createCableEntity(from start: SIMD3<Float>, to end: SIMD3<Float>, radius: Float = 0.002, probeType: String, isCableColorReversed: Bool) -> ModelEntity {
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
        textEntity.position = SIMD3<Float>(-0.03, 0, 0.00) // nyaris tepat di pusat bola
        
        // Gabungkan teks ke dalam sphere
        sphereEntity.addChild(textEntity)
        
        return sphereEntity
    }
}
