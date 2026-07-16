//
//  AuthManager.swift
//  ReservationApp
//
//  Created by Mahmut Arslan on 25.10.2025.
//

import Foundation
import FirebaseAuth
import FirebaseFirestore
import Combine

/// User authentication manager
class AuthManager: ObservableObject {
    @Published var currentUser: User?
    @Published var isAuthenticated = false
    
    static let shared = AuthManager()
    private let auth = Auth.auth()
    private lazy var db = Firestore.firestore()
    
    private init() {
        // Don't call checkAuthStatus() here - it blocks app launch
        print("✅ AuthManager initialized (auth check will be called later)")
    }
    
    /// Check if user is already authenticated
    func checkAuthStatus() {
        // Use async dispatch to avoid blocking main thread
        DispatchQueue.global(qos: .userInitiated).async { [weak self] in
            guard let self = self else { return }
            
            if let firebaseUser = self.auth.currentUser {
                print("✅ User already logged in: \(firebaseUser.uid)")
                self.fetchUserData(uid: firebaseUser.uid)
            } else {
                print("ℹ️ User not logged in")
            }
        }
    }
    
    // MARK: - Sign In
    func signIn(email: String, 
               password: String, 
               completion: @escaping (Result<User, Error>) -> Void) {
        
        auth.signIn(withEmail: email, password: password) { [weak self] result, error in
            if let error = error {
                print("❌ Sign in error: \(error.localizedDescription)")
                completion(.failure(error))
                return
            }
            
            guard let uid = result?.user.uid else { return }
            print("✅ Firebase Auth successful, fetching user data...")
            
            self?.fetchUserData(uid: uid) { user in
                completion(.success(user))
            }
        }
    }
    
    // MARK: - Sign Up
    func signUp(email: String, 
               password: String, 
               name: String,
               phoneNumber: String,
               userType: UserType,
               businessName: String? = nil,
               businessAddress: String? = nil,
               businessCity: String? = nil,
               businessDistrict: String? = nil,
               businessCategory: String? = nil,
               completion: @escaping (Result<User, Error>) -> Void) {
        
        auth.createUser(withEmail: email, password: password) { [weak self] result, error in
            if let error = error {
                print("❌ Sign up error: \(error.localizedDescription)")
                completion(.failure(error))
                return
            }
            
            guard let uid = result?.user.uid else { return }
            print("✅ Firebase Auth registration successful, saving user data...")
            print("📝 Saving User Data - City: '\(businessCity ?? "nil")', District: '\(businessDistrict ?? "nil")'")
            
            // Create User object
            let user = User(
                id: nil,
                uid: uid,
                email: email,
                name: name,
                phoneNumber: phoneNumber,
                phoneVerified: false,
                userType: userType,
                profileImageURL: nil,
                createdAt: Timestamp(),
                updatedAt: nil,
                businessName: businessName,
                businessCity: businessCity,
                businessDistrict: businessDistrict,
                businessAddress: businessAddress,
                businessCategory: businessCategory,
                businessDescription: nil,
                workingHours: nil
            )
            
            self?.createUserDocument(uid: uid, user: user, completion: completion)
        }
    }
    
    // MARK: - Sign Out
    func signOut() {
        do {
            try auth.signOut()
            currentUser = nil
            isAuthenticated = false
            print("✅ Signed out successfully")
        } catch {
            print("❌ Sign out error: \(error.localizedDescription)")
        }
    }
    
    // MARK: - Fetch User Data
    private func fetchUserData(uid: String, completion: ((User) -> Void)? = nil) {
        db.collection(Constant.usersCollection)
            .document(uid)
            .getDocument { [weak self] snapshot, error in
                
                if let error = error {
                    print("❌ Failed to fetch user data: \(error.localizedDescription)")
                    return
                }
                
                guard let snapshot = snapshot, snapshot.exists else {
                    print("❌ User data not found")
                    return
                }
                
                DispatchQueue.main.async {
                    do {
                        let user = try snapshot.data(as: User.self)
                        self?.currentUser = user
                        self?.isAuthenticated = true
                        print("✅ User data loaded: \(user.name)")
                        completion?(user)
                    } catch {
                        print("❌ Failed to parse user data: \(error)")
                        print("❌ Error details: \(error.localizedDescription)")
                    }
                }
            }
    }
    
    // MARK: - Create User Document
    private func createUserDocument(uid: String, 
                                   user: User,
                                   completion: @escaping (Result<User, Error>) -> Void) {
        do {
            try db.collection(Constant.usersCollection)
                .document(uid)
                .setData(from: user) { [weak self] error in
                    
                    if let error = error {
                        print("❌ Failed to save user data: \(error.localizedDescription)")
                        completion(.failure(error))
                        return
                    }
                    
                    print("✅ User data saved successfully")
                    
                    // If business user, create business listing
                    if user.userType == .business {
                        self?.createBusinessListing(for: user)
                    }
                    
                    self?.fetchUserData(uid: uid) { user in
                        completion(.success(user))
                    }
                }
        } catch {
            print("❌ Failed to encode user data: \(error.localizedDescription)")
            completion(.failure(error))
        }
    }
    
    // MARK: - Create Business Listing
    // MARK: - Create Business Listing
    private func createBusinessListing(for user: User) {
        guard let businessName = user.businessName,
              let businessAddress = user.businessAddress,
              let businessCategory = user.businessCategory else {
            print("⚠️ Missing business info, skipping listing creation")
            return
        }
        
        // Use businessCity if available, otherwise try to extract from address or default to "İstanbul"
        let city = user.businessCity ?? "İstanbul"
        print("📝 Creating Business Listing - Using City: '\(city)' (User.businessCity: '\(user.businessCity ?? "nil")')")
        
        BusinessListingManager.shared.createOrUpdateBusinessListing(
            businessId: user.uid,
            name: businessName,
            category: businessCategory,
            city: city,
            address: businessAddress,
            description: user.businessDescription,
            phoneNumber: user.phoneNumber
        ) { result in
            switch result {
            case .success:
                print("✅ Auto-created business listing for \(businessName)")
            case .failure(let error):
                print("❌ Failed to auto-create business listing: \(error)")
            }
        }
    }
    
    // MARK: - Update Profile
    func updateProfile(userData: [String: Any], completion: @escaping (Result<Void, Error>) -> Void) {
        guard let uid = currentUser?.uid else {
            completion(.failure(AuthError.userNotFound))
            return
        }
        
        var updatedData = userData
        updatedData["updatedAt"] = Timestamp()
        
        db.collection(Constant.usersCollection)
            .document(uid)
            .updateData(updatedData) { [weak self] error in
                
                if let error = error {
                    print("❌ Failed to update profile: \(error.localizedDescription)")
                    completion(.failure(error))
                    return
                }
                
                print("✅ Profile updated successfully")
                self?.fetchUserData(uid: uid)
                completion(.success(()))
            }
    }
    
    // MARK: - Update Current User (for real-time updates)
    func updateCurrentUser(_ user: User) {
        DispatchQueue.main.async {
            self.currentUser = user
        }
    }
    
    // MARK: - Reset Password
    func resetPassword(email: String, completion: @escaping (Result<Void, Error>) -> Void) {
        auth.sendPasswordReset(withEmail: email) { error in
            if let error = error {
                print("❌ Failed to send password reset email: \(error.localizedDescription)")
                completion(.failure(error))
            } else {
                print("✅ Password reset email sent successfully")
                completion(.success(()))
            }
        }
    }
}

// MARK: - Auth Errors
enum AuthError: LocalizedError {
    case userNotFound
    case invalidCredentials
    case weakPassword
    
    var errorDescription: String? {
        switch self {
        case .userNotFound:
            return "User not found"
        case .invalidCredentials:
            return "Invalid email or password"
        case .weakPassword:
            return "Password must be at least 6 characters"
        }
    }
}
