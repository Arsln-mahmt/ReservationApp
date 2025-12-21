//
//  BusinessSettingsScene.swift
//  ReservationApp
//
//  Created by Mahmut Arslan on 25.10.2025.
//

import SwiftUI
import Combine
import FirebaseFirestore

struct BusinessSettingsScene: View {
    @EnvironmentObject var authManager: AuthManager
    @EnvironmentObject var sceneDelegate: SceneDelegate
    @EnvironmentObject var appEnvironment: AppEnvironment
    @State private var showLogoutAlert = false
    @State private var showBusinessInfoSheet = false
    @State private var showWorkingHoursSheet = false
    @State private var showServicesSheet = false
    @State private var showStaffSheet = false
    
    // Parameters from parent
    var needsSetup: Bool = false
    var onOpenSetup: (() -> Void)? = nil
    
    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(spacing: 24) {
                    // Setup Warning (if not published)
                    if needsSetup {
                        setupWarningCard
                    }
                    
                    // Business Info Section
                    businessInfoSection
                    
                    // Management Section
                    managementSection
                    
                    // Account Section
                    accountSection
                }
                .padding(20)
            }
            .background(Color.bgPrimary)
            .navigationTitle("Ayarlar")
            .navigationBarTitleDisplayMode(.large)
            .alert("Çıkış Yap", isPresented: $showLogoutAlert) {
                Button("İptal", role: .cancel) {}
                Button("Çıkış Yap", role: .destructive) {
                    authManager.signOut()
                    appEnvironment.isAuthenticated = false
                    appEnvironment.currentUser = nil
                    sceneDelegate.navigateTo(.mainApp)
                }
            } message: {
                Text("Çıkış yapmak istediğinize emin misiniz?")
            }
            .sheet(isPresented: $showBusinessInfoSheet) {
                BusinessInfoEditSheet()
            }
            .sheet(isPresented: $showWorkingHoursSheet) {
                WorkingHoursSheet()
            }
            .sheet(isPresented: $showServicesSheet) {
                ServicesManagementSheet()
            }
            .sheet(isPresented: $showStaffSheet) {
                StaffManagementSheet()
            }
        }
    }
    
    // MARK: - Setup Warning Card
    private var setupWarningCard: some View {
        VStack(spacing: 16) {
            HStack {
                Image(systemName: "exclamationmark.triangle.fill")
                    .font(.title)
                    .foregroundColor(.orange)
                
                VStack(alignment: .leading, spacing: 4) {
                    Text("İşletmeniz Yayında Değil")
                        .font(.headline)
                        .foregroundColor(.textPrimary)
                    
                    Text("Kurulumu tamamlayarak işletmenizi yayınlayın ve müşterilere ulaşın.")
                        .font(.caption)
                        .foregroundColor(.textSecondary)
                }
                
                Spacer()
            }
            
            Button(action: {
                onOpenSetup?()
            }) {
                HStack {
                    Image(systemName: "wrench.and.screwdriver.fill")
                    Text("Kurulumu Tamamla")
                }
                .font(.headline)
                .foregroundColor(.white)
                .frame(maxWidth: .infinity)
                .padding()
                .background(LinearGradient.primaryGradient)
                .cornerRadius(12)
            }
        }
        .padding()
        .background(Color.orange.opacity(0.1))
        .cornerRadius(16)
    }
    
    // MARK: - Business Info Section
    private var businessInfoSection: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("İşletme Bilgileri")
                .font(.headline)
                .foregroundColor(.textPrimary)
            
            VStack(spacing: 0) {
                // Setup Wizard Button
                SettingsRow(
                    icon: "wrench.and.screwdriver.fill",
                    title: "İşletme Kurulumu",
                    value: needsSetup ? "Tamamlanmadı" : "Düzenle",
                    valueColor: needsSetup ? .orange : .primaryOrange,
                    action: { onOpenSetup?() }
                )
                
                Divider().padding(.leading, 50)
                
                SettingsRow(
                    icon: "building.2.fill",
                    title: "İşletme Adı",
                    value: authManager.currentUser?.businessName,
                    action: { showBusinessInfoSheet = true }
                )
                
                Divider().padding(.leading, 50)
                
                SettingsRow(
                    icon: "tag.fill",
                    title: "Kategori",
                    value: authManager.currentUser?.businessCategory,
                    action: { showBusinessInfoSheet = true }
                )
                
                Divider().padding(.leading, 50)
                
                SettingsRow(
                    icon: "location.fill",
                    title: "Adres",
                    value: authManager.currentUser?.businessAddress,
                    action: { showBusinessInfoSheet = true }
                )
                
                Divider().padding(.leading, 50)
                
                SettingsRow(
                    icon: "phone.fill",
                    title: "Telefon",
                    value: authManager.currentUser?.phoneNumber,
                    action: { showBusinessInfoSheet = true }
                )
            }
            .background(Color.bgCard)
            .cornerRadius(16)
        }
    }
    
    // MARK: - Management Section
    private var managementSection: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("Yönetim")
                .font(.headline)
                .foregroundColor(.textPrimary)
            
            VStack(spacing: 0) {
                SettingsButton(
                    icon: "clock.fill",
                    title: "Çalışma Saatleri",
                    subtitle: "Açılış ve kapanış saatlerini ayarlayın",
                    action: { showWorkingHoursSheet = true }
                )
                
                Divider().padding(.leading, 50)
                
                SettingsButton(
                    icon: "scissors",
                    title: "Hizmetler",
                    subtitle: "Sunduğunuz hizmetleri yönetin",
                    action: { showServicesSheet = true }
                )
                
                Divider().padding(.leading, 50)
                
                SettingsButton(
                    icon: "person.2.fill",
                    title: "Personel",
                    subtitle: "Çalışanlarınızı yönetin",
                    action: { showStaffSheet = true }
                )
                
                Divider().padding(.leading, 50)
                
                SettingsButton(
                    icon: "calendar.badge.clock",
                    title: "Müsaitlik",
                    subtitle: "Randevu alınabilir saatleri ayarlayın",
                    action: {}
                )
            }
            .background(Color.bgCard)
            .cornerRadius(16)
        }
    }
    
    // MARK: - Account Section
    private var accountSection: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("Hesap")
                .font(.headline)
                .foregroundColor(.textPrimary)
            
            VStack(spacing: 0) {
                SettingsButton(
                    icon: "bell.fill",
                    title: "Bildirimler",
                    subtitle: "Bildirim ayarlarını yönetin",
                    action: {}
                )
                
                Divider().padding(.leading, 50)
                
                SettingsButton(
                    icon: "lock.fill",
                    title: "Gizlilik",
                    subtitle: "Gizlilik ve güvenlik ayarları",
                    action: {}
                )
            }
            .background(Color.bgCard)
            .cornerRadius(16)
            
            // Logout Button
            Button(action: {
                showLogoutAlert = true
            }) {
                HStack {
                    Image(systemName: "rectangle.portrait.and.arrow.right")
                        .foregroundColor(.red)
                    Text("Çıkış Yap")
                        .foregroundColor(.red)
                        .fontWeight(.semibold)
                }
                .frame(maxWidth: .infinity)
                .padding()
                .background(Color.red.opacity(0.1))
                .cornerRadius(12)
            }
            .padding(.top, 12)
        }
    }
}

// MARK: - Settings Row
struct SettingsRow: View {
    let icon: String
    let title: String
    let value: String?
    var valueColor: Color = .textSecondary
    let action: () -> Void
    
    var body: some View {
        Button(action: action) {
            HStack(spacing: 16) {
                Image(systemName: icon)
                    .font(.title3)
                    .foregroundColor(.primaryOrange)
                    .frame(width: 30)
                
                VStack(alignment: .leading, spacing: 4) {
                    Text(title)
                        .font(.subheadline)
                        .foregroundColor(.textPrimary)
                    
                    if let value = value {
                        Text(value)
                            .font(.caption)
                            .foregroundColor(valueColor)
                            .lineLimit(1)
                    }
                }
                
                Spacer()
                
                Image(systemName: "chevron.right")
                    .font(.caption)
                    .foregroundColor(.textLight)
            }
            .padding()
        }
    }
}

// MARK: - Settings Button
struct SettingsButton: View {
    let icon: String
    let title: String
    let subtitle: String?
    let action: () -> Void
    
    var body: some View {
        Button(action: action) {
            HStack(spacing: 16) {
                Image(systemName: icon)
                    .font(.title3)
                    .foregroundColor(.primaryOrange)
                    .frame(width: 30)
                
                VStack(alignment: .leading, spacing: 4) {
                    Text(title)
                        .font(.subheadline)
                        .foregroundColor(.textPrimary)
                    
                    if let subtitle = subtitle {
                        Text(subtitle)
                            .font(.caption)
                            .foregroundColor(.textSecondary)
                            .lineLimit(1)
                    }
                }
                
                Spacer()
                
                Image(systemName: "chevron.right")
                    .font(.caption)
                    .foregroundColor(.textLight)
            }
            .padding()
        }
    }
}

// MARK: - Placeholder Sheets
struct BusinessInfoEditSheet: View {
    @Environment(\.dismiss) var dismiss
    
    var body: some View {
        NavigationStack {
            Text("İşletme Bilgileri Düzenleme")
                .navigationTitle("Bilgilerim")
                .toolbar {
                    ToolbarItem(placement: .navigationBarTrailing) {
                        Button("Kapat") { dismiss() }
                    }
                }
        }
    }
}

struct WorkingHoursSheet: View {
    @Environment(\.dismiss) var dismiss
    
    var body: some View {
        NavigationStack {
            Text("Çalışma Saatleri")
                .navigationTitle("Çalışma Saatleri")
                .toolbar {
                    ToolbarItem(placement: .navigationBarTrailing) {
                        Button("Kapat") { dismiss() }
                    }
                }
        }
    }
}

struct ServicesManagementSheet: View {
    @Environment(\.dismiss) var dismiss
    @StateObject private var viewModel = ServicesManagementViewModel()
    @State private var showAddService = false
    
    var body: some View {
        NavigationStack {
            ZStack {
                Color.bgPrimary.ignoresSafeArea()
                
                if viewModel.isLoading {
                    ProgressView()
                } else if viewModel.services.isEmpty {
                    emptyView
                } else {
                    servicesList
                }
            }
            .navigationTitle("Hizmetler")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button("Kapat") { dismiss() }
                }
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button(action: { showAddService = true }) {
                        Image(systemName: "plus")
                    }
                }
            }
            .sheet(isPresented: $showAddService) {
                AddServiceSheet(onSave: { name, description, duration, price in
                    viewModel.addService(name: name, description: description, duration: duration, price: price)
                    showAddService = false
                })
            }
        }
    }
    
    private var emptyView: some View {
        VStack(spacing: 16) {
            Image(systemName: "scissors")
                .font(.system(size: 60))
                .foregroundColor(.textLight)
            
            Text("Henüz Hizmet Yok")
                .font(.title3)
                .fontWeight(.semibold)
                .foregroundColor(.textPrimary)
            
            Text("Müşterilerinize sunduğunuz hizmetleri ekleyin")
                .font(.subheadline)
                .foregroundColor(.textSecondary)
                .multilineTextAlignment(.center)
                .padding(.horizontal, 40)
            
            Button(action: { showAddService = true }) {
                Text("Hizmet Ekle")
                    .font(.headline)
                    .foregroundColor(.white)
                    .padding(.horizontal, 32)
                    .padding(.vertical, 12)
                    .background(LinearGradient.primaryGradient)
                    .cornerRadius(12)
            }
        }
    }
    
    private var servicesList: some View {
        ScrollView {
            LazyVStack(spacing: 12) {
                ForEach(viewModel.services) { service in
                    ServiceManagementCard(service: service) {
                        viewModel.toggleServiceStatus(service: service)
                    }
                }
            }
            .padding(20)
        }
    }
}

// MARK: - Services Management ViewModel
class ServicesManagementViewModel: ObservableObject {
    @Published var services: [Service] = []
    @Published var isLoading = false
    
    private let serviceManager = ServiceManager.shared
    private let authManager = AuthManager.shared
    
    init() {
        loadServices()
    }
    
    func loadServices() {
        guard let businessId = authManager.currentUser?.uid else {
            print("❌ No business user logged in")
            return
        }
        
        isLoading = true
        
        serviceManager.getServices(businessId: businessId) { [weak self] result in
            DispatchQueue.main.async {
                self?.isLoading = false
                
                switch result {
                case .success(let services):
                    self?.services = services
                    print("✅ Loaded \(services.count) services")
                    
                case .failure(let error):
                    print("❌ Failed to load services: \(error)")
                    self?.services = []
                }
            }
        }
    }
    
    func addService(name: String, description: String?, duration: Int, price: Double) {
        guard let businessId = authManager.currentUser?.uid else { return }
        
        serviceManager.createService(
            businessId: businessId,
            name: name,
            description: description,
            duration: duration,
            price: price
        ) { [weak self] result in
            switch result {
            case .success:
                print("✅ Service added successfully")
                self?.loadServices()
            case .failure(let error):
                print("❌ Failed to add service: \(error)")
            }
        }
    }
    
    func toggleServiceStatus(service: Service) {
        guard let serviceId = service.id else { return }
        
        serviceManager.updateService(
            serviceId: serviceId,
            isActive: !service.isActive
        ) { [weak self] result in
            switch result {
            case .success:
                print("✅ Service status toggled")
                self?.loadServices()
            case .failure(let error):
                print("❌ Failed to toggle service: \(error)")
            }
        }
    }
}

// MARK: - Service Management Card
struct ServiceManagementCard: View {
    let service: Service
    let onToggle: () -> Void
    
    var body: some View {
        HStack {
            VStack(alignment: .leading, spacing: 6) {
                Text(service.name)
                    .font(.headline)
                    .foregroundColor(.textPrimary)
                
                if let description = service.description {
                    Text(description)
                        .font(.caption)
                        .foregroundColor(.textSecondary)
                        .lineLimit(2)
                }
                
                HStack(spacing: 16) {
                    HStack(spacing: 4) {
                        Image(systemName: "clock")
                            .font(.caption2)
                        Text("\(service.duration) dk")
                            .font(.caption)
                    }
                    .foregroundColor(.textSecondary)
                    
                    Text("₺\(Int(service.price))")
                        .font(.subheadline)
                        .fontWeight(.semibold)
                        .foregroundColor(.primaryOrange)
                }
            }
            
            Spacer()
            
            Toggle("", isOn: .constant(service.isActive))
                .labelsHidden()
                .onChange(of: service.isActive) { _ in
                    onToggle()
                }
        }
        .padding()
        .background(Color.bgCard)
        .cornerRadius(12)
    }
}

// MARK: - Add Service Sheet
struct AddServiceSheet: View {
    @Environment(\.dismiss) var dismiss
    let onSave: (String, String?, Int, Double) -> Void
    
    @State private var name = ""
    @State private var description = ""
    @State private var duration = "30"
    @State private var price = ""
    
    var body: some View {
        NavigationStack {
            Form {
                Section("Hizmet Bilgileri") {
                    TextField("Hizmet Adı", text: $name)
                    TextField("Açıklama (Opsiyonel)", text: $description)
                }
                
                Section("Detaylar") {
                    HStack {
                        Text("Süre (dakika)")
                        Spacer()
                        TextField("30", text: $duration)
                            .keyboardType(.numberPad)
                            .multilineTextAlignment(.trailing)
                            .frame(width: 80)
                    }
                    
                    HStack {
                        Text("Fiyat (₺)")
                        Spacer()
                        TextField("0", text: $price)
                            .keyboardType(.decimalPad)
                            .multilineTextAlignment(.trailing)
                            .frame(width: 100)
                    }
                }
            }
            .navigationTitle("Yeni Hizmet")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button("İptal") { dismiss() }
                }
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("Kaydet") {
                        guard !name.isEmpty,
                              let durationInt = Int(duration),
                              let priceDouble = Double(price) else { return }
                        
                        onSave(name, description.isEmpty ? nil : description, durationInt, priceDouble)
                    }
                    .disabled(name.isEmpty || duration.isEmpty || price.isEmpty)
                }
            }
        }
    }
}

struct StaffManagementSheet: View {
    @Environment(\.dismiss) var dismiss
    
    var body: some View {
        NavigationStack {
            Text("Personel Yönetimi")
                .navigationTitle("Personel")
                .toolbar {
                    ToolbarItem(placement: .navigationBarTrailing) {
                        Button("Kapat") { dismiss() }
                    }
                }
        }
    }
}

#Preview {
    BusinessSettingsScene()
        .environmentObject(AuthManager.shared)
        .environmentObject(SceneDelegate.shared)
        .environmentObject(AppEnvironment.shared)
}



