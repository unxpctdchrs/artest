//
//  ToolsViewModel.swift
//  Eudori3
//
//  Created by Vigo on 14/06/25.
//

import SwiftUI

class ToolsViewModel: ObservableObject {
    @Published var isMagnifyingGlassActive: Bool = false
    @Published var isMultimeterActive: Bool = false
    @Published var isThermalGlassActive: Bool = false
}
