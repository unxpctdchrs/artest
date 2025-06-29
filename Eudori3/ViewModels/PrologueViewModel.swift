//
//  PrologueViewModel.swift
//  LloydElectrofixJourney
//
//  Created by Djie Valencia Santoso on 23/06/25.
//

import Foundation

class PrologueViewModel: ObservableObject {
    @Published var currentIndex: Int = 0
    
    let slides: [PrologueModel] = [
        PrologueModel(id: 0, imageName: "prolog1", text: "Kios servis elektronik ini adalah peninggalan bapak yang telah tiada.  Dulu, tempat ini ramai dengan pelanggan. Kini hanya aku, kios yang hampir bangkrut, dan semangat yang belum padam."),
        PrologueModel(id: 1, imageName: "prolog2", text: "Untuk menjaga toko ini tetap berdiri, aku terpaksa meminjam uang. Kalau tidak begitu… toko ini akan tutup."),
        PrologueModel(id: 2, imageName: "prolog3", text: "Hari-hari berlalu, dan tenggat membayar hutang itu semakin dekat. Setiap detik terasa seperti hitungan mundur. Kalau aku gagal bayar… toko ini, satu-satunya peninggalan keluarga, bisa hilang selamanya."),
        PrologueModel(id: 3, imageName: "prolog4", text: "Sekarang, tak ada pilihan selain maju. Setiap rangkaian yang kuperiksa, setiap pelanggan yang kulayani, adalah satu langkah menyelamatkan kios ini. Aku harus berusaha… sebelum semuanya terlambat.")
    ]
    
    var isLastSlide: Bool {
        currentIndex == slides.count - 1
    }
    
    func nextSlide() {
        if currentIndex < slides.count - 1 {
            currentIndex += 1
        }
    }
}
