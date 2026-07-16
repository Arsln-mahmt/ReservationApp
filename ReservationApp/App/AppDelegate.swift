//
//  AppDelegate.swift
//  ReservationApp
//
//  Created by Mahmut Arslan on 25.10.2025.
//

import UIKit
import FirebaseCore
import FirebaseFirestore

class AppDelegate: NSObject, UIApplicationDelegate {
    func application(_ application: UIApplication,
                    didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey : Any]? = nil) -> Bool {
        
        print("🔧 Configuring Firebase...")
        
        // Configure Firebase
        FirebaseApp.configure()
        
        // Configure Firestore settings for better performance and offline support
        let db = Firestore.firestore()
        let settings = FirestoreSettings()
        
        // Enable offline persistence
        settings.cacheSettings = PersistentCacheSettings()
        
        db.settings = settings
        
        print("✅ Firestore configured with offline persistence")
        
        // Verify Firebase is configured
        if let app = FirebaseApp.app() {
            print("✅ Firebase configured successfully")
            print("📱 Firebase App Name: \(app.name)")
            print("🔑 Project ID: \(app.options.projectID ?? "unknown")")
            print("📦 Bundle ID: \(app.options.bundleID)")
        } else {
            print("❌ Firebase configuration FAILED!")
        }
        
        return true
    }
}
