//
//  DialogueView.swift
//  Eudori3
//
//  Created by Djie Valencia Santoso on 27/06/25.
//

import SwiftUI

struct DialogueView: View {
    @ObservedObject var viewModel: DialogueViewModel
    @Binding var showDialogue: Bool
    @Binding var currentIndexDialogue: Int
    @State var currentIndex: Int = 0
    
    var body: some View {
        let slide = viewModel.slides[viewModel.currentIndex]
        
        GeometryReader { geometry in
            ZStack {
                // Transparent full screen tap area
                Rectangle()
                    .fill(Color.clear)
                    .ignoresSafeArea()
                    .onTapGesture {
                        print("Next slide tapped")
                    }
                
                ZStack(alignment: .leading) {
                    // Dialog box with border and padding
                    VStack(alignment: .leading, spacing: 12) {
                        Text(slide.text)
                            .foregroundColor(.black)
                            .font(.custom("Nunito", size: 24))
                            .padding(.leading, geometry.size.width * 0.115)
                        
                        HStack {
                            Spacer()
                            Text("Tekan untuk lanjut")
                                .foregroundColor(.black)
                                .font(.custom("Nunito-SemiBold", size: 16))
                            Image(systemName: "arrowtriangle.forward.fill")
                                .font(.system(size: 16))
                                .foregroundColor(.black)
                        }
                    }
                    .padding()
                    .background(Color("DialogBox"))
                    .overlay(
                        RoundedRectangle(cornerRadius: 12)
                            .stroke(Color("TapableArea"), lineWidth: 12)
                    )
                    .cornerRadius(12)
                    .padding(.horizontal, 60)
                    .padding(.top, geometry.size.width * 0.45)
                    .padding(.leading, geometry.size.width * 0.1)
                    
                    // Lloyd portrait image, overlapping from the left
                    Image("DialogLloyd")
                        .resizable()
                        .aspectRatio(contentMode: .fit)
                        .offset(x: -40, y: 60)
                }
                .frame(maxHeight: .infinity, alignment: .bottom)
            }
            .onTapGesture {
                print("Tapped. Current index on viewmodel: \(viewModel.currentIndex)")
                    viewModel.nextSlide()
//                currentIndexDialogue += 1
//                viewModel.currentIndex = currentIndexDialogue
//                print("current index on view: \(currentIndex)")
//                print("current index on mainview: \(currentIndexDialogue)")
//                if currentIndexDialogue == 2 { showDialogue = false }
//                if currentIndexDialogue == 3 { showDialogue = false }
            }
        }
    }
}


#Preview {
    ContentView()
}
