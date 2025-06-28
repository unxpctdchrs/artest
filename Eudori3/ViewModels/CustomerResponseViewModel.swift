//
//  CustomerResponseView.swift
//  Eudori3
//
//  Created by Djie Valencia Santoso on 28/06/25.
//

import Foundation

class CustomerResponseViewModel: ObservableObject {
    enum DiagnosisResult {
        case correct
        case incorrect
    }
    
    @Published var diagnosisResult: DiagnosisResult = .correct
    
    var responseText: String {
        switch diagnosisResult {
        case .correct:
            return "Wah! Emang servis disini paling mantap, cepat, dan akurat! Terima kasih, Lloyd!"
        case .incorrect:
            return "Kurang teliti! Padahal rangkaiannya masih salah kok dikasih lagi ke saya?! Refundddd!!!"
        }
    }
}
