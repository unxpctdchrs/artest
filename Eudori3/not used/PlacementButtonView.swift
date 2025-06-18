//
//  PlacementButtonView.swift
//  Eudori3
//
//  Created by Vigo on 11/06/25.
//

import SwiftUI

struct PlacementButtonsView: View {
    
    @Binding var isPlacementEnabled: Bool
    @Binding var selectedModel: Model?
    @Binding var modelConfirmedForPlacement: Model?
    
    var body: some View {
        HStack {
            // cancel btn
            Button(action: {
                print("DEBUG: Selecting CANCEL on model")
                self.resetPlacementParams()
            }){
                Image(systemName: "xmark")
                    .frame(width: 60, height: 60)
                    .font(.title)
                    .background(Color.white.opacity(0.75))
                    .cornerRadius(20)
                    .padding(5)
            }
            
            // confirm
            Button(action: {
                print("DEBUG: Selecting CONFIRM on model")
                self.modelConfirmedForPlacement = self.selectedModel
                self.resetPlacementParams()
            }){
                Image(systemName: "checkmark")
                    .frame(width: 60, height: 60)
                    .font(.title)
                    .background(Color.white.opacity(0.75))
                    .cornerRadius(20)
                    .padding(5)
            }
        }
        .padding(.bottom, 25)
    }
    
    func resetPlacementParams() {
        self.isPlacementEnabled = false
        self.selectedModel = nil
    }
}

#Preview {
    @State var isPlacementEnabled: Bool = false
    @State var selectedModel: Model?
    @State var modelConfirmedForPlacement: Model?
    
    PlacementButtonsView(
        isPlacementEnabled: $isPlacementEnabled,
        selectedModel: $selectedModel,
        modelConfirmedForPlacement: $modelConfirmedForPlacement
    )
}


//        guard let model = self.modelConfirmedForPlacement,
//              let modelEntity = model.modelEntity,
//              let focusEntity = context.coordinator.focusEntity else {
//            // If any of these are nil, we can't proceed.
//            return
//        }
//
//        print("DEBUG: Adding model to scene - \(model.modelName)")
//
//        let clonedEntity = modelEntity.clone(recursive: true)
//        clonedEntity.generateCollisionShapes(recursive: true)
//        uiView.installGestures([.translation, .rotation, .scale], for: clonedEntity)
//
//        let anchorEntity = AnchorEntity()
//        anchorEntity.transform = focusEntity.transform
//
//        anchorEntity.addChild(clonedEntity)
//        uiView.scene.addAnchor(anchorEntity)
//
//        DispatchQueue.main.async {
//            self.modelConfirmedForPlacement = nil
//        }
//
//        // Example: Attach the capacitor after 3 seconds
//        DispatchQueue.main.asyncAfter(deadline: .now() + 3.0) {
//            if let socketEntity = modelEntity.findEntity(named: "capacitor_socket_1") {
//
//                print("Socket 'capacitor_socket_1' found!")
//
//                // 3. Attach the capacitor as a child of the socket
//                // This automatically gives it the correct position and orientation.
//                if let capacitor = modelEntity.findEntity(named: "capacitor") {
//                    socketEntity.addChild(capacitor)
//                }
//
//            } else {
//                print("ERROR: Could not find entity named 'capacitor_socket_1' in the model.")
//            }
//        }
