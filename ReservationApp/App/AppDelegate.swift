//
//  AppDelegate.swift
//  ReservationApp
//
//  Created by Mahmut Arslan on 25.10.2025.
//

import UIKit
import FirebaseCore

class AppDelegate: NSObject, UIApplicationDelegate {
    func application(_ application: UIApplication,
                    didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey : Any]? = nil) -> Bool {
        // Configure Firebase
        FirebaseApp.configure()
        
        print("✅ Firebase configured successfully")
        return true
    }
}
