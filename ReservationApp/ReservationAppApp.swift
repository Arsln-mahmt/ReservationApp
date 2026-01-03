//
//  ReservationAppApp.swift
//  ReservationApp
//
//  Created by Mahmut Arslan on 25.10.2025.
//

import SwiftUI
import FirebaseCore

@main
struct ReservationAppApp: App {
    // Connect AppDelegate to initialize Firebase
    @UIApplicationDelegateAdaptor(AppDelegate.self) var appDelegate
    
    @StateObject private var sceneDelegate = SceneDelegate.shared
    @StateObject private var authManager = AuthManager.shared
    @StateObject private var appEnvironment = AppEnvironment.shared
    @State private var hasCheckedAuth = false
    @State private var showSplash = true
    
    var body: some Scene {
        WindowGroup {
            ZStack {
                // Only render main content AFTER splash is hidden
                if !showSplash {
                    Group {
                        switch sceneDelegate.currentScene {
                        case .mainApp:
                            MainTabView()
                        case .businessDashboard:
                            BusinessDashboardScene()
                        }
                    }
                    .environmentObject(sceneDelegate)
                    .environmentObject(appEnvironment)
                    .environmentObject(authManager)
                } else {
                    // During splash, show nothing else
                    Color.clear
                }
                
                if showSplash {
                    SplashView()
                        .transition(.opacity)
                        .zIndex(1)
                }
            }
            .onAppear {
                print("🚀 App appeared, starting splash timer")
                
                // Check auth status FIRST
                print("🔐 Checking existing Firebase session...")
                authManager.checkAuthStatus()
                
                // Hide splash after delay
                DispatchQueue.main.asyncAfter(deadline: .now() + 2.5) {
                    print("⏰ Splash timer completed, hiding splash")
                    withAnimation(.easeOut(duration: 0.5)) {
                        showSplash = false
                    }
                }
                
                // Check auth state AFTER splash is hidden
                DispatchQueue.main.asyncAfter(deadline: .now() + 3.0) {
                    if !hasCheckedAuth {
                        hasCheckedAuth = true
                        print("🔐 Checking authentication state")
                        checkAuthenticationState()
                    }
                }
            }
            .onChange(of: authManager.currentUser) { _, newUser in
                // When user changes, update navigation
                if let user = newUser {
                    if user.userType == .business {
                        sceneDelegate.navigateTo(.businessDashboard)
                    } else {
                        sceneDelegate.navigateTo(.mainApp)
                    }
                }
            }
        }
    }
    
    // Check authentication and update environment
    private func checkAuthenticationState() {
        if authManager.isAuthenticated, let user = authManager.currentUser {
            appEnvironment.isAuthenticated = true
            appEnvironment.currentUser = user
            appEnvironment.userType = user.userType
            
            // Navigate based on user type
            DispatchQueue.main.async {
                if user.userType == .business {
                    self.sceneDelegate.navigateTo(.businessDashboard)
                } else {
                    self.sceneDelegate.navigateTo(.mainApp)
                }
            }
        } else {
            // Not authenticated, show main app (guest mode)
            sceneDelegate.navigateTo(.mainApp)
        }
    }
}
