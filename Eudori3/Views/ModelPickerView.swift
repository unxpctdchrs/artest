//
//  ModelPickerView.swift
//  Eudori3
//
//  Created by Vigo on 11/06/25.
//

import SwiftUI

struct ModelPickerView: View {
    
    @Binding var isPlacementEnabled: Bool
    @Binding var selectedModel: Model?
    
    var models: [Model]
    
    var body: some View {
        ScrollView(.horizontal, showsIndicators: false){
            HStack(spacing: 30){
                ForEach(0 ..< self.models.count){ index in
                    Button(action: {
                        print("DEBUG: Selected with name \(self.models[index].modelName)")
                        
                        self.isPlacementEnabled = true
                        self.selectedModel = self.models[index]
                    }){
                        Image(uiImage: self.models[index].image)
                            .resizable()
                            .frame(height: 60)
                            .aspectRatio(1/1, contentMode: .fit)
                            .background(Color.white)
                            .cornerRadius(20)
                    }.buttonStyle(PlainButtonStyle())
                }
            }
        }
        .padding()
        .background(Color.black.opacity(0.5))
        .padding(.bottom)
    }
}
