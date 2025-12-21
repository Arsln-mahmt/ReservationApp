//
//  ClaimManager.swift
//  ReservationApp
//
//  Created by Mahmut Arslan on 21.12.2025.
//

import Foundation
import FirebaseFirestore
import Combine

class ClaimManager: ObservableObject {
    static let shared = ClaimManager()
    private let db = Firestore.firestore()
    private let collection = "claim_requests"
    
    // Published properties if needed later
    @Published var isLoading = false
    
    private init() {}
    
    /// Submit a claim request for a business
    func submitClaimRequest(
        business: BusinessListing,
        requesterName: String,
        requesterPhone: String,
        completion: @escaping (Result<Void, Error>) -> Void
    ) {
        guard let user = AuthManager.shared.currentUser else {
            completion(.failure(NSError(domain: "Auth", code: -1, userInfo: [NSLocalizedDescriptionKey: "Giriş yapmalısınız"])))
            return
        }
        
        let request = ClaimRequest(
            id: nil,
            userId: user.uid,
            userEmail: user.email,
            requesterName: requesterName,
            requesterPhone: requesterPhone,
            businessName: business.name,
            businessAddress: business.address,
            googlePlaceId: business.googlePlaceId ?? "",
            status: .pending,
            requestDate: Timestamp()
        )
        
        do {
            try db.collection(collection).addDocument(from: request) { error in
                if let error = error {
                    completion(.failure(error))
                } else {
                    completion(.success(()))
                }
            }
        } catch {
            completion(.failure(error))
        }
    }
    
    /// Check if user has already claimed this business (pending or approved)
    func checkClaimStatus(googlePlaceId: String, completion: @escaping (Bool) -> Void) {
        // This is a simple check. In a real app, we might want to check per user or globally.
        // For now, let's check if there is ANY pending request for this place to lock it.
        
        db.collection(collection)
            .whereField("googlePlaceId", isEqualTo: googlePlaceId)
            .whereField("status", isEqualTo: ClaimStatus.pending.rawValue)
            .getDocuments { snapshot, error in
                if let snapshot = snapshot, !snapshot.documents.isEmpty {
                    // There is already a pending request
                    completion(true)
                } else {
                    // No pending request
                    completion(false)
                }
            }
    }
}
