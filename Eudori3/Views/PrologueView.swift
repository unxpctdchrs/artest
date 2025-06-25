//
//  PrologueView.swift
//  LloydElectrofixJourney
//
//  Created by Djie Valencia Santoso on 23/06/25.
//

import SwiftUI

struct PrologueView: View {
    @ObservedObject var viewModel = PrologueViewModel()
    var onFinish: () -> Void
    
    var body: some View {
        let slide = viewModel.slides[viewModel.currentIndex]
        
            ZStack {
                Color.black.opacity(0.95)
                    .ignoresSafeArea()
                
                VStack {
                    Image(slide.imageName)
                        .resizable()
                        .scaledToFit()
                        .padding()
                    
                    Spacer()
                    
                    VStack(alignment: .leading, spacing: 12) {
                        Text(slide.text)
                            .foregroundColor(.black)
                            .font(.custom("Nunito", size: 28))
                        
                        HStack {
                            Spacer()
                            Text(viewModel.isLastSlide ? "Mulai game" : "Tekan untuk lanjut")
                                .foregroundColor(.black)
                                .font(.custom("Nunito-SemiBold", size: 18))
                            
                            Image(systemName: "arrowtriangle.forward.fill")
                                .font(.system(size: 18))
                                .foregroundColor(.black)
                        }
                    }
                    .padding()
                    .frame(maxWidth: .infinity)
                    .background(Color("DialogBox"))
                    .cornerRadius(12)
                    .padding()
                }
            }
            .contentShape(Rectangle()) // Make the whole ZStack tappable
            .onTapGesture {
                print("Tapped. Current index: \(viewModel.currentIndex)")
                if viewModel.isLastSlide {
                    onFinish()
                } else {
                    viewModel.nextSlide()
                }
            }
            }
        }
    


#Preview {
    PrologueView{}
}
