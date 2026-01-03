//
//  BusinessNotificationManager.swift
//  ReservationApp
//
//  Created by Mahmut Arslan on 23.12.2025.
//

import Foundation
import FirebaseFirestore
import Combine

/// Manager class for business notifications
class BusinessNotificationManager: ObservableObject {
    static let shared = BusinessNotificationManager()
    
    @Published var notifications: [BusinessNotification] = []
    @Published var unreadCount: Int = 0
    @Published var isLoading: Bool = false
    
    private lazy var db = Firestore.firestore()
    private var listener: ListenerRegistration?
    private let notificationsCollection = "business_notifications"
    
    private init() {}
    
    // MARK: - Start Listening for Notifications
    func startListening(businessId: String) {
        // Remove existing listener
        stopListening()
        
        print("🔔 Starting notification listener for business: \(businessId)")
        
        listener = db.collection(notificationsCollection)
            .whereField("business_id", isEqualTo: businessId)
            .order(by: "created_at", descending: true)
            .limit(to: 50)
            .addSnapshotListener { [weak self] snapshot, error in
                guard let self = self else { return }
                
                if let error = error {
                    print("❌ Notification listener error: \(error.localizedDescription)")
                    return
                }
                
                guard let documents = snapshot?.documents else {
                    print("⚠️ No notification documents")
                    return
                }
                
                var fetchedNotifications: [BusinessNotification] = []
                
                for doc in documents {
                    do {
                        let notification = try doc.data(as: BusinessNotification.self)
                        fetchedNotifications.append(notification)
                    } catch {
                        print("⚠️ Failed to parse notification: \(error)")
                    }
                }
                
                DispatchQueue.main.async {
                    self.notifications = fetchedNotifications
                    self.unreadCount = fetchedNotifications.filter { !$0.isRead }.count
                    print("✅ Fetched \(fetchedNotifications.count) notifications, \(self.unreadCount) unread")
                }
            }
    }
    
    // MARK: - Stop Listening
    func stopListening() {
        listener?.remove()
        listener = nil
    }
    
    // MARK: - Create Notification for New Reservation
    func createNewReservationNotification(
        businessId: String,
        reservationId: String,
        customerName: String,
        serviceName: String,
        appointmentDate: String,
        appointmentTime: String,
        completion: ((Result<String, Error>) -> Void)? = nil
    ) {
        let notification = BusinessNotification(
            businessId: businessId,
            type: .newReservation,
            title: "Yeni Randevu Alındı! 🎉",
            message: "\(customerName), \(serviceName) için \(appointmentDate) tarihinde saat \(appointmentTime)'de randevu aldı.",
            reservationId: reservationId,
            customerName: customerName,
            serviceName: serviceName,
            appointmentDate: appointmentDate,
            appointmentTime: appointmentTime,
            isRead: false,
            createdAt: Timestamp()
        )
        
        saveNotification(notification, completion: completion)
    }
    
    // MARK: - Create Notification for Cancelled Reservation
    func createCancelledReservationNotification(
        businessId: String,
        reservationId: String,
        customerName: String,
        serviceName: String,
        appointmentDate: String,
        appointmentTime: String,
        wasWithin10Minutes: Bool = false,
        completion: ((Result<String, Error>) -> Void)? = nil
    ) {
        let message: String
        if wasWithin10Minutes {
            message = "\(customerName), az önce aldığı \(serviceName) randevusunu (\(appointmentDate) - \(appointmentTime)) iptal etti. (Randevu alındıktan 10 dakika içinde iptal edildi)"
        } else {
            message = "\(customerName), \(appointmentDate) tarihli saat \(appointmentTime)'deki \(serviceName) randevusunu iptal etti."
        }
        
        let notification = BusinessNotification(
            businessId: businessId,
            type: .cancelledReservation,
            title: "Randevu İptal Edildi ❌",
            message: message,
            reservationId: reservationId,
            customerName: customerName,
            serviceName: serviceName,
            appointmentDate: appointmentDate,
            appointmentTime: appointmentTime,
            isRead: false,
            createdAt: Timestamp()
        )
        
        saveNotification(notification, completion: completion)
    }
    
    // MARK: - Save Notification
    private func saveNotification(_ notification: BusinessNotification, completion: ((Result<String, Error>) -> Void)? = nil) {
        do {
            let docRef = try db.collection(notificationsCollection).addDocument(from: notification)
            print("✅ Notification created: \(docRef.documentID)")
            completion?(.success(docRef.documentID))
        } catch {
            print("❌ Failed to create notification: \(error)")
            completion?(.failure(error))
        }
    }
    
    // MARK: - Mark Notification as Read
    func markAsRead(notificationId: String) {
        db.collection(notificationsCollection)
            .document(notificationId)
            .updateData(["is_read": true]) { error in
                if let error = error {
                    print("❌ Failed to mark notification as read: \(error)")
                } else {
                    print("✅ Notification marked as read")
                }
            }
    }
    
    // MARK: - Mark All as Read
    func markAllAsRead(businessId: String) {
        db.collection(notificationsCollection)
            .whereField("business_id", isEqualTo: businessId)
            .whereField("is_read", isEqualTo: false)
            .getDocuments { [weak self] snapshot, error in
                guard let documents = snapshot?.documents else { return }
                
                let batch = self?.db.batch()
                
                for doc in documents {
                    batch?.updateData(["is_read": true], forDocument: doc.reference)
                }
                
                batch?.commit { error in
                    if let error = error {
                        print("❌ Failed to mark all as read: \(error)")
                    } else {
                        print("✅ All notifications marked as read")
                    }
                }
            }
    }
    
    // MARK: - Delete Old Notifications (cleanup)
    func deleteOldNotifications(businessId: String, daysOld: Int = 30) {
        let cutoffDate = Calendar.current.date(byAdding: .day, value: -daysOld, to: Date()) ?? Date()
        let cutoffTimestamp = Timestamp(date: cutoffDate)
        
        db.collection(notificationsCollection)
            .whereField("business_id", isEqualTo: businessId)
            .whereField("created_at", isLessThan: cutoffTimestamp)
            .getDocuments { [weak self] snapshot, error in
                guard let documents = snapshot?.documents else { return }
                
                let batch = self?.db.batch()
                
                for doc in documents {
                    batch?.deleteDocument(doc.reference)
                }
                
                batch?.commit { error in
                    if let error = error {
                        print("❌ Failed to delete old notifications: \(error)")
                    } else {
                        print("✅ Deleted \(documents.count) old notifications")
                    }
                }
            }
    }
    
    // MARK: - Get Unread Count (one-time fetch)
    func fetchUnreadCount(businessId: String, completion: @escaping (Int) -> Void) {
        db.collection(notificationsCollection)
            .whereField("business_id", isEqualTo: businessId)
            .whereField("is_read", isEqualTo: false)
            .getDocuments { snapshot, error in
                let count = snapshot?.documents.count ?? 0
                DispatchQueue.main.async {
                    self.unreadCount = count
                    completion(count)
                }
            }
    }
}
