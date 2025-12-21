//
//  VoiceServiceManager.swift
//  ReservationApp
//
//  Created by Mahmut Arslan on 16.11.2025.
//

import Foundation
import FirebaseFirestore

class VoiceServiceManager {
    static let shared = VoiceServiceManager()
    
    // IMPORTANT: Backend URL'inizi buraya yazın
    // Simulator için: "http://127.0.0.1:8000" veya "http://localhost:8000"
    // Gerçek cihaz için: "http://YOUR_MAC_IP:8000" (örn: "http://192.168.1.100:8000")
    // Deploy edilmişse: "https://your-backend-url.com"
    let baseURL = "http://192.168.1.129:8000"
    
    // Custom URLSession with extended timeout
    private lazy var urlSession: URLSession = {
        let configuration = URLSessionConfiguration.default
        configuration.timeoutIntervalForRequest = 120  // Request timeout
        configuration.timeoutIntervalForResource = 300 // Resource timeout (total time)
        return URLSession(configuration: configuration)
    }()
     
    private init() {}
    
    // MARK: - Process Voice Reservation
    func processVoiceReservation(
        audioURL: URL,
        userId: String,
        completion: @escaping (Result<VoiceReservationResponse, Error>) -> Void
    ) {
        let endpoint = "\(baseURL)/voice-reservation"
        
        // Add user_id as query parameter
        var components = URLComponents(string: endpoint)
        components?.queryItems = [URLQueryItem(name: "user_id", value: userId)]
        
        guard let url = components?.url else {
            completion(.failure(NSError(domain: "Invalid URL", code: -1, userInfo: [NSLocalizedDescriptionKey: "Invalid endpoint URL"])))
            return
        }
        
        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.timeoutInterval = 120
        
        print("🌐 Voice Service Request:")
        print("   URL: \(url.absoluteString)")
        print("   Timeout: 120s (request), 300s (resource)")
        print("   Time: \(Date())")
        
        // Create multipart/form-data
        let boundary = "Boundary-\(UUID().uuidString)"
        request.setValue("multipart/form-data; boundary=\(boundary)", forHTTPHeaderField: "Content-Type")
        
        // Build multipart body
        guard let httpBody = createMultipartBody(
            boundary: boundary,
            audioURL: audioURL,
            fieldName: "audio"
        ) else {
            let error = NSError(
                domain: "VoiceServiceManager",
                code: -1,
                userInfo: [NSLocalizedDescriptionKey: "Ses dosyası okunamadı. Lütfen tekrar deneyin."]
            )
            completion(.failure(error))
            return
        }
        
        request.httpBody = httpBody
        
        
        // Send request with custom session
        print("📤 Sending voice request...")
        let startTime = Date()
        
        urlSession.dataTask(with: request) { data, response, error in
            let elapsed = Date().timeIntervalSince(startTime)
            print("⏱️ Request completed in \(String(format: "%.2f", elapsed))s")
            
            if let error = error {
                let nsError = error as NSError
                print("❌ Request failed:")
                print("   Domain: \(nsError.domain)")
                print("   Code: \(nsError.code)")
                print("   Description: \(nsError.localizedDescription)")
                print("   Time elapsed: \(String(format: "%.2f", elapsed))s")
                
                // Check if it's a timeout
                if nsError.code == NSURLErrorTimedOut {
                    print("⚠️ TIMEOUT ERROR - Backend took longer than \(elapsed)s")
                    print("   Suggestion: Check if backend is running and responding")
                }
                
                completion(.failure(error))
                return
            }
            
            guard let httpResponse = response as? HTTPURLResponse else {
                completion(.failure(NSError(domain: "Invalid response", code: -1)))
                return
            }
            
            guard let data = data else {
                completion(.failure(NSError(domain: "No data", code: -1)))
                return
            }
            
            // Check status code
            guard (200...299).contains(httpResponse.statusCode) else {
                completion(.failure(NSError(domain: "Server error", code: httpResponse.statusCode)))
                return
            }
            
            // Parse response
            do {
                let decoder = JSONDecoder()
                let voiceResponse = try decoder.decode(VoiceReservationResponse.self, from: data)
                completion(.success(voiceResponse))
            } catch {
                completion(.failure(error))
            }
        }.resume()
    }
    
    // MARK: - Create Multipart Body
    private func createMultipartBody(
        boundary: String,
        audioURL: URL,
        fieldName: String
    ) -> Data? {
        var body = Data()
        
        let boundaryPrefix = "--\(boundary)\r\n"
        let boundarySuffix = "--\(boundary)--\r\n"
        
        // Debug: Print audio file path
        print("🎤 Audio file path: \(audioURL.path)")
        print("🎤 File exists: \(FileManager.default.fileExists(atPath: audioURL.path))")
        
        // Read audio file
        guard let audioData = try? Data(contentsOf: audioURL) else {
            print("❌ Failed to read audio file at: \(audioURL.path)")
            return nil
        }
        
        print("✅ Audio data size: \(audioData.count) bytes")
        
        // Add audio file part
        body.append(boundaryPrefix.data(using: .utf8)!)
        body.append("Content-Disposition: form-data; name=\"\(fieldName)\"; filename=\"\(audioURL.lastPathComponent)\"\r\n".data(using: .utf8)!)
        body.append("Content-Type: audio/m4a\r\n\r\n".data(using: .utf8)!)
        body.append(audioData)
        body.append("\r\n".data(using: .utf8)!)
        
        // End boundary
        body.append(boundarySuffix.data(using: .utf8)!)
        
        return body
    }
    
    // MARK: - Get User Reservations
    func getUserReservations(
        userId: String,
        completion: @escaping (Result<[Reservation], Error>) -> Void
    ) {
        let endpoint = "\(baseURL)/reservations/\(userId)"
        
        guard let url = URL(string: endpoint) else {
            completion(.failure(NSError(domain: "Invalid URL", code: -1, userInfo: [NSLocalizedDescriptionKey: "Invalid endpoint URL"])))
            return
        }
        
        var request = URLRequest(url: url)
        request.httpMethod = "GET"
        request.timeoutInterval = 30
        
        print("🔍 Fetching reservations from backend:")
        print("   URL: \(url.absoluteString)")
        print("   User ID: \(userId)")
        
        urlSession.dataTask(with: request) { data, response, error in
            if let error = error {
                print("❌ Failed to fetch reservations: \(error.localizedDescription)")
                completion(.failure(error))
                return
            }
            
            guard let httpResponse = response as? HTTPURLResponse else {
                completion(.failure(NSError(domain: "Invalid response", code: -1)))
                return
            }
            
            guard let data = data else {
                completion(.failure(NSError(domain: "No data", code: -1)))
                return
            }
            
            guard (200...299).contains(httpResponse.statusCode) else {
                print("❌ Server error: \(httpResponse.statusCode)")
                completion(.failure(NSError(domain: "Server error", code: httpResponse.statusCode)))
                return
            }
            
            // Parse response
            do {
                let decoder = JSONDecoder()
                let backendResponse = try decoder.decode(BackendReservationsResponse.self, from: data)
                print("✅ Fetched \(backendResponse.count) reservations from backend")
                
                // Convert BackendReservation to Reservation with business names
                self.convertReservationsWithBusinessNames(backendResponse.reservations) { reservations in
                    completion(.success(reservations))
                }
            } catch {
                print("❌ Failed to decode reservations: \(error.localizedDescription)")
                if let dataString = String(data: data, encoding: .utf8) {
                    print("📝 Response data: \(dataString)")
                }
                completion(.failure(error))
            }
        }.resume()
    }
    
    // MARK: - Convert Reservations with Business Names
    private func convertReservationsWithBusinessNames(
        _ backendReservations: [BackendReservation],
        completion: @escaping ([Reservation]) -> Void
    ) {
        let db = Firestore.firestore()
        let group = DispatchGroup()
        var reservations: [Reservation] = []
        
        for backendRes in backendReservations {
            group.enter()
            
            // Fetch business name and businessId from Firestore
            db.collection("businesses")
                .document(backendRes.business_id)
                .getDocument { snapshot, error in
                    defer { group.leave() }
                    
                    let businessName = snapshot?.data()?["name"] as? String ?? "İşletme"
                    // CRITICAL: Use businessId field (user ID), not document ID
                    let businessId = snapshot?.data()?["businessId"] as? String ?? backendRes.business_id
                    
                    if let reservation = backendRes.toReservation(businessName: businessName, businessId: businessId) {
                        reservations.append(reservation)
                    }
                }
        }
        
        group.notify(queue: .main) {
            // Sort by creation date (newest first)
            let sortedReservations = reservations.sorted { $0.createdAt.dateValue() > $1.createdAt.dateValue() }
            completion(sortedReservations)
        }
    }
    
    // MARK: - Get Business Reservations
    func getBusinessReservations(
        businessId: String,
        completion: @escaping (Result<[Reservation], Error>) -> Void
    ) {
        let endpoint = "\(baseURL)/business-reservations/\(businessId)"
        
        guard let url = URL(string: endpoint) else {
            completion(.failure(NSError(domain: "Invalid URL", code: -1, userInfo: [NSLocalizedDescriptionKey: "Invalid endpoint URL"])))
            return
        }
        
        var request = URLRequest(url: url)
        request.httpMethod = "GET"
        request.timeoutInterval = 30
        
        print("🏬 Fetching business reservations from backend:")
        print("   URL: \(url.absoluteString)")
        print("   Business ID: \(businessId)")
        
        urlSession.dataTask(with: request) { data, response, error in
            if let error = error {
                print("❌ Failed to fetch business reservations: \(error.localizedDescription)")
                completion(.failure(error))
                return
            }
            
            guard let httpResponse = response as? HTTPURLResponse else {
                completion(.failure(NSError(domain: "Invalid response", code: -1)))
                return
            }
            
            guard let data = data else {
                completion(.failure(NSError(domain: "No data", code: -1)))
                return
            }
            
            guard (200...299).contains(httpResponse.statusCode) else {
                print("❌ Server error: \(httpResponse.statusCode)")
                completion(.failure(NSError(domain: "Server error", code: httpResponse.statusCode)))
                return
            }
            
            // Parse response
            do {
                let decoder = JSONDecoder()
                let backendResponse = try decoder.decode(BackendReservationsResponse.self, from: data)
                print("✅ Fetched \(backendResponse.count) business reservations from backend")
                
                // Convert BackendReservation to Reservation with business names
                self.convertReservationsWithBusinessNames(backendResponse.reservations) { reservations in
                    completion(.success(reservations))
                }
            } catch {
                print("❌ Failed to decode business reservations: \(error.localizedDescription)")
                if let dataString = String(data: data, encoding: .utf8) {
                    print("📝 Response data: \(dataString)")
                }
                completion(.failure(error))
            }
        }.resume()
    }
}

// MARK: - Response Models
struct VoiceReservationResponse: Codable {
    let raw_stt: String?
    let cleaned_text: String?
    let cleaned_fixed: String?
    let parsed: ParsedData?
    let final_answer: String
    let reservation_created: Bool?
    let reservation_id: String?
    
    struct ParsedData: Codable {
        let intent: String?
        let date: String?
        let time: String?
        let service: String?
        let business_name: String?
    }
}

// MARK: - Backend Reservation Models
struct BackendReservationsResponse: Codable {
    let reservations: [BackendReservation]
    let count: Int
}

struct BackendReservation: Codable {
    let id: String?
    let user_id: String
    let user_name: String?        // Customer name from backend
    let user_phone: String?       // Customer phone from backend
    let business_id: String
    let service_id: String?
    let service_name: String
    let date: String  // "2025-12-02"
    let time: String  // "11:00"
    let status: String
    let created_at: String
    
    // Convert to iOS Reservation model
    func toReservation(businessName: String = "İşletme", businessId: String? = nil) -> Reservation? {
        // Parse date string - try ISO 8601 first, then simple date format
        let dateObj: Date
        
        // Try ISO 8601 format first (e.g., "2025-12-01T22:57:46.683866+00:00")
        let dateIsoFormatter = ISO8601DateFormatter()
        dateIsoFormatter.formatOptions = [.withInternetDateTime, .withFractionalSeconds]
        
        if let parsedDate = dateIsoFormatter.date(from: date) {
            dateObj = parsedDate
        } else {
            // Fallback to simple date format (YYYY-MM-DD)
            let dateFormatter = DateFormatter()
            dateFormatter.dateFormat = "yyyy-MM-dd"
            
            guard let parsedDate = dateFormatter.date(from: date) else {
                print("⚠️ Failed to parse date: \(date)")
                return nil
            }
            dateObj = parsedDate
        }
        
        // Parse created_at (ISO string)
        let isoFormatter = ISO8601DateFormatter()
        isoFormatter.formatOptions = [.withInternetDateTime, .withFractionalSeconds]
        let createdAtObj = isoFormatter.date(from: created_at) ?? Date()
        
        // Map status string to ReservationStatus
        let reservationStatus: ReservationStatus
        switch status.lowercased() {
        case "pending": reservationStatus = .pending
        case "confirmed": reservationStatus = .confirmed
        case "completed": reservationStatus = .completed
        case "cancelled": reservationStatus = .cancelled
        case "no_show": reservationStatus = .noShow
        default: reservationStatus = .pending
        }
        
        return Reservation(
            id: id,
            customerId: user_id,
            customerName: user_name ?? "Müşteri",  // Use actual name from backend
            customerPhone: user_phone,
            businessId: businessId ?? business_id,  // Use fetched businessId (user ID) if available
            businessName: businessName,  // Fetched from Firestore
            serviceType: service_name,
            date: Timestamp(date: dateObj),
            timeSlot: time,
            duration: 60,  // Default duration
            status: reservationStatus,
            notes: nil,
            createdAt: Timestamp(date: createdAtObj),
            updatedAt: nil,
            aiRecommended: true,
            proposedDate: nil,
            proposedTimeSlot: nil
        )
    }
}

