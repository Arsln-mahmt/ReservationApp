//
//  ServiceManager.swift
//  ReservationApp
//
//  Created by Mahmut Arslan on 25.10.2025.
//

import Foundation
import FirebaseFirestore
import Combine

class ServiceManager: ObservableObject {
    private lazy var db = Firestore.firestore()
    
    static let shared = ServiceManager()
    
    private init() {}
    
    // MARK: - Get Services for Business
    func getServices(
        businessId: String,
        completion: @escaping (Result<[Service], Error>) -> Void
    ) {
        db.collection(Constant.servicesCollection)
            .whereField("businessId", isEqualTo: businessId)
            .whereField("isActive", isEqualTo: true)
            .getDocuments { snapshot, error in
                
                if let error = error {
                    print("❌ Failed to fetch services: \(error)")
                    completion(.failure(error))
                    return
                }
                
                guard let documents = snapshot?.documents else {
                    completion(.success([]))
                    return
                }
                
                do {
                    let services = try documents.map { doc in
                        try doc.data(as: Service.self)
                    }
                    print("✅ Fetched \(services.count) services for business")
                    completion(.success(services))
                } catch {
                    print("❌ Failed to decode services: \(error)")
                    completion(.failure(error))
                }
            }
    }
    
    // MARK: - Create Service
    func createService(
        businessId: String,
        name: String,
        description: String?,
        duration: Int,
        price: Double,
        completion: @escaping (Result<String, Error>) -> Void
    ) {
        let service = Service(
            id: nil,
            businessId: businessId,
            name: name,
            description: description,
            duration: duration,
            price: price,
            isActive: true,
            createdAt: Timestamp()
        )
        
        do {
            let docRef = try db.collection(Constant.servicesCollection)
                .addDocument(from: service)
            
            print("✅ Service created: \(docRef.documentID)")
            completion(.success(docRef.documentID))
        } catch {
            print("❌ Failed to create service: \(error)")
            completion(.failure(error))
        }
    }
    
    // MARK: - Update Service
    func updateService(
        serviceId: String,
        name: String? = nil,
        description: String? = nil,
        duration: Int? = nil,
        price: Double? = nil,
        isActive: Bool? = nil,
        completion: @escaping (Result<Void, Error>) -> Void
    ) {
        var updateData: [String: Any] = [:]
        
        if let name = name { updateData["name"] = name }
        if let description = description { updateData["description"] = description }
        if let duration = duration { updateData["duration"] = duration }
        if let price = price { updateData["price"] = price }
        if let isActive = isActive { updateData["isActive"] = isActive }
        
        db.collection(Constant.servicesCollection)
            .document(serviceId)
            .updateData(updateData) { error in
                if let error = error {
                    print("❌ Failed to update service: \(error)")
                    completion(.failure(error))
                } else {
                    print("✅ Service updated successfully")
                    completion(.success(()))
                }
            }
    }
    
    // MARK: - Delete Service
    func deleteService(
        serviceId: String,
        completion: @escaping (Result<Void, Error>) -> Void
    ) {
        // Soft delete by setting isActive to false
        updateService(serviceId: serviceId, isActive: false, completion: completion)
    }
}

