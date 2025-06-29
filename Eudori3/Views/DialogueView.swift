//
//  DialogueView.swift
//  Eudori3
//
//  Created by Djie Valencia Santoso on 27/06/25.
//

import SwiftUI

struct DialogueView: View {
    @ObservedObject var viewModel: DialogueViewModel
    
    var body: some View {
        let slide = viewModel.currentSlide
        
        GeometryReader { geometry in
            ZStack {
                // Tappable background layer (ensures touches are received)
                Color.black.opacity(0.001) // must be > 0 opacity to catch taps
                    .ignoresSafeArea()
                    .onTapGesture {
                        viewModel.nextSlide()
                    }
                
                // Dialogue UI
                ZStack(alignment: .leading) {
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
                    
                    Image("DialogLloyd")
                        .resizable()
                        .aspectRatio(contentMode: .fit)
                        .offset(x: -40, y: 60)
                }
                .frame(maxHeight: .infinity, alignment: .bottom)
            }
        }
    }
}


//#Preview {
//    DialogueView()
//}
