//
//  ClaimRequest.swift
//  ReservationApp
//
//  Created by Mahmut Arslan on 21.12.2025.
//

import Foundation
import FirebaseFirestore

enum ClaimStatus: String, Codable {
    case pending    // Bekliyor
    case approved   // Onaylandı
    case rejected   // Reddedildi
}

struct ClaimRequest: Codable, Identifiable {
    @DocumentID var id: String?
    var userId: String              // Talep eden kullanıcı ID
    var userEmail: String           // Talep eden e-posta
    var requesterName: String       // Ad Soyad
    var requesterPhone: String      // İletişim Numarası
    
    var businessName: String        // İşletme Adı
    var businessAddress: String     // İşletme Adresi
    var googlePlaceId: String       // Google ID'si
    
    var status: ClaimStatus         // Durum
    var requestDate: Timestamp      // Talep Tarihi
    
    // For local use
    var formattedDate: String {
        let formatter = DateFormatter()
        formatter.dateStyle = .medium
        formatter.timeStyle = .short
        formatter.locale = Locale(identifier: "tr_TR")
        return formatter.string(from: requestDate.dateValue())
    }
}
