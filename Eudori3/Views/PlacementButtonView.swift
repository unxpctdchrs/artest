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
