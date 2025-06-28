//
//  MultimeterToolView.swift
//  Eudori3
//
//  Created by Tubagus Ariq Naufal on 24/06/25.
//

import SwiftUI

struct MultimeterToolView: View {
    @ObservedObject var viewModel: ToolsViewModel
        @State var showGuidebook = false

        var body: some View {
            ZStack(alignment: .center) {
                VStack {
                    if viewModel.isMultimeterActive {
                        Text(viewModel.isFocusing ?
                             (viewModel.focusedEntityName.isEmpty ? "Fokuskan ke objek..." : viewModel.focusedEntityName)
                             :
                             (viewModel.focusProgress > 0.1 ? "Tahan kamera untuk mendapatkan nilai..." : "Tidak ada objek yang difokuskan"))
                            .padding(8)
                            .background(Color.black.opacity(0.6))
                            .foregroundColor(.white)
                            .cornerRadius(10)
                            .padding(.top, 50)
                    }

                    Spacer()

                    HStack(spacing: 20) {
                        Button(action: {
                            viewModel.toggleMultimeter()
                        }) {
                            Text(viewModel.isMultimeterActive ? "Matikan Multimeter" : "Aktifkan Multimeter")
                                .padding()
                                .background(viewModel.isMultimeterActive ? Color.red : Color.green)
                                .foregroundColor(.white)
                                .cornerRadius(10)
                        }
                    }
                    .padding(.bottom, 40)
                }

                if showGuidebook {
                    Color.black.opacity(0.6)
                        .edgesIgnoringSafeArea(.all)

                    Image("guidebook")
                        .resizable()
                        .scaledToFit()
                        .padding(20)
                        .background(Color.white.opacity(0.8))
                        .cornerRadius(16)
                        .shadow(radius: 10)

                    VStack {
                        Spacer()
                        Button("Tutup") {
                            showGuidebook = false
                        }
                        .padding()
                        .background(Color.white)
                        .foregroundColor(.black)
                        .cornerRadius(12)
                        .padding(.bottom, 40)
                    }
                }

                if viewModel.isMultimeterActive {
                    Circle()
                        .strokeBorder(lineWidth: 4)
                        .foregroundColor(Color(red: 1.0 - viewModel.focusProgress,
                                               green: viewModel.focusProgress,
                                               blue: 0))
                        .frame(width: 40, height: 40)
                        .animation(.easeInOut(duration: 0.15), value: viewModel.focusProgress)
                }
            }
        }
}

//#Preview {
//    MultimeterToolView()
//}
