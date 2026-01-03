//
//  BusinessSetupHelpers.swift
//  ReservationApp
//
//  Kurulum yardımcı componentleri
//

import SwiftUI
import PhotosUI

// MARK: - Image Picker
struct ImagePicker: UIViewControllerRepresentable {
    @Binding var image: UIImage?
    @Environment(\.dismiss) var dismiss
    
    func makeUIViewController(context: Context) -> PHPickerViewController {
        var config = PHPickerConfiguration()
        config.filter = .images
        config.selectionLimit = 1
        
        let picker = PHPickerViewController(configuration: config)
        picker.delegate = context.coordinator
        return picker
    }
    
    func updateUIViewController(_ uiViewController: PHPickerViewController, context: Context) {}
    
    func makeCoordinator() -> Coordinator {
        Coordinator(self)
    }
    
    class Coordinator: NSObject, PHPickerViewControllerDelegate {
        let parent: ImagePicker
        
        init(_ parent: ImagePicker) {
            self.parent = parent
        }
        
        func picker(_ picker: PHPickerViewController, didFinishPicking results: [PHPickerResult]) {
            picker.dismiss(animated: true)
            
            guard let provider = results.first?.itemProvider else { return }
            
            if provider.canLoadObject(ofClass: UIImage.self) {
                provider.loadObject(ofClass: UIImage.self) { image, _ in
                    DispatchQueue.main.async {
                        self.parent.image = image as? UIImage
                    }
                }
            }
        }
    }
}

// MARK: - Add Service Sheet
struct SetupAddServiceSheet: View {
    @Binding var services: [ServiceSetupItem]
    @Environment(\.dismiss) var dismiss
    
    @State private var serviceName = ""
    @State private var serviceDescription = ""
    @State private var serviceDuration = 30
    @State private var servicePrice = ""
    
    @State private var showError = false
    @State private var errorMessage = ""
    
    let durations = [15, 30, 45, 60, 90, 120]
    
    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(spacing: 20) {
                    // Service name
                    VStack(alignment: .leading, spacing: 8) {
                        Text("Hizmet Adı *")
                            .font(.subheadline)
                            .fontWeight(.semibold)
                            .foregroundColor(.textPrimary)
                        
                        TextField("örn: Saç Kesimi", text: $serviceName)
                            .textFieldStyle(.roundedBorder)
                    }
                    
                    // Description
                    VStack(alignment: .leading, spacing: 8) {
                        Text("Açıklama")
                            .font(.subheadline)
                            .fontWeight(.semibold)
                            .foregroundColor(.textPrimary)
                        
                        TextEditor(text: $serviceDescription)
                            .frame(height: 80)
                            .padding(8)
                            .background(Color.gray.opacity(0.1))
                            .cornerRadius(8)
                    }
                    
                    // Duration
                    VStack(alignment: .leading, spacing: 8) {
                        Text("Süre (dakika) *")
                            .font(.subheadline)
                            .fontWeight(.semibold)
                            .foregroundColor(.textPrimary)
                        
                        Picker("Süre", selection: $serviceDuration) {
                            ForEach(durations, id: \.self) { duration in
                                Text("\(duration) dk").tag(duration)
                            }
                        }
                        .pickerStyle(.segmented)
                    }
                    
                    // Price
                    VStack(alignment: .leading, spacing: 8) {
                        Text("Fiyat (₺) *")
                            .font(.subheadline)
                            .fontWeight(.semibold)
                            .foregroundColor(.textPrimary)
                        
                        TextField("0", text: $servicePrice)
                            .keyboardType(.decimalPad)
                            .textFieldStyle(.roundedBorder)
                    }
                    
                    // Save button
                    Button(action: saveService) {
                        Text("Hizmeti Ekle")
                            .font(.headline)
                            .foregroundColor(.white)
                            .frame(maxWidth: .infinity)
                            .padding()
                            .background(LinearGradient.primaryGradient)
                            .cornerRadius(12)
                    }
                    .padding(.top)
                }
                .padding(20)
            }
            .background(Color.bgPrimary)
            .navigationTitle("Yeni Hizmet")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button("İptal") {
                        dismiss()
                    }
                }
            }
            .alert("Hata", isPresented: $showError) {
                Button("Tamam", role: .cancel) {}
            } message: {
                Text(errorMessage)
            }
        }
    }
    
    private func saveService() {
        // Validation
        guard !serviceName.isEmpty else {
            errorMessage = "Lütfen hizmet adı girin"
            showError = true
            return
        }
        
        guard let price = Double(servicePrice), price > 0 else {
            errorMessage = "Lütfen geçerli bir fiyat girin"
            showError = true
            return
        }
        
        let service = ServiceSetupItem(
            name: serviceName,
            description: serviceDescription.isEmpty ? serviceName : serviceDescription,
            duration: serviceDuration,
            price: price
        )
        
        services.append(service)
        dismiss()
    }
}

// MARK: - Time Picker Sheet
struct TimePickerSheet: View {
    let day: String
    let openTime: String
    let closeTime: String
    let onSave: (String, String) -> Void
    
    @Environment(\.dismiss) var dismiss
    @State private var selectedOpenTime: Date
    @State private var selectedCloseTime: Date
    
    init(day: String, openTime: String, closeTime: String, onSave: @escaping (String, String) -> Void) {
        self.day = day
        self.openTime = openTime
        self.closeTime = closeTime
        self.onSave = onSave
        
        // Parse time strings
        let formatter = DateFormatter()
        formatter.dateFormat = "HH:mm"
        
        _selectedOpenTime = State(initialValue: formatter.date(from: openTime) ?? Date())
        _selectedCloseTime = State(initialValue: formatter.date(from: closeTime) ?? Date())
    }
    
    var body: some View {
        NavigationStack {
            VStack(spacing: 24) {
                Text(day)
                    .font(.title2)
                    .fontWeight(.bold)
                    .foregroundColor(.textPrimary)
                
                // Open time
                VStack(alignment: .leading, spacing: 8) {
                    Text("Açılış Saati")
                        .font(.subheadline)
                        .fontWeight(.semibold)
                        .foregroundColor(.textPrimary)
                    
                    DatePicker("", selection: $selectedOpenTime, displayedComponents: .hourAndMinute)
                        .labelsHidden()
                        .datePickerStyle(.wheel)
                }
                
                // Close time
                VStack(alignment: .leading, spacing: 8) {
                    Text("Kapanış Saati")
                        .font(.subheadline)
                        .fontWeight(.semibold)
                        .foregroundColor(.textPrimary)
                    
                    DatePicker("", selection: $selectedCloseTime, displayedComponents: .hourAndMinute)
                        .labelsHidden()
                        .datePickerStyle(.wheel)
                }
                
                Spacer()
            }
            .padding(20)
            .background(Color.bgPrimary)
            .navigationTitle("Çalışma Saatleri")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button("İptal") {
                        dismiss()
                    }
                }
                
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("Kaydet") {
                        saveTime()
                    }
                    .fontWeight(.semibold)
                }
            }
        }
    }
    
    private func saveTime() {
        let formatter = DateFormatter()
        formatter.dateFormat = "HH:mm"
        
        let openTimeString = formatter.string(from: selectedOpenTime)
        let closeTimeString = formatter.string(from: selectedCloseTime)
        
        onSave(openTimeString, closeTimeString)
        dismiss()
    }
}

#Preview("Add Service") {
    SetupAddServiceSheet(services: .constant([]))
}

#Preview("Time Picker") {
    TimePickerSheet(day: "Pazartesi", openTime: "09:00", closeTime: "18:00", onSave: { _, _ in })
}

