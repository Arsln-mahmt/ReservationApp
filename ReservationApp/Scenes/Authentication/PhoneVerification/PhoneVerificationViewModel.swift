//
//  PhoneVerificationViewModel.swift
//  ReservationApp
//
//  Created by Mahmut Arslan on 25.10.2025.
//

import Foundation
import SwiftUI
import Combine
import FirebaseAuth
import FirebaseFirestore

class PhoneVerificationViewModel: ObservableObject {
    let phoneNumber: String
    let userId: String
    
    @Published var verificationCode = ""
    @Published var isLoading = false
    @Published var isSendingCode = false
    @Published var errorMessage: String?
    @Published var successMessage: String?
    @Published var verificationId: String?
    @Published var countdown: Int = 60
    @Published var canResend = false
    
    private var timer: Timer?
    private let db = Firestore.firestore()
    
    init(phoneNumber: String, userId: String) {
        self.phoneNumber = phoneNumber
        self.userId = userId
        sendVerificationCode()
    }
    
    // MARK: - Send Verification Code
    func sendVerificationCode() {
        isSendingCode = true
        errorMessage = nil
        successMessage = nil
        canResend = false
        countdown = 60
        
        // Start countdown timer
        startCountdown()
        
        // TODO: Implement Firebase Phone Auth
        // For now, simulate sending code
        DispatchQueue.main.asyncAfter(deadline: .now() + 2) { [weak self] in
            guard let self = self else { return }
            self.isSendingCode = false
            
            // Simulate verification ID (in production, this comes from Firebase)
            self.verificationId = "simulation_\(UUID().uuidString)"
            self.successMessage = "Doğrulama kodu \(self.phoneNumber) numarasına gönderildi"
            
            print("📱 Verification code sent to: \(self.phoneNumber)")
            print("🔑 For testing, use code: 123456")
        }
        
        /* PRODUCTION CODE - Firebase Phone Auth:
        
        PhoneAuthProvider.provider()
            .verifyPhoneNumber(phoneNumber, uiDelegate: nil) { [weak self] verificationId, error in
                guard let self = self else { return }
                
                DispatchQueue.main.async {
                    self.isSendingCode = false
                    
                    if let error = error {
                        self.errorMessage = "Kod gönderilemedi: \(error.localizedDescription)"
                        print("❌ Failed to send verification code: \(error)")
                        return
                    }
                    
                    if let verificationId = verificationId {
                        self.verificationId = verificationId
                        self.successMessage = "Doğrulama kodu \(self.phoneNumber) numarasına gönderildi"
                        print("✅ Verification code sent successfully")
                    }
                }
            }
        */
    }
    
    // MARK: - Verify Code
    func verifyCode(completion: @escaping (Bool) -> Void) {
        guard !verificationCode.isEmpty else {
            errorMessage = "Lütfen doğrulama kodunu girin"
            completion(false)
            return
        }
        
        guard verificationCode.count == 6 else {
            errorMessage = "Doğrulama kodu 6 haneli olmalıdır"
            completion(false)
            return
        }
        
        isLoading = true
        errorMessage = nil
        
        // TODO: Implement Firebase Phone Auth verification
        // For now, simulate verification (accept 123456 as valid code)
        DispatchQueue.main.asyncAfter(deadline: .now() + 1.5) { [weak self] in
            guard let self = self else { return }
            
            if self.verificationCode == "123456" {
                // Verification successful
                self.updatePhoneVerificationStatus { success in
                    self.isLoading = false
                    if success {
                        self.successMessage = "Telefon numaranız doğrulandı!"
                        print("✅ Phone verification successful")
                        completion(true)
                    } else {
                        self.errorMessage = "Doğrulama kaydedilemedi. Lütfen tekrar deneyin."
                        completion(false)
                    }
                }
            } else {
                self.isLoading = false
                self.errorMessage = "Geçersiz doğrulama kodu"
                completion(false)
            }
        }
        
        /* PRODUCTION CODE - Firebase Phone Auth:
        
        guard let verificationId = verificationId else {
            errorMessage = "Doğrulama ID'si bulunamadı. Lütfen tekrar kod gönderin."
            completion(false)
            return
        }
        
        let credential = PhoneAuthProvider.provider().credential(
            withVerificationID: verificationId,
            verificationCode: verificationCode
        )
        
        Auth.auth().currentUser?.link(with: credential) { [weak self] result, error in
            guard let self = self else { return }
            
            DispatchQueue.main.async {
                if let error = error {
                    self.isLoading = false
                    self.errorMessage = "Doğrulama başarısız: \(error.localizedDescription)"
                    completion(false)
                    return
                }
                
                // Update phone verification status in Firestore
                self.updatePhoneVerificationStatus { success in
                    self.isLoading = false
                    if success {
                        self.successMessage = "Telefon numaranız doğrulandı!"
                        completion(true)
                    } else {
                        self.errorMessage = "Doğrulama kaydedilemedi"
                        completion(false)
                    }
                }
            }
        }
        */
    }
    
    // MARK: - Update Phone Verification Status
    private func updatePhoneVerificationStatus(completion: @escaping (Bool) -> Void) {
        db.collection(Constant.usersCollection)
            .document(userId)
            .updateData([
                "phoneVerified": true,
                "updatedAt": Timestamp()
            ]) { error in
                if let error = error {
                    print("❌ Failed to update phone verification status: \(error)")
                    completion(false)
                } else {
                    print("✅ Phone verification status updated")
                    completion(true)
                }
            }
    }
    
    // MARK: - Countdown Timer
    private func startCountdown() {
        timer?.invalidate()
        countdown = 60
        canResend = false
        
        timer = Timer.scheduledTimer(withTimeInterval: 1.0, repeats: true) { [weak self] _ in
            guard let self = self else { return }
            
            if self.countdown > 0 {
                self.countdown -= 1
            } else {
                self.canResend = true
                self.timer?.invalidate()
            }
        }
    }
    
    deinit {
        timer?.invalidate()
    }
}











