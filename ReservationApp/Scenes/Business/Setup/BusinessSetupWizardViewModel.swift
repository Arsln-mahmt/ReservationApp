//
//  BusinessSetupWizardViewModel.swift
//  ReservationApp
//
//  İşletme kurulum viewmodel
//

import SwiftUI
import FirebaseFirestore
import FirebaseStorage
import Combine

struct ServiceSetupItem: Identifiable {
    let id = UUID()
    var firestoreId: String? // Firestore document ID for existing services
    var name: String
    var description: String
    var duration: Int
    var price: Double
}

struct WorkingHoursItem {
    var isOpen: Bool
    var openTime: String
    var closeTime: String
}

class BusinessSetupWizardViewModel: ObservableObject {
    let user: User
    
    @Published var currentStep = 0
    @Published var businessImage: UIImage?
    @Published var existingImageURL: String? // URL of existing business image
    @Published var shouldDeleteImage = false // Flag to delete existing image
    @Published var services: [ServiceSetupItem] = []
    @Published var deletedServiceIds: Set<String> = [] // Track deleted service IDs
    @Published var workingHours: [String: WorkingHoursItem] = [:]
    @Published var isExistingBusiness = false // Track if business already exists
    
    @Published var isPublishing = false
    @Published var showExitAlert = false
    @Published var showError = false
    @Published var errorMessage = ""
    
    let weekDays = ["Pazartesi", "Salı", "Çarşamba", "Perşembe", "Cuma", "Cumartesi", "Pazar"]
    
    private let firebaseManager = FirebaseManager.shared
    private let db = Firestore.firestore()
    
    init(user: User) {
        self.user = user
        setupDefaultWorkingHours()
        loadExistingData()
    }
    
    private func loadExistingData() {
        // Load existing business listing
        db.collection(Constant.businessesCollection)
            .whereField("businessId", isEqualTo: user.uid)
            .getDocuments { [weak self] snapshot, error in
                guard let self = self else { return }
                
                DispatchQueue.main.async {
                    if let doc = snapshot?.documents.first {
                        self.isExistingBusiness = true
                        
                        // Load existing image URL
                        if let imageURL = doc.data()["imageURL"] as? String {
                            self.existingImageURL = imageURL
                            print("✅ Found existing image URL: \(imageURL)")
                            
                            // Download and display existing image
                            self.downloadImage(from: imageURL)
                        }
                        
                        print("✅ Found existing business listing (ID: \(doc.documentID))")
                    } else {
                        self.isExistingBusiness = false
                        print("ℹ️ No existing business listing found")
                    }
                }
            }
        
        // Load existing services with their Firestore IDs
        db.collection(Constant.servicesCollection)
            .whereField("businessId", isEqualTo: user.uid)
            .getDocuments { [weak self] snapshot, error in
                guard let self = self, let docs = snapshot?.documents else { return }
                
                DispatchQueue.main.async {
                    self.services = docs.compactMap { doc -> ServiceSetupItem? in
                        let data = doc.data()
                        
                        // Skip deleted services
                        if self.deletedServiceIds.contains(doc.documentID) {
                            return nil
                        }
                        
                        guard let name = data["name"] as? String,
                              let description = data["description"] as? String,
                              let duration = data["duration"] as? Int,
                              let price = data["price"] as? Double else {
                            return nil
                        }
                        return ServiceSetupItem(
                            firestoreId: doc.documentID, // Store Firestore ID
                            name: name,
                            description: description,
                            duration: duration,
                            price: price
                        )
                    }
                    
                    if !self.services.isEmpty {
                        print("✅ Loaded \(self.services.count) existing services with IDs")
                    }
                }
            }
    }
    
    private func downloadImage(from urlString: String) {
        guard let url = URL(string: urlString) else { return }
        
        URLSession.shared.dataTask(with: url) { [weak self] data, response, error in
            guard let self = self,
                  let data = data,
                  let image = UIImage(data: data) else {
                print("⚠️ Failed to download existing image")
                return
            }
            
            DispatchQueue.main.async {
                self.businessImage = image
                print("✅ Downloaded and displayed existing image")
            }
        }.resume()
    }
    
    var stepTitle: String {
        switch currentStep {
        case 0: return "Fotoğraf Yükle"
        case 1: return "Hizmetler Ekle"
        case 2: return "Çalışma Saatleri"
        case 3: return "Önizleme"
        default: return ""
        }
    }
    
    var canProceed: Bool {
        switch currentStep {
        case 0: return true // Photo is optional
        case 1: return !services.isEmpty
        case 2: return true // Working hours optional
        case 3: return true
        default: return false
        }
    }
    
    func nextStep() {
        if currentStep < 3 {
            currentStep += 1
        }
    }
    
    func previousStep() {
        if currentStep > 0 {
            currentStep -= 1
        }
    }
    
    private func setupDefaultWorkingHours() {
        for day in weekDays {
            workingHours[day] = WorkingHoursItem(isOpen: true, openTime: "09:00", closeTime: "18:00")
        }
    }
    
    func toggleDay(_ day: String, isOpen: Bool) {
        workingHours[day]?.isOpen = isOpen
    }
    
    func updateWorkingHours(_ day: String, openTime: String, closeTime: String) {
        workingHours[day]?.openTime = openTime
        workingHours[day]?.closeTime = closeTime
    }
    
    // MARK: - Publish Business
    func publishBusiness(completion: @escaping () -> Void) {
        guard !services.isEmpty else {
            errorMessage = "En az bir hizmet eklemelisiniz"
            showError = true
            return
        }
        
        isPublishing = true
        
        // Handle image upload/deletion intelligently
        if shouldDeleteImage {
            // User wants to delete the image
            createBusinessListing(imageURL: nil, completion: completion)
        } else if let image = businessImage, existingImageURL == nil {
            // New image selected (no existing image)
            uploadBusinessImage(image) { [weak self] imageURL in
                self?.createBusinessListing(imageURL: imageURL, completion: completion)
            }
        } else if let _ = businessImage, let existingURL = existingImageURL {
            // Has both - keep existing URL (image was downloaded, not changed)
            createBusinessListing(imageURL: existingURL, completion: completion)
        } else {
            // No image at all
            createBusinessListing(imageURL: existingImageURL, completion: completion)
        }
    }
    
    private func uploadBusinessImage(_ image: UIImage, completion: @escaping (String?) -> Void) {
        guard let imageData = image.jpegData(compressionQuality: 0.8) else {
            print("❌ Failed to convert image to JPEG data")
            completion(nil)
            return
        }
        
        let path = "business_images/\(user.uid)/cover_\(UUID().uuidString).jpg"
        print("📤 Uploading business image to path: \(path)")
        
        firebaseManager.uploadImage(imageData, path: path) { result in
            switch result {
            case .success(let url):
                print("✅ Business image uploaded successfully: \(url)")
                completion(url)
            case .failure(let error):
                print("❌ Failed to upload business image: \(error.localizedDescription)")
                completion(nil)
            }
        }
    }
    
    private func createBusinessListing(imageURL: String?, completion: @escaping () -> Void) {
        // Extract city from address
        let city = extractCity(from: user.businessAddress ?? "")
        
        // First, check if business listing already exists
        db.collection(Constant.businessesCollection)
            .whereField("businessId", isEqualTo: user.uid)
            .getDocuments { [weak self] snapshot, error in
                guard let self = self else { return }
                
                if let existingDoc = snapshot?.documents.first {
                    // Business listing exists, UPDATE it
                    self.updateExistingBusinessListing(documentId: existingDoc.documentID, imageURL: imageURL, city: city, completion: completion)
                } else {
                    // Business listing doesn't exist, CREATE it
                    self.createNewBusinessListing(imageURL: imageURL, city: city, completion: completion)
                }
            }
    }
    
    private func createNewBusinessListing(imageURL: String?, city: String, completion: @escaping () -> Void) {
        print("📝 Creating NEW business listing")
        print("   - Name: \(user.businessName ?? "N/A")")
        print("   - Image URL: \(imageURL ?? "No image")")
        print("   - City: \(city)")
        
        let listing = BusinessListing(
            id: nil,
            businessId: user.uid,
            name: user.businessName ?? "",
            category: user.businessCategory ?? "",
            city: city,
            address: user.businessAddress ?? "",
            rating: nil,
            reviewCount: 0,
            imageURL: imageURL,
            description: user.businessDescription,
            priceRange: calculatePriceRange(),
            isOpen: true,
            distance: nil
        )
        
        do {
            try db.collection(Constant.businessesCollection)
                .addDocument(from: listing) { [weak self] error in
                    if let error = error {
                        print("❌ Failed to create business listing: \(error.localizedDescription)")
                        DispatchQueue.main.async {
                            self?.isPublishing = false
                            self?.errorMessage = "İşletme yayınlanırken hata oluştu"
                            self?.showError = true
                        }
                    } else {
                        print("✅ Business listing created successfully")
                        self?.createOrUpdateServices(completion: completion)
                    }
                }
        } catch {
            print("❌ Failed to encode business listing: \(error.localizedDescription)")
            DispatchQueue.main.async {
                self.isPublishing = false
                self.errorMessage = "İşletme oluşturulamadı"
                self.showError = true
            }
        }
    }
    
    private func updateExistingBusinessListing(documentId: String, imageURL: String?, city: String, completion: @escaping () -> Void) {
        print("🔄 Updating EXISTING business listing (ID: \(documentId))")
        print("   - Name: \(user.businessName ?? "N/A")")
        print("   - Image URL: \(imageURL ?? "No new image")")
        print("   - City: \(city)")
        
        var updateData: [String: Any] = [
            "name": user.businessName ?? "",
            "category": user.businessCategory ?? "",
            "city": city,
            "address": user.businessAddress ?? "",
            "description": user.businessDescription ?? "",
            "priceRange": calculatePriceRange(),
            "isOpen": true
        ]
        
        // Only update imageURL if a new one was uploaded
        if let imageURL = imageURL {
            updateData["imageURL"] = imageURL
            print("   - Updating imageURL to: \(imageURL)")
        } else {
            print("   - Keeping existing imageURL")
        }
        
        db.collection(Constant.businessesCollection)
            .document(documentId)
            .updateData(updateData) { [weak self] error in
                if let error = error {
                    print("❌ Failed to update business listing: \(error.localizedDescription)")
                    DispatchQueue.main.async {
                        self?.isPublishing = false
                        self?.errorMessage = "İşletme güncellenirken hata oluştu"
                        self?.showError = true
                    }
                } else {
                    print("✅ Business listing updated successfully")
                    self?.createOrUpdateServices(completion: completion)
                }
            }
    }
    
    private func createOrUpdateServices(completion: @escaping () -> Void) {
        // Smart service synchronization:
        // 1. Delete services that were removed
        // 2. Update existing services
        // 3. Create new services
        
        let group = DispatchGroup()
        
        // Step 1: Delete removed services
        for deletedId in deletedServiceIds {
            group.enter()
            db.collection(Constant.servicesCollection)
                .document(deletedId)
                .delete { error in
                    if let error = error {
                        print("⚠️ Failed to delete service \(deletedId): \(error.localizedDescription)")
                    } else {
                        print("✅ Deleted service: \(deletedId)")
                    }
                    group.leave()
                }
        }
        
        // Step 2 & 3: Update existing and create new services
        for serviceItem in services {
            group.enter()
            
            if let firestoreId = serviceItem.firestoreId {
                // Update existing service
                let serviceData: [String: Any] = [
                    "name": serviceItem.name,
                    "description": serviceItem.description,
                    "duration": serviceItem.duration,
                    "price": serviceItem.price,
                    "isActive": true
                ]
                
                db.collection(Constant.servicesCollection)
                    .document(firestoreId)
                    .updateData(serviceData) { error in
                        if let error = error {
                            print("⚠️ Failed to update service \(firestoreId): \(error.localizedDescription)")
                        } else {
                            print("✅ Updated service: \(serviceItem.name)")
                        }
                        group.leave()
                    }
            } else {
                // Create new service
                let service = Service(
                    id: nil,
                    businessId: user.uid,
                    name: serviceItem.name,
                    description: serviceItem.description,
                    duration: serviceItem.duration,
                    price: serviceItem.price,
                    isActive: true,
                    createdAt: Timestamp()
                )
                
                do {
                    try db.collection(Constant.servicesCollection)
                        .addDocument(from: service) { error in
                            if let error = error {
                                print("⚠️ Failed to create service: \(error.localizedDescription)")
                            } else {
                                print("✅ Created new service: \(serviceItem.name)")
                            }
                            group.leave()
                        }
                } catch {
                    print("⚠️ Failed to encode service: \(error.localizedDescription)")
                    group.leave()
                }
            }
        }
        
        // Wait for all operations to complete
        group.notify(queue: .main) { [weak self] in
            self?.updateUserWorkingHours(completion: completion)
        }
    }
    
    private func updateUserWorkingHours(completion: @escaping () -> Void) {
        // Convert to Firestore format
        var firestoreWorkingHours: [String: [String: Any]] = [:]
        for (day, hours) in workingHours {
            firestoreWorkingHours[day] = [
                "isOpen": hours.isOpen,
                "openTime": hours.openTime,
                "closeTime": hours.closeTime
            ]
        }
        
        db.collection(Constant.usersCollection)
            .document(user.uid)
            .updateData(["workingHours": firestoreWorkingHours]) { [weak self] error in
                DispatchQueue.main.async {
                    self?.isPublishing = false
                    if error == nil {
                        completion()
                    } else {
                        self?.errorMessage = "Çalışma saatleri kaydedilemedi"
                        self?.showError = true
                    }
                }
            }
    }
    
    private func extractCity(from address: String) -> String {
        // Try to extract city from address
        // Format: "Çankaya, Ankara" -> "Ankara"
        let components = address.components(separatedBy: ",")
        if components.count > 1 {
            return components.last?.trimmingCharacters(in: .whitespaces) ?? "Diğer"
        }
        return "Diğer"
    }
    
    private func calculatePriceRange() -> String {
        guard !services.isEmpty else { return "$$" }
        
        let avgPrice = services.map { $0.price }.reduce(0, +) / Double(services.count)
        
        if avgPrice < 100 {
            return "$"
        } else if avgPrice < 300 {
            return "$$"
        } else {
            return "$$$"
        }
    }
}





