//
//  TestDataHelper.swift
//  ReservationApp
//
//  Created by Mahmut Arslan on 25.10.2025.
//

import Foundation
import FirebaseFirestore

/// Helper for adding test data to Firebase
class TestDataHelper {
    static let shared = TestDataHelper()
    private let db = Firestore.firestore()
    
    private init() {}
    
    // MARK: - Add Test Services to Business
    func addTestServicesToBusiness(businessId: String, completion: @escaping (Bool) -> Void) {
        let services = createTestServices(for: businessId)
        
        var successCount = 0
        let totalServices = services.count
        
        for service in services {
            do {
                try db.collection(Constant.servicesCollection)
                    .addDocument(from: service) { error in
                        if let error = error {
                            print("❌ Error adding test service: \(error.localizedDescription)")
                            completion(false)
                        } else {
                            successCount += 1
                            if successCount == totalServices {
                                completion(true)
                            }
                        }
                    }
            } catch {
                completion(false)
            }
        }
    }
    
    // MARK: - Add Test Business Listing
    func addTestBusinessListing(businessId: String, businessName: String, category: String, city: String, address: String, imageURL: String? = nil, completion: @escaping (Bool) -> Void) {
        let listing = BusinessListing(
            id: nil,
            businessId: businessId,
            name: businessName,
            category: category,
            city: city,
            address: address,
            rating: 4.5,
            reviewCount: 50,
            imageURL: imageURL,
            description: "Profesyonel hizmetler sunuyoruz",
            priceRange: "$$",
            isOpen: true,
            distance: 1.5
        )
        
        do {
            try db.collection(Constant.businessesCollection)
                .addDocument(from: listing) { error in
                    completion(error == nil)
                }
        } catch {
            completion(false)
        }
    }
    
    // MARK: - Create Test Services
    private func createTestServices(for businessId: String) -> [Service] {
        return [
            Service(
                id: nil,
                businessId: businessId,
                name: "Saç Kesimi",
                description: "Profesyonel saç kesimi ve şekillendirme hizmeti",
                duration: 30,
                price: 150.0,
                isActive: true,
                createdAt: Timestamp()
            ),
            Service(
                id: nil,
                businessId: businessId,
                name: "Sakal Tıraşı",
                description: "Ustura ile profesyonel sakal tıraşı ve şekillendirme",
                duration: 20,
                price: 75.0,
                isActive: true,
                createdAt: Timestamp()
            ),
            Service(
                id: nil,
                businessId: businessId,
                name: "Komple Bakım",
                description: "Saç kesimi + Sakal tıraşı + Cilt bakımı paketi",
                duration: 60,
                price: 250.0,
                isActive: true,
                createdAt: Timestamp()
            ),
            Service(
                id: nil,
                businessId: businessId,
                name: "Yıkama",
                description: "Profesyonel saç yıkama ve bakım",
                duration: 15,
                price: 50.0,
                isActive: true,
                createdAt: Timestamp()
            ),
            Service(
                id: nil,
                businessId: businessId,
                name: "Boya",
                description: "Profesyonel saç boyama hizmeti",
                duration: 90,
                price: 350.0,
                isActive: true,
                createdAt: Timestamp()
            )
        ]
    }
    
    // MARK: - Setup All Test Data for a Business
    func setupTestDataForBusiness(businessId: String, businessName: String, category: String, city: String, address: String, imageURL: String? = nil, completion: @escaping (Bool) -> Void) {
        // First add business listing
        addTestBusinessListing(businessId: businessId, businessName: businessName, category: category, city: city, address: address, imageURL: imageURL) { [weak self] success in
            if success {
                // Then add services
                self?.addTestServicesToBusiness(businessId: businessId) { servicesSuccess in
                    completion(servicesSuccess)
                }
            } else {
                completion(false)
            }
        }
    }
}

