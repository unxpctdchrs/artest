//
//  ContentView.swift
//  Eudori3
//
//  Created by Vigo on 11/06/25.
//

import SwiftUI
import RealityKit
import FocusEntity

struct ContentView : View {
    @State var isPlacementEnabled: Bool = false
    @State var selectedModel: Model?
    @State var modelConfirmedForPlacement: Model?
    @State var isPlacingObject: Bool = false
    @State var currentLevel: Int = 0
    
    private var models: [Model] = {
        // get dynamically from dir
        let fileManager = FileManager.default
        
        guard let path = Bundle.main.resourcePath, let files = try? fileManager.contentsOfDirectory(atPath: path) else {
            return []
        }
        
        var availabelModels: [Model] = []
        for filename in files where
            filename.hasSuffix("usdz") {
                let modelName = filename.replacingOccurrences(of: ".usdz", with: "")
                // implement from class model
                let model = Model(modelName: modelName)
                availabelModels.append(model)
            }
        
        return availabelModels
    }()

    var body: some View {
        ZStack(alignment: .bottomLeading){
            ARViewContainer(modelConfirmedForPlacement: self.$modelConfirmedForPlacement, isPlacingObject: self.$isPlacingObject, currentLevel: self.$currentLevel).edgesIgnoringSafeArea(.all)
            
            Button {
                self.isPlacingObject = true
                self.currentLevel = 1
            } label: {
                Text("Hello, World!")
            }
            
//            if self.isPlacementEnabled {
//                PlacementButtonsView(isPlacementEnabled: self.$isPlacementEnabled, selectedModel: self.$selectedModel, modelConfirmedForPlacement: self.$modelConfirmedForPlacement)
//            } else {
//                ModelPickerView(isPlacementEnabled: self.$isPlacementEnabled, selectedModel: self.$selectedModel, models: self.models)
//                
//                ToolsView().padding(10)
//            }
        }
    }

}

#Preview {
    ContentView()
}
