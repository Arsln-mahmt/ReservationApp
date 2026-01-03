//
//  BlockedSlotManager.swift
//  ReservationApp
//
//  Manages blocked time slots for businesses
//

import Foundation
import FirebaseFirestore

class BlockedSlotManager {
    static let shared = BlockedSlotManager()
    private let db = Firestore.firestore()
    private let collectionName = "blocked_slots"
    
    private init() {}
    
    // MARK: - Block a slot
    func blockSlot(
        businessId: String,
        date: Date,
        time: String,
        completion: @escaping (Result<String, Error>) -> Void
    ) {
        let startOfDay = Calendar.current.startOfDay(for: date)
        
        let data: [String: Any] = [
            "business_id": businessId,
            "date": Timestamp(date: startOfDay),
            "time": time,
            "created_at": Timestamp()
        ]
        
        print("🔒 Blocking slot: \(time) on \(startOfDay) for business \(businessId)")
        
        db.collection(collectionName).addDocument(data: data) { error in
            if let error = error {
                print("❌ Failed to block slot: \(error)")
                completion(.failure(error))
            } else {
                print("✅ Slot blocked successfully")
                completion(.success("Blocked"))
            }
        }
    }
    
    // MARK: - Unblock a slot
    func unblockSlot(
        documentId: String,
        completion: @escaping (Result<Void, Error>) -> Void
    ) {
        print("🔓 Unblocking slot with ID: \(documentId)")
        
        db.collection(collectionName).document(documentId).delete { error in
            if let error = error {
                print("❌ Failed to unblock slot: \(error)")
                completion(.failure(error))
            } else {
                print("✅ Slot unblocked successfully")
                completion(.success(()))
            }
        }
    }
    
    // MARK: - Get blocked slots for a date
    func getBlockedSlots(
        businessId: String,
        date: Date,
        completion: @escaping (Result<[BlockedSlot], Error>) -> Void
    ) {
        let startOfDay = Calendar.current.startOfDay(for: date)
        let endOfDay = Calendar.current.date(byAdding: .day, value: 1, to: startOfDay)!
        
        print("🔍 Fetching blocked slots for \(businessId) on \(startOfDay)")
        
        db.collection(collectionName)
            .whereField("business_id", isEqualTo: businessId)
            .whereField("date", isGreaterThanOrEqualTo: Timestamp(date: startOfDay))
            .whereField("date", isLessThan: Timestamp(date: endOfDay))
            .getDocuments { snapshot, error in
                if let error = error {
                    print("❌ Error fetching blocked slots: \(error)")
                    completion(.failure(error))
                    return
                }
                
                let slots = snapshot?.documents.compactMap { doc -> BlockedSlot? in
                    let data = doc.data()
                    guard let time = data["time"] as? String else { return nil }
                    return BlockedSlot(id: doc.documentID, time: time)
                } ?? []
                
                print("✅ Found \(slots.count) blocked slots: \(slots.map { $0.time })")
                completion(.success(slots))
            }
    }
}

// MARK: - Model
struct BlockedSlot: Identifiable {
    let id: String
    let time: String
}
