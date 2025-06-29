//
//  DialogueViewModel.swift
//  Eudori3
//
//  Created by Djie Valencia Santoso on 27/06/25.
//

import Foundation

class DialogueViewModel: ObservableObject {
    @Published var currentIndex: Int = 0
    
    let slides: [DialogueModel] = [
        DialogueModel(id: 0, text: "Waktunya bekerja. Pelanggan pertama menunggu, dan aku tak boleh mengecewakan."),
        DialogueModel(id: 1, text: "Setiap tugas yang kuselesaikan membawa aku selangkah lebih dekat untuk menyelamatkan kios ini dari utang."),
        DialogueModel(id: 2, text: "Lihat tugas pertama hari ini di papan checklist, ayo kita cek apa yang perlu diperiksa dan diperbaiki sebelum dikirim ke pelanggan!"),
        DialogueModel(id: 3, text: "Kacamata thermal ini milik mendiang Bapak, benda yang selalu menemaninya saat bekerja. Kini, saat aku memakainya, aku bisa melihat suhu dalam bentuk warna."),
        DialogueModel(id: 4, text: "Catatan Bapak tentang kapasitor masih tersimpan di buku catatan ini. Selalu aku buka saat mulai bingung."),
        DialogueModel(id: 5, text: "Nggak ada ruang untuk kesalahan. Kalau aku salah diagnosa, pelanggan bisa minta ganti rugi. Dan kalau sampai tiga kali, reputasi toko bisa memburuk... dan aku nggak bakal punya pelanggan lagi."),
        DialogueModel(id: 6, text: "Akhirnya, dari hasil perbaikan kemarin, aku berhasil menyisihkan sedikit uang. Cukup untuk membeli alat baru, Multimeter. Satu langkah kecil, tapi penting, untuk membantu pekerjaanku lebih akurat."),
        DialogueModel(id: 7, text: "Aku perlu menekan objek multimeter untuk menggunakannya.")
    ]
    
    var endIndex: Int = 0
    var onFinish: (() -> Void)? = nil
    
    func configure(startIndex: Int, endIndex: Int, onFinish: @escaping () -> Void) {
        self.currentIndex = startIndex
        self.endIndex = endIndex
        self.onFinish = onFinish
    }
    
    func nextSlide() {
        if currentIndex < endIndex {
            currentIndex += 1
        } else {
            onFinish?()
        }
    }
    
    var currentSlide: DialogueModel {
        slides[currentIndex]
    }
}
