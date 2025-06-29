//
//  CustomerResponseView.swift
//  Eudori3
//
//  Created by Djie Valencia Santoso on 28/06/25.
//

import SwiftUI

struct CustomerResponseView: View {
    @ObservedObject var viewModel: CustomerResponseViewModel
    var onNext: () -> Void
    
    var body: some View {
        GeometryReader { geometry in
            ZStack {
                // Background overlay
                Color.black.opacity(0.6)
                    .ignoresSafeArea()
                
                VStack {
                    ZStack {
                        Image("DialogCustomer")
                            .resizable()
                            .scaledToFit()
                            .frame(width: geometry.size.width * 0.7)
                        
                        VStack(alignment: .leading) {
                            Text("Pelanggan")
                                .padding(.vertical, 4)
                                .font(.custom("Nunito-Bold", size: 24))
                            
                            Text(viewModel.responseText)
                                .font(.custom("Nunito", size: 24))
                        }
                        .frame(width: geometry.size.width * 0.35)
                        .padding(.leading, 150)
                    }
                    
                    Spacer()
                    
                    HStack {
                        Text("Tekan untuk lanjut")
                            .foregroundColor(.white)
                            .font(.custom("Nunito-SemiBold", size: 18))
                    }
                }
                .frame(maxHeight: .infinity, alignment: .top)
            }
        }
    }
}

#Preview {
    CustomerResponseView(viewModel: {
        let vm = CustomerResponseViewModel()
        vm.diagnosisResult = .correct
        return vm
    }(), onNext: {
        print("Next pressed")
    })
}
