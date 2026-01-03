//
//  BusinessDetailViewModel.swift
//  ReservationApp
//
//  Created by Mahmut Arslan on 25.10.2025.
//

import Foundation
import Combine
import FirebaseCore

class BusinessDetailViewModel: ObservableObject {
    let business: BusinessListing
    @Published var services: [Service] = []
    @Published var selectedService: Service?
    @Published var isLoading = false
    
    private let serviceManager = ServiceManager.shared
    
    init(business: BusinessListing) {
        self.business = business
        print("🏢 BusinessDetailViewModel initialized for: \(business.name)")
        print("📍 Business ID: \(business.businessId)")
        loadServices()
    }
    
    func loadServices() {
        print("🔄 Loading services for business: \(business.name)")
        isLoading = true
        
        serviceManager.getServices(businessId: business.businessId) { [weak self] result in
            DispatchQueue.main.async {
                self?.isLoading = false
                
                switch result {
                case .success(let services):
                    if services.isEmpty {
                        print("⚠️ No services found in Firebase, using test data")
                        self?.loadTestData()
                    } else {
                        self?.services = services
                        print("✅ Loaded \(services.count) services from Firebase")
                        services.forEach { service in
                            print("   - \(service.name): ₺\(service.price)")
                        }
                    }
                    
                case .failure(let error):
                    print("❌ Failed to load services: \(error.localizedDescription)")
                    // Use test data as fallback
                    self?.loadTestData()
                }
            }
        }
    }
    
    private func loadTestData() {
        print("📝 Loading test data for business: \(business.businessId)")
        // Fallback test data
        services = [
            Service(
                id: "1",
                businessId: business.businessId,
                name: "Saç Kesimi",
                description: "Profesyonel saç kesimi hizmeti",
                duration: 30,
                price: 150.0,
                isActive: true,
                createdAt: .init()
            ),
            Service(
                id: "2",
                businessId: business.businessId,
                name: "Sakal Tıraşı",
                description: "Ustura ile profesyonel sakal tıraşı",
                duration: 20,
                price: 75.0,
                isActive: true,
                createdAt: .init()
            ),
            Service(
                id: "3",
                businessId: business.businessId,
                name: "Komple Bakım",
                description: "Saç kesimi + Sakal tıraşı + Cilt bakımı",
                duration: 60,
                price: 250.0,
                isActive: true,
                createdAt: .init()
            )
        ]
        print("✅ Loaded \(services.count) test services")
    }
}



