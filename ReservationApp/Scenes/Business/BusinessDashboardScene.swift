//
//  BusinessDashboardScene.swift
//  ReservationApp
//
//  Created by Mahmut Arslan on 25.10.2025.
//

import SwiftUI
import FirebaseFirestore

struct BusinessDashboardScene: View {
    @State private var selectedTab: BusinessTabItem = .dashboard
    @EnvironmentObject var authManager: AuthManager
    
    @State private var showSetupWizard = false
    @State private var isCheckingSetup = true
    @State private var businessListing: BusinessListing?
    @State private var needsSetup = false
    
    var body: some View {
        ZStack(alignment: .top) {
            Group {
                if isCheckingSetup {
                    // Loading state
                    VStack(spacing: 20) {
                        ProgressView()
                            .scaleEffect(1.5)
                        Text("Yükleniyor...")
                            .foregroundColor(.textSecondary)
                    }
                } else {
                    TabView(selection: $selectedTab) {
                        // Appointments Tab
                        BusinessAppointmentsScene()
                            .tabItem {
                                Label(BusinessTabItem.appointments.title, systemImage: BusinessTabItem.appointments.icon)
                            }
                            .tag(BusinessTabItem.appointments)
                        
                        // Dashboard Tab
                        BusinessOverviewScene()
                            .tabItem {
                                Label(BusinessTabItem.dashboard.title, systemImage: BusinessTabItem.dashboard.icon)
                            }
                            .tag(BusinessTabItem.dashboard)
                        
                        // Settings Tab
                        BusinessSettingsScene(
                            needsSetup: needsSetup,
                            onOpenSetup: {
                                showSetupWizard = true
                            }
                        )
                        .tabItem {
                            Label(BusinessTabItem.settings.title, systemImage: BusinessTabItem.settings.icon)
                        }
                        .tag(BusinessTabItem.settings)
                    }
                    .accentColor(.primaryOrange)
                }
            }
            
            // Setup warning banner (if not published)
            if needsSetup && !isCheckingSetup {
                setupWarningBanner
            }
        }
        .fullScreenCover(isPresented: $showSetupWizard, onDismiss: {
            // Re-check setup after wizard closes
            checkBusinessSetup()
        }) {
            if let user = authManager.currentUser {
                BusinessSetupWizardScene(user: user)
            }
        }
        .onAppear {
            checkBusinessSetup()
        }
    }
    
    // MARK: - Setup Warning Banner
    private var setupWarningBanner: some View {
        VStack(spacing: 0) {
            HStack(spacing: 12) {
                Image(systemName: "exclamationmark.triangle.fill")
                    .font(.title3)
                    .foregroundColor(.yellow)
                
                VStack(alignment: .leading, spacing: 4) {
                    Text("İşletmeniz Henüz Yayında Değil")
                        .font(.subheadline)
                        .fontWeight(.bold)
                        .foregroundColor(.white)
                    
                    Text("Kurulumu tamamlayıp yayınlayın")
                        .font(.caption)
                        .foregroundColor(.white.opacity(0.9))
                }
                
                Spacer()
                
                Button(action: {
                    showSetupWizard = true
                }) {
                    Text("Kuruluma Git")
                        .font(.caption)
                        .fontWeight(.semibold)
                        .foregroundColor(.orange)
                        .padding(.horizontal, 12)
                        .padding(.vertical, 6)
                        .background(Color.white)
                        .cornerRadius(8)
                }
            }
            .padding()
            .background(
                LinearGradient(
                    colors: [Color.orange, Color.red],
                    startPoint: .leading,
                    endPoint: .trailing
                )
            )
            .shadow(color: Color.black.opacity(0.2), radius: 5, y: 2)
            
            Spacer()
        }
        .transition(.move(edge: .top))
    }
    
    // MARK: - Check Business Setup
    private func checkBusinessSetup() {
        guard let userId = authManager.currentUser?.uid else {
            isCheckingSetup = false
            return
        }
        
        let db = Firestore.firestore()
        db.collection(Constant.businessesCollection)
            .whereField("businessId", isEqualTo: userId)
            .getDocuments { snapshot, error in
                DispatchQueue.main.async {
                    isCheckingSetup = false
                    
                    if let error = error {
                        // Error, but show dashboard anyway
                        needsSetup = true
                        return
                    }
                    
                    if let documents = snapshot?.documents, !documents.isEmpty {
                        // Business listing exists, dashboard is ready
                        businessListing = try? documents.first?.data(as: BusinessListing.self)
                        needsSetup = false
                    } else {
                        // No business listing, needs setup
                        needsSetup = true
                        showSetupWizard = true
                    }
                }
            }
    }
}

#Preview {
    BusinessDashboardScene()
        .environmentObject(AuthManager.shared)
        .environmentObject(SceneDelegate.shared)
}

