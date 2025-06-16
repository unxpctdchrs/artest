//
//  Model.swift
//  Eudori3
//
//  Created by Vigo on 11/06/25.
//

import UIKit
import RealityKit
import Combine

class Model {
    var modelName: String
    var image: UIImage
    var modelEntity: ModelEntity?
    
    private var cancellable: AnyCancellable? = nil
    
    init(modelName: String) {
        self.modelName = modelName
        
        self.image = UIImage(named: modelName) ?? UIImage(systemName: "photo")!
        
        let filename = modelName + ".usdz"
        self.cancellable = ModelEntity.loadModelAsync(named: filename)
            .sink(receiveCompletion: { loadCompletion in
                // Handle error
                print("DEBUG: Model loading failed: \(self.modelName)")
            }, receiveValue: { modelEntity in
                // get model entity
                self.modelEntity = modelEntity
                print("DEBUG: Model loading successful: \(self.modelName)")
            })
    }
}
