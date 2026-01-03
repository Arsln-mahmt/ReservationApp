//
//  BusinessSetupWizardScene.swift
//  ReservationApp
//
//  İşletme kurulum sihirbazı
//

import SwiftUI
import PhotosUI
import FirebaseFirestore


struct BusinessSetupWizardScene: View {
    @StateObject private var viewModel: BusinessSetupWizardViewModel
    @EnvironmentObject var sceneDelegate: SceneDelegate
    @Environment(\.dismiss) var dismiss
    
    init(user: User) {
        _viewModel = StateObject(wrappedValue: BusinessSetupWizardViewModel(user: user))
    }
    
    var body: some View {
        NavigationStack {
            ZStack {
                Color.bgPrimary.ignoresSafeArea()
                
                VStack(spacing: 0) {
                    // Progress bar
                    progressBar
                    
                    // Current step content
                    currentStepView
                        .transition(.asymmetric(
                            insertion: .move(edge: .trailing),
                            removal: .move(edge: .leading)
                        ))
                    
                    // Navigation buttons
                    navigationButtons
                }
            }
            .navigationTitle("İşletme Kurulumu")
            .navigationBarTitleDisplayMode(.inline)
            .navigationBarBackButtonHidden(true)
            .alert("Kurulumdan Çık?", isPresented: $viewModel.showExitAlert) {
                Button("Vazgeç", role: .cancel) {}
                Button("Çık", role: .destructive) {
                    dismiss()
                }
            } message: {
                Text("Kurulum tamamlanmadan çıkarsanız değişiklikler kaydedilmeyecek.")
            }
            .alert("Hata", isPresented: $viewModel.showError) {
                Button("Tamam", role: .cancel) {}
            } message: {
                Text(viewModel.errorMessage)
            }
        }
    }
    
    // MARK: - Progress Bar
    private var progressBar: some View {
        VStack(spacing: 12) {
            // Step indicators
            HStack(spacing: 0) {
                ForEach(0..<4) { index in
                    HStack(spacing: 0) {
                        Circle()
                            .fill(index <= viewModel.currentStep ? LinearGradient.primaryGradient : LinearGradient(colors: [.gray.opacity(0.3), .gray.opacity(0.3)], startPoint: .leading, endPoint: .trailing))
                            .frame(width: 32, height: 32)
                            .overlay(
                                Text("\(index + 1)")
                                    .font(.caption)
                                    .fontWeight(.bold)
                                    .foregroundColor(.white)
                            )
                        
                        if index < 3 {
                            Rectangle()
                                .fill(index < viewModel.currentStep ? LinearGradient.primaryGradient : LinearGradient(colors: [.gray.opacity(0.3), .gray.opacity(0.3)], startPoint: .leading, endPoint: .trailing))
                                .frame(height: 2)
                        }
                    }
                }
            }
            .padding(.horizontal, 40)
            
            // Step title
            Text(viewModel.stepTitle)
                .font(.subheadline)
                .fontWeight(.semibold)
                .foregroundColor(.textPrimary)
        }
        .padding(.vertical, 20)
        .background(Color.bgSecondary)
    }
    
    // MARK: - Current Step View
    @ViewBuilder
    private var currentStepView: some View {
        ScrollView {
            VStack(spacing: 24) {
                switch viewModel.currentStep {
                case 0:
                    PhotoUploadStep(viewModel: viewModel)
                case 1:
                    ServicesStep(viewModel: viewModel)
                case 2:
                    WorkingHoursStep(viewModel: viewModel)
                case 3:
                    PreviewStep(viewModel: viewModel)
                default:
                    EmptyView()
                }
            }
            .padding(20)
        }
    }
    
    // MARK: - Navigation Buttons
    private var navigationButtons: some View {
        HStack(spacing: 16) {
            // Back button
            if viewModel.currentStep > 0 {
                Button(action: {
                    withAnimation {
                        viewModel.previousStep()
                    }
                }) {
                    HStack {
                        Image(systemName: "chevron.left")
                        Text("Geri")
                    }
                    .font(.headline)
                    .foregroundColor(.primaryOrange)
                    .frame(maxWidth: .infinity)
                    .padding()
                    .background(Color.primaryOrange.opacity(0.1))
                    .cornerRadius(12)
                }
            } else {
                Button(action: {
                    viewModel.showExitAlert = true
                }) {
                    Text("Vazgeç")
                        .font(.headline)
                        .foregroundColor(.red)
                        .frame(maxWidth: .infinity)
                        .padding()
                        .background(Color.red.opacity(0.1))
                        .cornerRadius(12)
                }
            }
            
            // Next/Publish button
            Button(action: {
                if viewModel.currentStep < 3 {
                    withAnimation {
                        viewModel.nextStep()
                    }
                } else {
                    viewModel.publishBusiness {
                        dismiss()
                    }
                }
            }) {
                HStack {
                    if viewModel.isPublishing {
                        ProgressView()
                            .progressViewStyle(.circular)
                            .tint(.white)
                    } else {
                        if viewModel.currentStep < 3 {
                            Text("İleri")
                            Image(systemName: "chevron.right")
                        } else {
                            Text(viewModel.isExistingBusiness ? "💾 Güncelle" : "🚀 Yayınla")
                        }
                    }
                }
                .font(.headline)
                .foregroundColor(.white)
                .frame(maxWidth: .infinity)
                .padding()
                .background(LinearGradient.primaryGradient)
                .cornerRadius(12)
            }
            .disabled(viewModel.isPublishing || !viewModel.canProceed)
            .opacity(viewModel.canProceed ? 1.0 : 0.5)
        }
        .padding(20)
        .background(Color.bgSecondary)
    }
}

// MARK: - Step 1: Photo Upload
struct PhotoUploadStep: View {
    @ObservedObject var viewModel: BusinessSetupWizardViewModel
    @State private var showImagePicker = false
    
    var body: some View {
        VStack(spacing: 24) {
            Text("İşletme Fotoğrafı")
                .font(.title2)
                .fontWeight(.bold)
                .foregroundColor(.textPrimary)
            
            Text("İşletmenizin kapak fotoğrafını yükleyin. İyi bir fotoğraf müşteri çekmenize yardımcı olur.")
                .font(.subheadline)
                .foregroundColor(.textSecondary)
                .multilineTextAlignment(.center)
            
            // Image preview
            Button(action: {
                showImagePicker = true
            }) {
                ZStack {
                    if let image = viewModel.businessImage {
                        Image(uiImage: image)
                            .resizable()
                            .aspectRatio(contentMode: .fill)
                            .frame(height: 200)
                            .clipped()
                            .cornerRadius(16)
                    } else {
                        RoundedRectangle(cornerRadius: 16)
                            .fill(LinearGradient.primaryGradient.opacity(0.1))
                            .frame(height: 200)
                            .overlay(
                                VStack(spacing: 12) {
                                    Image(systemName: "photo.badge.plus")
                                        .font(.system(size: 50))
                                        .foregroundColor(.primaryOrange)
                                    
                                    Text(viewModel.existingImageURL != nil ? "Resmi Değiştir" : "Fotoğraf Seç")
                                        .font(.headline)
                                        .foregroundColor(.primaryOrange)
                                }
                            )
                    }
                }
            }
            .sheet(isPresented: $showImagePicker) {
                ImagePicker(image: Binding(
                    get: { viewModel.businessImage },
                    set: { newImage in
                        viewModel.businessImage = newImage
                        viewModel.shouldDeleteImage = false // Reset delete flag when new image selected
                    }
                ))
            }
            
            if viewModel.businessImage != nil {
                HStack(spacing: 12) {
                    // Change image button
                    Button(action: {
                        showImagePicker = true
                    }) {
                        HStack {
                            Image(systemName: "arrow.triangle.2.circlepath")
                            Text("Değiştir")
                        }
                        .font(.subheadline)
                        .foregroundColor(.primaryOrange)
                        .padding(.horizontal, 16)
                        .padding(.vertical, 8)
                        .background(Color.primaryOrange.opacity(0.1))
                        .cornerRadius(8)
                    }
                    
                    // Remove image button
                    Button(action: {
                        viewModel.businessImage = nil
                        viewModel.existingImageURL = nil
                        viewModel.shouldDeleteImage = true
                    }) {
                        HStack {
                            Image(systemName: "trash")
                            Text("Kaldır")
                        }
                        .font(.subheadline)
                        .foregroundColor(.red)
                        .padding(.horizontal, 16)
                        .padding(.vertical, 8)
                        .background(Color.red.opacity(0.1))
                        .cornerRadius(8)
                    }
                }
            }
            
            Divider()
                .padding(.vertical)
            
            Text("💡 İpucu: Aydınlık ve net bir fotoğraf kullanın")
                .font(.caption)
                .foregroundColor(.textSecondary)
                .padding()
                .frame(maxWidth: .infinity)
                .background(Color.blue.opacity(0.1))
                .cornerRadius(12)
        }
    }
}

// MARK: - Step 2: Services
struct ServicesStep: View {
    @ObservedObject var viewModel: BusinessSetupWizardViewModel
    @State private var showAddService = false
    
    var body: some View {
        VStack(spacing: 24) {
            Text("Hizmetleriniz")
                .font(.title2)
                .fontWeight(.bold)
                .foregroundColor(.textPrimary)
            
            Text("Sunduğunuz hizmetleri ekleyin. Müşteriler bu hizmetlerden birini seçerek randevu alabilir.")
                .font(.subheadline)
                .foregroundColor(.textSecondary)
                .multilineTextAlignment(.center)
            
            // Services list
            if viewModel.services.isEmpty {
                emptyServicesView
            } else {
                servicesListView
            }
            
            // Add service button
            Button(action: {
                showAddService = true
            }) {
                HStack {
                    Image(systemName: "plus.circle.fill")
                    Text("Yeni Hizmet Ekle")
                }
                .font(.headline)
                .foregroundColor(.primaryOrange)
                .frame(maxWidth: .infinity)
                .padding()
                .background(Color.primaryOrange.opacity(0.1))
                .cornerRadius(12)
            }
            .sheet(isPresented: $showAddService) {
                SetupAddServiceSheet(services: $viewModel.services)
            }
        }
    }
    
    private var emptyServicesView: some View {
        VStack(spacing: 16) {
            Image(systemName: "scissors")
                .font(.system(size: 60))
                .foregroundColor(.textLight)
            
            Text("Henüz hizmet eklenmedi")
                .font(.headline)
                .foregroundColor(.textSecondary)
            
            Text("En az bir hizmet eklemelisiniz")
                .font(.subheadline)
                .foregroundColor(.textLight)
        }
        .frame(maxWidth: .infinity)
        .padding(40)
        .background(Color.bgCard)
        .cornerRadius(16)
    }
    
    private var servicesListView: some View {
        VStack(spacing: 12) {
            ForEach(viewModel.services) { service in
                ServiceRow(service: service) {
                    // Track deleted service ID if it exists in Firestore
                    if let firestoreId = service.firestoreId {
                        viewModel.deletedServiceIds.insert(firestoreId)
                    }
                    // Remove from UI
                    viewModel.services.removeAll { $0.id == service.id }
                }
            }
        }
    }
}

// MARK: - Service Row
struct ServiceRow: View {
    let service: ServiceSetupItem
    let onDelete: () -> Void
    
    var body: some View {
        HStack(spacing: 16) {
            VStack(alignment: .leading, spacing: 4) {
                Text(service.name)
                    .font(.headline)
                    .foregroundColor(.textPrimary)
                
                HStack {
                    Text("\(service.duration) dk")
                        .font(.caption)
                        .foregroundColor(.textSecondary)
                    
                    Text("•")
                        .foregroundColor(.textLight)
                    
                    Text("₺\(Int(service.price))")
                        .font(.caption)
                        .fontWeight(.semibold)
                        .foregroundColor(.primaryOrange)
                }
            }
            
            Spacer()
            
            Button(action: onDelete) {
                Image(systemName: "trash")
                    .foregroundColor(.red)
            }
        }
        .padding()
        .background(Color.bgCard)
        .cornerRadius(12)
    }
}

// MARK: - Step 3: Working Hours
struct WorkingHoursStep: View {
    @ObservedObject var viewModel: BusinessSetupWizardViewModel
    
    var body: some View {
        VStack(spacing: 24) {
            Text("Çalışma Saatleri")
                .font(.title2)
                .fontWeight(.bold)
                .foregroundColor(.textPrimary)
            
            Text("İşletmenizin hangi saatlerde açık olduğunu belirtin. (İsteğe bağlı, sonra da düzenleyebilirsiniz)")
                .font(.subheadline)
                .foregroundColor(.textSecondary)
                .multilineTextAlignment(.center)
            
            VStack(spacing: 12) {
                ForEach(viewModel.weekDays, id: \.self) { day in
                    WorkingHourRow(
                        day: day,
                        isOpen: viewModel.workingHours[day]?.isOpen ?? false,
                        openTime: viewModel.workingHours[day]?.openTime ?? "09:00",
                        closeTime: viewModel.workingHours[day]?.closeTime ?? "18:00",
                        onToggle: { isOpen in
                            viewModel.toggleDay(day, isOpen: isOpen)
                        },
                        onTimeChange: { openTime, closeTime in
                            viewModel.updateWorkingHours(day, openTime: openTime, closeTime: closeTime)
                        }
                    )
                }
            }
        }
    }
}

// MARK: - Working Hour Row
struct WorkingHourRow: View {
    let day: String
    let isOpen: Bool
    let openTime: String
    let closeTime: String
    let onToggle: (Bool) -> Void
    let onTimeChange: (String, String) -> Void
    
    @State private var showTimePicker = false
    
    var body: some View {
        VStack(spacing: 12) {
            HStack {
                Text(day)
                    .font(.subheadline)
                    .fontWeight(.medium)
                    .foregroundColor(.textPrimary)
                
                Spacer()
                
                Toggle("", isOn: Binding(
                    get: { isOpen },
                    set: { onToggle($0) }
                ))
                .labelsHidden()
            }
            
            if isOpen {
                HStack(spacing: 16) {
                    Text("\(openTime) - \(closeTime)")
                        .font(.subheadline)
                        .foregroundColor(.textSecondary)
                    
                    Spacer()
                    
                    Button(action: {
                        showTimePicker = true
                    }) {
                        Text("Düzenle")
                            .font(.caption)
                            .foregroundColor(.primaryOrange)
                    }
                }
            }
        }
        .padding()
        .background(Color.bgCard)
        .cornerRadius(12)
        .sheet(isPresented: $showTimePicker) {
            TimePickerSheet(
                day: day,
                openTime: openTime,
                closeTime: closeTime,
                onSave: onTimeChange
            )
        }
    }
}

// MARK: - Step 4: Preview
struct PreviewStep: View {
    @ObservedObject var viewModel: BusinessSetupWizardViewModel
    
    var body: some View {
        VStack(spacing: 24) {
            Text("Önizleme")
                .font(.title2)
                .fontWeight(.bold)
                .foregroundColor(.textPrimary)
            
            Text("Her şey hazır! Aşağıda işletmenizin nasıl görüneceğini görebilirsiniz.")
                .font(.subheadline)
                .foregroundColor(.textSecondary)
                .multilineTextAlignment(.center)
            
            // Business preview card
            VStack(alignment: .leading, spacing: 16) {
                // Image
                if let image = viewModel.businessImage {
                    Image(uiImage: image)
                        .resizable()
                        .aspectRatio(contentMode: .fill)
                        .frame(height: 180)
                        .clipped()
                        .cornerRadius(12)
                } else {
                    Rectangle()
                        .fill(LinearGradient.primaryGradient.opacity(0.3))
                        .frame(height: 180)
                        .cornerRadius(12)
                        .overlay(
                            Image(systemName: "building.2.fill")
                                .font(.system(size: 50))
                                .foregroundColor(.primaryOrange.opacity(0.5))
                        )
                }
                
                // Business info
                VStack(alignment: .leading, spacing: 8) {
                    Text(viewModel.user.businessName ?? "İşletme Adı")
                        .font(.title3)
                        .fontWeight(.bold)
                        .foregroundColor(.textPrimary)
                    
                    Text(viewModel.user.businessCategory ?? "Kategori")
                        .font(.subheadline)
                        .foregroundColor(.textSecondary)
                    
                    HStack {
                        Image(systemName: "location.fill")
                            .font(.caption)
                        Text(viewModel.user.businessAddress ?? "Adres")
                            .font(.caption)
                    }
                    .foregroundColor(.textSecondary)
                }
                .padding(.horizontal, 12)
                
                // Services count
                HStack {
                    Image(systemName: "wrench.and.screwdriver")
                        .foregroundColor(.primaryOrange)
                    Text("\(viewModel.services.count) Hizmet")
                        .font(.subheadline)
                        .foregroundColor(.textPrimary)
                }
                .padding(.horizontal, 12)
                .padding(.bottom, 12)
            }
            .background(Color.bgCard)
            .cornerRadius(16)
            .shadow(color: Color.black.opacity(0.05), radius: 8, y: 2)
            
            // Info
            Text(viewModel.isExistingBusiness ? 
                 "✨ Güncelle butonuna basarak değişikliklerinizi kaydedin." :
                 "✨ Harika görünüyor! Yayınla butonuna basarak işletmenizi aktif edin.")
                .font(.caption)
                .foregroundColor(.textSecondary)
                .padding()
                .frame(maxWidth: .infinity)
                .background(Color.green.opacity(0.1))
                .cornerRadius(12)
        }
    }
}

#Preview {
    BusinessSetupWizardScene(user: User(
        id: "1",
        uid: "test",
        email: "test@test.com",
        name: "Test User",
        phoneNumber: "555",
        phoneVerified: false,
        userType: .business,
        profileImageURL: nil,
        createdAt: Timestamp(),
        updatedAt: nil,
        businessName: "Test Business",
        businessAddress: "Test Address",
        businessCategory: "Test Category",
        businessDescription: nil,
        workingHours: nil
    ))
    .environmentObject(SceneDelegate.shared)
}

