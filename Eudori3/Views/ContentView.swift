//
//  ContentView.swift
//  Eudori3
//
//  Created by Vigo on 11/06/25.
//

import SwiftUI

struct ContentView : View {
    @StateObject var arViewModel = ARViewModel()

    var body: some View {
        ZStack(alignment: .center){
            ARViewContainer(arViewModel: arViewModel).edgesIgnoringSafeArea(.all)
            
            Button {
                arViewModel.isPlacingObject = true
                arViewModel.currentLevel = 1
            } label: {
                Text("Hello, World!")
            }
            
            VStack {
                Spacer()
                HStack {
                    ToolsView()
                    Spacer()
                    Button {
                        arViewModel.goToNextLevel()
                    } label: {
                        Text("GO TO NEXT LEVEL")
                    }
                }
            }
        }
    }
}

#Preview {
    ContentView()
}
