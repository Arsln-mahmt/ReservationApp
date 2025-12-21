//
//  BusinessOverviewScene.swift
//  ReservationApp
//
//  Created by Mahmut Arslan on 25.10.2025.
//

import SwiftUI

struct BusinessOverviewScene: View {
    @EnvironmentObject var authManager: AuthManager
    @StateObject private var viewModel = BusinessOverviewViewModel()
    @State private var showServicesSheet = false
    @State private var showTestDataSheet = false
    
    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(spacing: 20) {
                    // Business Header
                    businessHeader
                    
                    // Stats Cards
                    statsSection
                    
                    // Quick Actions
                    quickActionsSection
                    
                    // Today's Appointments
                    todayAppointmentsSection
                }
                .padding(20)
            }
            .background(Color.bgPrimary)
            .navigationTitle("Ana Sayfa")
            .navigationBarTitleDisplayMode(.large)
            .sheet(isPresented: $showServicesSheet) {
                ServicesManagementSheet()
            }
            .sheet(isPresented: $showTestDataSheet) {
                TestDataSetupSheet()
            }
            .refreshable {
                viewModel.loadStats()
            }
        }
    }
    
    // MARK: - Business Header
    private var businessHeader: some View {
        VStack(spacing: 12) {
            ZStack {
                Circle()
                    .fill(LinearGradient.primaryGradient)
                    .frame(width: 80, height: 80)
                
                Text((authManager.currentUser?.businessName ?? "İşletme").prefix(1))
                    .font(.system(size: 36))
                    .fontWeight(.bold)
                    .foregroundColor(.white)
            }
            
            Text(authManager.currentUser?.businessName ?? "İşletme")
                .font(.title2)
                .fontWeight(.bold)
                .foregroundColor(.textPrimary)
            
            Text(authManager.currentUser?.businessCategory ?? "")
                .font(.subheadline)
                .foregroundColor(.textSecondary)
        }
        .frame(maxWidth: .infinity)
        .padding(.vertical, 20)
        .background(Color.bgCard)
        .cornerRadius(16)
    }
    
    // MARK: - Stats Section
    private var statsSection: some View {
        LazyVGrid(columns: [GridItem(.flexible()), GridItem(.flexible())], spacing: 16) {
            StatCard(
                title: "Bugünkü Randevular",
                value: "\(viewModel.todayAppointments)",
                icon: "calendar.badge.clock",
                color: .primaryOrange
            )
            
            StatCard(
                title: "Bu Ay",
                value: "\(viewModel.monthlyAppointments)",
                icon: "chart.bar.fill",
                color: .green
            )
            
            StatCard(
                title: "Toplam Müşteri",
                value: "\(viewModel.totalCustomers)",
                icon: "person.3.fill",
                color: .blue
            )
            
            StatCard(
                title: "Ortalama Puan",
                value: String(format: "%.1f", viewModel.averageRating),
                icon: "star.fill",
                color: .accentYellow
            )
        }
    }
    
    // MARK: - Quick Actions
    private var quickActionsSection: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("Hızlı İşlemler")
                .font(.headline)
                .foregroundColor(.textPrimary)
            
            VStack(spacing: 12) {
                QuickActionButton(
                    title: "Hizmet Yönetimi",
                    icon: "scissors",
                    action: {
                        showServicesSheet = true
                    }
                )
                
                QuickActionButton(
                    title: "Test Verileri Ekle",
                    icon: "plus.circle.fill",
                    action: {
                        showTestDataSheet = true
                    }
                )
                
                QuickActionButton(
                    title: "İstatistikleri Yenile",
                    icon: "arrow.clockwise",
                    action: {
                        viewModel.loadStats()
                    }
                )
            }
        }
    }
    
    // MARK: - Today's Appointments
    private var todayAppointmentsSection: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("Bugünkü Randevular")
                .font(.headline)
                .foregroundColor(.textPrimary)
            
            if viewModel.todayAppointments == 0 {
                VStack(spacing: 8) {
                    Image(systemName: "calendar.badge.checkmark")
                        .font(.system(size: 40))
                        .foregroundColor(.textLight)
                    Text("Bugün randevunuz yok")
                        .font(.subheadline)
                        .foregroundColor(.textSecondary)
                }
                .frame(maxWidth: .infinity)
                .padding(.vertical, 40)
                .background(Color.bgCard)
                .cornerRadius(16)
            } else {
                Text("Randevularınızı görmek için Randevular sekmesine gidin")
                    .font(.caption)
                    .foregroundColor(.textSecondary)
                    .padding()
                    .background(Color.bgCard)
                    .cornerRadius(12)
            }
        }
    }
}

// MARK: - Stat Card
struct StatCard: View {
    let title: String
    let value: String
    let icon: String
    let color: Color
    
    var body: some View {
        VStack(spacing: 12) {
            ZStack {
                Circle()
                    .fill(color.opacity(0.15))
                    .frame(width: 50, height: 50)
                
                Image(systemName: icon)
                    .font(.title3)
                    .foregroundColor(color)
            }
            
            Text(value)
                .font(.title)
                .fontWeight(.bold)
                .foregroundColor(.textPrimary)
            
            Text(title)
                .font(.caption)
                .foregroundColor(.textSecondary)
                .multilineTextAlignment(.center)
        }
        .frame(maxWidth: .infinity)
        .padding()
        .background(Color.bgCard)
        .cornerRadius(16)
    }
}

// MARK: - Quick Action Button
struct QuickActionButton: View {
    let title: String
    let icon: String
    let action: () -> Void
    
    var body: some View {
        Button(action: action) {
            HStack {
                Image(systemName: icon)
                    .font(.title3)
                    .foregroundColor(.primaryOrange)
                    .frame(width: 30)
                
                Text(title)
                    .font(.subheadline)
                    .foregroundColor(.textPrimary)
                
                Spacer()
                
                Image(systemName: "chevron.right")
                    .font(.caption)
                    .foregroundColor(.textLight)
            }
            .padding()
            .background(Color.bgCard)
            .cornerRadius(12)
        }
    }
}

// MARK: - Test Data Setup Sheet
struct TestDataSetupSheet: View {
    @Environment(\.dismiss) var dismiss
    @EnvironmentObject var authManager: AuthManager
    @State private var isLoading = false
    @State private var showSuccessAlert = false
    @State private var showErrorAlert = false
    @State private var errorMessage = ""
    
    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(spacing: 20) {
                    // Info Section
                    VStack(alignment: .leading, spacing: 12) {
                        HStack {
                            Image(systemName: "info.circle.fill")
                                .foregroundColor(.blue)
                            Text("Test Verileri Hakkında")
                                .font(.headline)
                        }
                        
                        Text("Bu işlem işletmenize otomatik olarak örnek hizmetler ekleyecektir. Bu hizmetleri daha sonra düzenleyebilir veya silebilirsiniz.")
                            .font(.subheadline)
                            .foregroundColor(.textSecondary)
                            .fixedSize(horizontal: false, vertical: true)
                    }
                    .padding()
                    .background(Color.blue.opacity(0.1))
                    .cornerRadius(12)
                    
                    // Services List
                    VStack(alignment: .leading, spacing: 12) {
                        Text("Eklenecek Hizmetler:")
                            .font(.headline)
                            .foregroundColor(.textPrimary)
                        
                        VStack(spacing: 8) {
                            TestServiceRow(name: "Saç Kesimi", duration: 30, price: 150)
                            TestServiceRow(name: "Sakal Tıraşı", duration: 20, price: 75)
                            TestServiceRow(name: "Komple Bakım", duration: 60, price: 250)
                            TestServiceRow(name: "Yıkama", duration: 15, price: 50)
                            TestServiceRow(name: "Boya", duration: 90, price: 350)
                        }
                    }
                    .padding()
                    .background(Color.bgCard)
                    .cornerRadius(12)
                    
                    // Add Button
                    Button(action: {
                        addTestData()
                    }) {
                        if isLoading {
                            ProgressView()
                                .progressViewStyle(CircularProgressViewStyle(tint: .white))
                                .frame(maxWidth: .infinity)
                        } else {
                            Text("Test Verilerini Ekle")
                                .font(.headline)
                                .foregroundColor(.white)
                                .frame(maxWidth: .infinity)
                        }
                    }
                    .frame(height: 56)
                    .background(LinearGradient.primaryGradient)
                    .cornerRadius(12)
                    .disabled(isLoading)
                }
                .padding(20)
            }
            .background(Color.bgPrimary)
            .navigationTitle("Test Verileri")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button("Kapat") { dismiss() }
                }
            }
            .alert("Başarılı!", isPresented: $showSuccessAlert) {
                Button("Tamam") {
                    dismiss()
                }
            } message: {
                Text("Test hizmetleri başarıyla eklendi!")
            }
            .alert("Hata", isPresented: $showErrorAlert) {
                Button("Tamam", role: .cancel) {}
            } message: {
                Text(errorMessage)
            }
        }
    }
    
    private func addTestData() {
        guard let businessId = authManager.currentUser?.uid,
              let businessName = authManager.currentUser?.businessName else {
            errorMessage = "İşletme bilgileri bulunamadı"
            showErrorAlert = true
            return
        }
        
        isLoading = true
        
        TestDataHelper.shared.addTestServicesToBusiness(businessId: businessId) { [self] success in
            DispatchQueue.main.async {
                isLoading = false
                
                if success {
                    showSuccessAlert = true
                } else {
                    errorMessage = "Hizmetler eklenirken bir hata oluştu"
                    showErrorAlert = true
                }
            }
        }
    }
}

// MARK: - Test Service Row
struct TestServiceRow: View {
    let name: String
    let duration: Int
    let price: Double
    
    var body: some View {
        HStack {
            Image(systemName: "checkmark.circle.fill")
                .foregroundColor(.green)
            
            VStack(alignment: .leading, spacing: 4) {
                Text(name)
                    .font(.subheadline)
                    .foregroundColor(.textPrimary)
                
                HStack(spacing: 12) {
                    HStack(spacing: 4) {
                        Image(systemName: "clock")
                            .font(.caption2)
                        Text("\(duration) dk")
                            .font(.caption)
                    }
                    .foregroundColor(.textSecondary)
                    
                    Text("₺\(Int(price))")
                        .font(.caption)
                        .fontWeight(.semibold)
                        .foregroundColor(.primaryOrange)
                }
            }
            
            Spacer()
        }
        .padding(.vertical, 8)
    }
}

#Preview {
    BusinessOverviewScene()
        .environmentObject(AuthManager.shared)
}



