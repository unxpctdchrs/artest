//
//  ChecklistView.swift
//  LloydElectrofixJourney
//
//  Created by Djie Valencia Santoso on 23/06/25.
//

import SwiftUI

struct ChecklistView: View {
    var onDismiss: () -> Void
    @State private var selectedVoltage: String? = nil
    @State private var selectedPolarity: String? = nil
    @State private var selectedCapacitance: String? = nil
    
    var body: some View {
        GeometryReader { geometry in
            ZStack {
                Color.black.opacity(0.6)
                    .ignoresSafeArea()
                    .contentShape(Rectangle())
                    .onTapGesture {
                        print("Tapped background")
                        onDismiss()
                    }
                    .zIndex(0)
                
                Image("ChecklistPage")
                    .resizable()
                    .scaledToFit()
                    .frame(width: geometry.size.width * 0.95)
                    .zIndex(1)
                
                VStack(alignment: .leading, spacing: 24) {
                    Text("Laporan Kesalahan Rangkaian")
                        .font(.custom("Nunito-Bold", size: 20))
                    
                    Text("Checklist kesalahan sesuai dengan kondisi rangkaian:")
                        .font(.custom("Nunito", size: 18))
                    
                    // Options
                    optionRow(title: "Tegangan", options: ["Terlalu Rendah", "Normal", "Terlalu Tinggi"], selected: $selectedVoltage)
                    optionRow(title: "Polaritas", options: ["Sesuai", "Terbalik"], selected: $selectedPolarity)
                    optionRow(title: "Kapasitansi", options: ["Drop", "Normal"], selected: $selectedCapacitance)
                    
                    Spacer()
                    
                    // Submit Button
                    Button("Kirim Laporan") {
                        print("Tegangan: \(selectedVoltage ?? "-")")
                        print("Polaritas: \(selectedPolarity ?? "-")")
                        print("Kapasitansi: \(selectedCapacitance ?? "-")")
                        onDismiss()
                        print("\(geometry.size.width*0.9)")
                    }
                    .font(.headline)
                    .frame(maxWidth: .infinity)
                    .padding()
                    .background(Color("TapableArea"))
                    .foregroundColor(.black)
                    .cornerRadius(12)
                    .shadow(radius: 4)
                }
                .padding()
                .frame(width: geometry.size.width * 0.37, height: geometry.size.height * 0.7)
                .zIndex(2)
            }
            
            .overlay(alignment: .topLeading) {
                Button(action: {
                    onDismiss()
                }) {
                    Image(systemName: "chevron.left")
                        .font(.system(size: 24, weight: .bold))
                        .foregroundColor(.black)
                        .padding()
                        .background(Circle().fill(Color("TapableArea")))
                }
                .padding()
                .padding(.leading, 24)
                .zIndex(3)
            }
        }
    }
    
    @ViewBuilder
    private func optionRow(title: String, options: [String], selected: Binding<String?>) -> some View {
        VStack(alignment: .leading, spacing: 8) {
            Text(title)
                .font(.headline)
            
            HStack(spacing: 8) {
                ForEach(options.indices, id: \.self) { index in
                    let option = options[index]
                    
                    Button(action: {
                        if selected.wrappedValue == option {
                            selected.wrappedValue = nil // deselect if tapped again
                        } else {
                            selected.wrappedValue = option
                        }
                    }) {
                        Text(option)
                            .padding(.vertical, 12)
                            .padding(.horizontal, 16)
                            .frame(minWidth: 100)
                            .foregroundColor(.black)
                            .background(
                                RoundedRectangle(cornerRadius: 50)
                                    .fill(Color.white.opacity(0.05))
                            )
                            .overlay(
                                RoundedRectangle(cornerRadius: 50)
                                    .stroke(selected.wrappedValue == option ? Color.red : Color.gray.opacity(0.3), lineWidth: 2)
                            )
                    }
                    .cornerRadius(50)
                    .shadow(color: .gray.opacity(0.4), radius: 3, x: 0, y: 2)
                }
            }
        }
    }
}

#Preview {
    ChecklistView{}
}
