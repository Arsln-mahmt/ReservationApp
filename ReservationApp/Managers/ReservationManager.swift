//
//  ReservationManager.swift
//  ReservationApp
//
//  Created by Mahmut Arslan on 25.10.2025.
//

import Foundation
import FirebaseFirestore
import Combine

class ReservationManager: ObservableObject {
    private lazy var db = Firestore.firestore()
    
    static let shared = ReservationManager()
    
    private init() {}
    
    // MARK: - Create Reservation
    func createReservation(
        customerId: String,
        customerName: String,
        customerPhone: String?,
        businessId: String,
        businessName: String,
        serviceType: String,
        date: Date,
        timeSlot: String,
        duration: Int,
        notes: String? = nil,
        completion: @escaping (Result<String, Error>) -> Void
    ) {
        print("\n" + String(repeating: "💾", count: 25))
        print("📝 FIREBASE CREATE RESERVATION - START")
        print(String(repeating: "💾", count: 25))
        print("Collection: \(Constant.reservationsCollection)")
        print("Customer ID: \(customerId)")
        print("Customer Name: \(customerName)")
        print("Business ID: \(businessId)")
        print("Business Name: \(businessName)")
        print("Service: \(serviceType)")
        print("Date: \(date)")
        print("Time Slot: \(timeSlot)")
        print("Duration: \(duration) min")
        print(String(repeating: "💾", count: 25) + "\n")
        
        let reservation = Reservation(
            id: nil,
            customerId: customerId,
            customerName: customerName,
            customerPhone: customerPhone,
            businessId: businessId,
            businessName: businessName,
            serviceType: serviceType,
            date: Timestamp(date: date),
            timeSlot: timeSlot,
            duration: duration,
            status: .pending,
            notes: notes,
            createdAt: Timestamp(),
            updatedAt: nil,
            aiRecommended: false
        )
        
        print("🔐 Attempting to write to Firestore...")
        
        do {
            let docRef = try db.collection(Constant.reservationsCollection)
                .addDocument(from: reservation)
            
            print("\n" + String(repeating: "✅", count: 25))
            print("💚 FIREBASE WRITE SUCCESS!")
            print("   Document ID: \(docRef.documentID)")
            print("   Collection: \(Constant.reservationsCollection)")
            print("   Customer ID: \(customerId)")
            print(String(repeating: "✅", count: 25) + "\n")
            
            // 🔔 Send notification to business
            print("🔔 SENDING NOTIFICATION TO BUSINESS...")
            print("   Business ID: \(businessId)")
            print("   Customer Name: \(customerName)")
            print("   Service: \(serviceType)")
            
            let dateFormatter = DateFormatter()
            dateFormatter.dateFormat = "dd MMM yyyy"
            dateFormatter.locale = Locale(identifier: "tr_TR")
            let dateString = dateFormatter.string(from: date)
            
            print("   Date String: \(dateString)")
            print("   Time Slot: \(timeSlot)")
            
            BusinessNotificationManager.shared.createNewReservationNotification(
                businessId: businessId,
                reservationId: docRef.documentID,
                customerName: customerName,
                serviceName: serviceType,
                appointmentDate: dateString,
                appointmentTime: timeSlot
            ) { result in
                switch result {
                case .success(let notificationId):
                    print("✅ NOTIFICATION CREATED SUCCESSFULLY!")
                    print("   Notification ID: \(notificationId)")
                case .failure(let error):
                    print("❌ NOTIFICATION CREATION FAILED!")
                    print("   Error: \(error.localizedDescription)")
                }
            }
            
            completion(.success(docRef.documentID))
        } catch {
            print("\n" + String(repeating: "❌", count: 25))
            print("🔥 FIREBASE WRITE FAILED!")
            print("   Error: \(error.localizedDescription)")
            print("   Full error: \(error)")
            print("   Collection: \(Constant.reservationsCollection)")
            print(String(repeating: "❌", count: 25) + "\n")
            
            completion(.failure(error))
        }
    }
    
    // MARK: - Get Customer Reservations
    func getCustomerReservations(
        customerId: String,
        completion: @escaping (Result<[Reservation], Error>) -> Void
    ) {
        print("\n" + String(repeating: "🔍", count: 25))
        print("📖 FIREBASE READ RESERVATIONS - START")
        print(String(repeating: "🔍", count: 25))
        print("Collection: \(Constant.reservationsCollection)")
        print("Query: user_id == \(customerId)")
        print("Sorting: Client-side (date descending)")
        print(String(repeating: "🔍", count: 25) + "\n")
        
        // Try to get from cache first, then server
        db.collection(Constant.reservationsCollection)
            .whereField("user_id", isEqualTo: customerId)
            .getDocuments(source: .default) { [weak self] snapshot, error in
                
                if let error = error {
                    print("⚠️ Default source failed, trying cache only...")
                    // If default fails, try cache
                    self?.db.collection(Constant.reservationsCollection)
                        .whereField("user_id", isEqualTo: customerId)
                        .getDocuments(source: .cache) { cacheSnapshot, cacheError in
                            if let cacheError = cacheError {
                                print("❌ Cache also failed: \(cacheError)")
                                completion(.failure(error))
                            } else if let docs = cacheSnapshot?.documents, !docs.isEmpty {
                                print("✅ Got \(docs.count) documents from cache")
                                self?.parseReservations(documents: docs, customerId: customerId, completion: completion)
                            } else {
                                print("⚠️ Cache is empty, returning error")
                                completion(.failure(error))
                            }
                        }
                    return
                }
                
                guard let documents = snapshot?.documents else {
                    print("\n⚠️ No snapshot documents (nil)")
                    print("   This means the query returned but has no results\n")
                    completion(.success([]))
                    return
                }
                
                self?.parseReservations(documents: documents, customerId: customerId, completion: completion)
            }
    }
    
    private func parseReservations(documents: [QueryDocumentSnapshot], customerId: String, completion: @escaping (Result<[Reservation], Error>) -> Void) {
        print("\n" + String(repeating: "📄", count: 25))
        print("📦 FIREBASE READ RESULT")
        print("   Found \(documents.count) documents")
        
        if documents.isEmpty {
            print("   ⚠️ Documents array is EMPTY!")
            print("   This means NO reservations found for customer: \(customerId)")
            print(String(repeating: "📄", count: 25) + "\n")
            completion(.success([]))
            return
        }
        
        print("   Document IDs:")
        documents.forEach { doc in
            print("      - \(doc.documentID)")
            print("        Data: \(doc.data())")
        }
        print(String(repeating: "📄", count: 25) + "\n")
        
        // Parse each document individually to find which one fails
        var reservations: [Reservation] = []
        var failedDocuments: [(String, String)] = []
        
        for doc in documents {
            do {
                var reservation = try doc.data(as: Reservation.self)
                // Manually set the document ID since custom decoder doesn't handle @DocumentID
                reservation.id = doc.documentID
                reservations.append(reservation)
                print("✅ Successfully decoded: \(doc.documentID)")
            } catch {
                print("❌ Failed to decode \(doc.documentID): \(error)")
                print("   Document data: \(doc.data())")
                failedDocuments.append((doc.documentID, error.localizedDescription))
            }
        }
        
        if !failedDocuments.isEmpty {
            print("\n⚠️ \(failedDocuments.count) documents failed to decode:")
            failedDocuments.forEach { id, error in
                print("   - \(id): \(error)")
            }
        }
        
        // If we got some reservations, return them (ignore failed ones)
        if !reservations.isEmpty {
            // Get current date for comparison
            let now = Date()
            
            // Sort by appointment date+time (nearest first), with active reservations before past ones
            let sortedReservations = reservations.sorted { res1, res2 in
                // Parse full datetime for each reservation
                func getFullDateTime(_ res: Reservation) -> Date {
                    let baseDate = res.date.dateValue()
                    let timeComponents = res.timeSlot.split(separator: ":").compactMap { Int($0) }
                    guard timeComponents.count >= 2 else { return baseDate }
                    
                    var calendar = Calendar.current
                    calendar.timeZone = TimeZone.current
                    var components = calendar.dateComponents([.year, .month, .day], from: baseDate)
                    components.hour = timeComponents[0]
                    components.minute = timeComponents[1]
                    
                    return calendar.date(from: components) ?? baseDate
                }
                
                let dateTime1 = getFullDateTime(res1)
                let dateTime2 = getFullDateTime(res2)
                
                // Check if reservations are in the future or past
                let isFuture1 = dateTime1 > now
                let isFuture2 = dateTime2 > now
                
                // Future reservations come before past reservations
                if isFuture1 != isFuture2 {
                    return isFuture1
                }
                
                // Both future: nearest first (ascending)
                // Both past: most recent first (descending)
                if isFuture1 {
                    return dateTime1 < dateTime2  // Nearest future first
                } else {
                    return dateTime1 > dateTime2  // Most recent past first
                }
            }
            
            print("\n" + String(repeating: "✅", count: 25))
            print("💚 SUCCESSFULLY DECODED \(sortedReservations.count) RESERVATIONS!")
            print("📋 Sort logic: Nearest appointment first (future before past)")
            print("")
            sortedReservations.prefix(5).enumerated().forEach { index, reservation in
                var statusIcon: String
                switch reservation.status {
                case .pending: statusIcon = "⏳"
                case .confirmed: statusIcon = "✅"
                case .completed: statusIcon = "✔️"
                case .noShow: statusIcon = "👻"
                case .cancelled: statusIcon = "❌"
                case .blocked: statusIcon = "⛔"
                }
                print("   \(index + 1). \(statusIcon) \(reservation.displayBusinessName): \(reservation.serviceType)")
                print("      Created: \(reservation.createdAt.dateValue()) | Appt: \(reservation.date.dateValue()) \(reservation.timeSlot)")
            }
            if sortedReservations.count > 5 {
                print("   ... and \(sortedReservations.count - 5) more")
            }
            print(String(repeating: "✅", count: 25) + "\n")
            
            completion(.success(sortedReservations))
        } else {
            // All documents failed
            let error = NSError(domain: "ReservationManager", code: -1, userInfo: [NSLocalizedDescriptionKey: "Failed to decode any reservations"])
            completion(.failure(error))
        }
    }
    
    // MARK: - Get Business Reservations
    func getBusinessReservations(
        businessId: String,
        completion: @escaping (Result<[Reservation], Error>) -> Void
    ) {
        db.collection(Constant.reservationsCollection)
            .whereField("business_id", isEqualTo: businessId)
            .getDocuments { snapshot, error in
                
                print("\n" + String(repeating: "🏢", count: 25))
                print("FETCHING BUSINESS RESERVATIONS")
                print("Business ID: \(businessId)")
                
                if let error = error {
                    print("❌ Failed to fetch business reservations: \(error)")
                    completion(.failure(error))
                    return
                }
                
                guard let documents = snapshot?.documents else {
                    print("⚠️ No documents found for business")
                    completion(.success([]))
                    return
                }
                
                print("📄 Found \(documents.count) documents")
                
                // Parse each document individually
                var reservations: [Reservation] = []
                
                for doc in documents {
                    do {
                        var reservation = try doc.data(as: Reservation.self)
                        // Manually set the document ID since custom decoder doesn't handle @DocumentID
                        reservation.id = doc.documentID
                        reservations.append(reservation)
                        print("   ✅ Doc ID: \(doc.documentID) - parsed successfully")
                    } catch {
                        print("   ❌ Doc ID: \(doc.documentID) - failed: \(error.localizedDescription)")
                    }
                }
                
                // Sort by date (ascending) on client side
                let sortedReservations = reservations.sorted { $0.date.dateValue() < $1.date.dateValue() }
                print("✅ Fetched \(sortedReservations.count) reservations for business")
                print(String(repeating: "🏢", count: 25) + "\n")
                completion(.success(sortedReservations))
            }
    }
    
    // MARK: - Update Reservation Status
    func updateReservationStatus(
        reservationId: String,
        status: ReservationStatus,
        completion: @escaping (Result<Void, Error>) -> Void
    ) {
        db.collection(Constant.reservationsCollection)
            .document(reservationId)
            .updateData([
                "status": status.rawValue,
                "updatedAt": Timestamp()
            ]) { error in
                if let error = error {
                    print("❌ Failed to update reservation status: \(error)")
                    completion(.failure(error))
                } else {
                    print("✅ Reservation status updated to: \(status.displayName)")
                    completion(.success(()))
                }
            }
    }
    
    // MARK: - Cancel Reservation
    func cancelReservation(
        reservationId: String,
        completion: @escaping (Result<Void, Error>) -> Void
    ) {
        // First, fetch the reservation to get details for notification
        db.collection(Constant.reservationsCollection)
            .document(reservationId)
            .getDocument { [weak self] snapshot, error in
                guard let self = self else { return }
                
                if let error = error {
                    print("❌ Failed to fetch reservation for cancellation: \(error)")
                    completion(.failure(error))
                    return
                }
                
                guard let data = snapshot?.data() else {
                    print("⚠️ No reservation data found for cancellation")
                    self.updateReservationStatus(reservationId: reservationId, status: .cancelled, completion: completion)
                    return
                }
                
                // Extract reservation details
                let businessId = data["business_id"] as? String ?? ""
                let customerName = data["user_name"] as? String ?? "Müşteri"
                let serviceName = data["service_name"] as? String ?? "Hizmet"
                let timeSlot = data["time"] as? String ?? ""
                
                // Check if cancelled within 10 minutes of creation
                var wasWithin10Minutes = false
                if let createdAt = data["created_at"] as? Timestamp {
                    let createdDate = createdAt.dateValue()
                    let now = Date()
                    let interval = now.timeIntervalSince(createdDate)
                    wasWithin10Minutes = interval < 600 // 10 minutes = 600 seconds
                }
                
                // Format date for notification
                var dateString = ""
                if let dateTimestamp = data["date"] as? Timestamp {
                    let dateFormatter = DateFormatter()
                    dateFormatter.dateFormat = "dd MMM yyyy"
                    dateFormatter.locale = Locale(identifier: "tr_TR")
                    dateString = dateFormatter.string(from: dateTimestamp.dateValue())
                }
                
                // Update the reservation status
                self.updateReservationStatus(reservationId: reservationId, status: .cancelled) { result in
                    switch result {
                    case .success:
                        // 🔔 Send cancellation notification to business
                        if !businessId.isEmpty {
                            BusinessNotificationManager.shared.createCancelledReservationNotification(
                                businessId: businessId,
                                reservationId: reservationId,
                                customerName: customerName,
                                serviceName: serviceName,
                                appointmentDate: dateString,
                                appointmentTime: timeSlot,
                                wasWithin10Minutes: wasWithin10Minutes
                            )
                        }
                        completion(.success(()))
                        
                    case .failure(let error):
                        completion(.failure(error))
                    }
                }
            }
    }
    
    // MARK: - Confirm Reservation (Business)
    func confirmReservation(
        reservationId: String,
        completion: @escaping (Result<Void, Error>) -> Void
    ) {
        updateReservationStatus(reservationId: reservationId, status: .confirmed, completion: completion)
    }
    
    // MARK: - Reject Reservation (Business)
    func rejectReservation(
        reservationId: String,
        rejectionReason: String? = nil,
        completion: @escaping (Result<Void, Error>) -> Void
    ) {
        var updateData: [String: Any] = [
            "status": ReservationStatus.cancelled.rawValue,
            "updatedAt": Timestamp()
        ]
        
        if let reason = rejectionReason {
            updateData["notes"] = reason
        }
        
        db.collection(Constant.reservationsCollection)
            .document(reservationId)
            .updateData(updateData) { error in
                if let error = error {
                    completion(.failure(error))
                } else {
                    completion(.success(()))
                }
            }
    }
    
    // MARK: - Propose New Time (Business)
    func proposeNewTime(
        reservationId: String,
        proposedDate: Date,
        proposedTimeSlot: String,
        completion: @escaping (Result<Void, Error>) -> Void
    ) {
        // Use snake_case field names to match CodingKeys
        let updateData: [String: Any] = [
            "proposed_date": Timestamp(date: proposedDate),
            "proposed_time_slot": proposedTimeSlot,
            "status": ReservationStatus.pending.rawValue,
            "updated_at": Timestamp()
        ]
        
        print("🕐 Saving proposed time to Firebase:")
        print("   proposed_date: \(proposedDate)")
        print("   proposed_time_slot: \(proposedTimeSlot)")
        
        db.collection(Constant.reservationsCollection)
            .document(reservationId)
            .updateData(updateData) { error in
                if let error = error {
                    completion(.failure(error))
                } else {
                    completion(.success(()))
                }
            }
    }
    
    // MARK: - Accept Proposed Time (Customer)
    func acceptProposedTime(
        reservationId: String,
        newDate: Date,
        newTimeSlot: String,
        completion: @escaping (Result<Void, Error>) -> Void
    ) {
        // Use snake_case field names to match CodingKeys
        let updateData: [String: Any] = [
            "date": Timestamp(date: newDate),
            "time": newTimeSlot,
            "proposed_date": FieldValue.delete(),
            "proposed_time_slot": FieldValue.delete(),
            "status": ReservationStatus.confirmed.rawValue,
            "updated_at": Timestamp()
        ]
        
        print("✅ Accepting proposed time:")
        print("   New date: \(newDate)")
        print("   New time: \(newTimeSlot)")
        
        db.collection(Constant.reservationsCollection)
            .document(reservationId)
            .updateData(updateData) { error in
                if let error = error {
                    completion(.failure(error))
                } else {
                    completion(.success(()))
                }
            }
    }
    
    // MARK: - Reject Proposed Time (Customer)
    func rejectProposedTime(
        reservationId: String,
        completion: @escaping (Result<Void, Error>) -> Void
    ) {
        // Use snake_case field names to match CodingKeys
        let updateData: [String: Any] = [
            "proposed_date": FieldValue.delete(),
            "proposed_time_slot": FieldValue.delete(),
            "status": ReservationStatus.cancelled.rawValue,
            "updated_at": Timestamp()
        ]
        
        print("❌ Rejecting proposed time - cancelling reservation")
        
        db.collection(Constant.reservationsCollection)
            .document(reservationId)
            .updateData(updateData) { error in
                if let error = error {
                    completion(.failure(error))
                } else {
                    completion(.success(()))
                }
            }
    }
    
    // MARK: - Get Available Time Slots
    func getAvailableTimeSlots(
        businessId: String,
        date: Date,
        duration: Int,
        completion: @escaping (Result<[String], Error>) -> Void
    ) {
        print("🕒 Getting available time slots for businessId: \(businessId)")
        print("📅 Date: \(date)")
        
        // Generate all possible slots FIRST
        let allSlots = Util.generateTimeSlots(
            startHour: 9,
            endHour: 22,
            interval: 30
        )
        
        if allSlots.isEmpty {
            completion(.failure(NSError(domain: "ReservationManager", code: -1, userInfo: [NSLocalizedDescriptionKey: "Could not generate time slots"])))
            return
        }
        
        let startOfDay = Calendar.current.startOfDay(for: date)
        let endOfDay = Calendar.current.date(byAdding: .day, value: 1, to: startOfDay)!
        
        // Use DispatchGroup to fetch both reservations and blocked slots
        let group = DispatchGroup()
        var bookedSlots: [String] = []
        var blockedSlots: [String] = []
        
        // 1. Fetch reservations
        group.enter()
        db.collection(Constant.reservationsCollection)
            .whereField("business_id", isEqualTo: businessId)
            .whereField("date", isGreaterThanOrEqualTo: Timestamp(date: startOfDay))
            .whereField("date", isLessThan: Timestamp(date: endOfDay))
            .getDocuments { snapshot, error in
                if let docs = snapshot?.documents {
                    bookedSlots = docs.compactMap { doc -> String? in
                        let data = doc.data()
                        let statusStr = data["status"] as? String
                        let timeSlot = data["time"] as? String
                        
                        // Skip cancelled
                        if statusStr == "cancelled" { return nil }
                        return timeSlot
                    }
                }
                print("📋 Found \(bookedSlots.count) booked slots from reservations")
                group.leave()
            }
        
        // 2. Fetch blocked slots
        group.enter()
        db.collection("blocked_slots")
            .whereField("business_id", isEqualTo: businessId)
            .whereField("date", isGreaterThanOrEqualTo: Timestamp(date: startOfDay))
            .whereField("date", isLessThan: Timestamp(date: endOfDay))
            .getDocuments { snapshot, error in
                if let docs = snapshot?.documents {
                    blockedSlots = docs.compactMap { doc -> String? in
                        return doc.data()["time"] as? String
                    }
                }
                print("🔒 Found \(blockedSlots.count) blocked slots")
                group.leave()
            }
        
        // 3. Combine and filter
        group.notify(queue: .main) {
            let unavailableSlots = Set(bookedSlots + blockedSlots)
            let availableSlots = allSlots.filter { !unavailableSlots.contains($0) }
            
            print("✅ Available slots: \(availableSlots.count)")
            print("📝 Unavailable: \(unavailableSlots)")
            
            completion(.success(availableSlots))
        }
    }
}
