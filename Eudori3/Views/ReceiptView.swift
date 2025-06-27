//
//  ReceiptView.swift
//  Eudori3
//
//  Created by Djie Valencia Santoso on 26/06/25.
//

import SwiftUI

struct ReceiptView: View {
    var onDismiss: () -> Void
    
    var body: some View {
        GeometryReader { geometry in
            ZStack {
                // Background overlay
                Color.black.opacity(0.6)
                    .ignoresSafeArea()
                
                VStack(spacing: 20) {
                    // Receipt container
                    ZStack {
                        // Receipt background image
                        Image("ReceiptPage")
                            .resizable()
                            .scaledToFit()
                            .frame(width: geometry.size.width)
                            .padding(.trailing, 30)
                        
                        // Receipt content overlay
                        VStack(spacing: 12) {
                            // Header
                            VStack(spacing: 4) {
                                Text("Nota Servis")
                                    .font(.title2)
                                    .fontWeight(.bold)
                                
                                Text("Lloyd Elektronik")
                                    .font(.title2)
                                    .fontWeight(.bold)
                                
                                Text("Jl. Mencari Cinta Sejati")
                                    .font(.subheadline)
                                
                                Text("Batam")
                                    .font(.subheadline)
                            }
                            .padding(.top, 40)
                            
                            // Separator
                            Text(dashLine(width: geometry.size.width * 0.2))
                                .font(.system(.caption, design: .monospaced))
                                .padding(.vertical, 4)
                            
                            // Receipt items
                            VStack(spacing: 8) {
                                receiptItem(title: "Pendapatan", price: "Rp 100,000")
                                receiptItem(title: "Cicilan hutang", price: "Rp 50,000")
                                receiptItem(title: "Pembelian alat baru", price: "Rp 50,000")
                            }
                            
                            // Bottom separator
                            Text(dashLine(width: geometry.size.width * 0.2))
                                .font(.system(.caption, design: .monospaced))
                                .padding(.vertical, 4)
                            
                            // Thank you message
                            Text("Terima kasih")
                                .font(.headline)
                                .fontWeight(.medium)
                            
                            Spacer()
                        }
                        .padding(.horizontal, 30)
                        .frame(maxWidth: geometry.size.width * 0.3)
                        .padding(.top, geometry.size.height * 0.15)
                    }
                    
                    // Continue button
                    Button("Rangkaian Selanjutnya") {
                        print("Button rangakaian selanjutnya diklik")
                        onDismiss()
                    }
                    .font(.headline)
                    .foregroundColor(.black)
                    .frame(maxWidth: 250)
                    .padding(.vertical, 12)
                    .padding(.horizontal, 20)
                    .background(Color("TapableArea"))
                    .cornerRadius(12)
                    .shadow(radius: 4)
                }
                .padding(.horizontal, 20)
            }
        }
    }
    
    @ViewBuilder
    private func receiptItem(title: String, price: String) -> some View {
        HStack {
            Text(title)
                .font(.body)
                .foregroundColor(.black)
            
            Spacer()
            
            Text(price)
                .font(.body)
                .fontWeight(.medium)
                .foregroundColor(.black)
        }
    }
}

private func dashLine(width: CGFloat) -> String {
    let dashWidth: CGFloat = 6.0
    let count = Int(width / dashWidth)
    return String(repeating: "-", count: count)
}

#Preview {
    ReceiptView {
        print("Dismissed")
    }
}
