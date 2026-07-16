//
//  AppointmentDetailSheet.swift
//  ReservationApp
//
//  Randevu detay ve yönetim ekranı
//

import SwiftUI
import FirebaseFirestore

// MARK: - Helper Functions
private func formatDateTurkish(_ date: Date) -> String {
    let formatter = DateFormatter()
    formatter.locale = Locale(identifier: "tr_TR")
    formatter.dateFormat = "d MMMM yyyy, EEEE"
    return formatter.string(from: date)
}

struct AppointmentDetailSheet: View {
    let appointment: Reservation
    @Environment(\.dismiss) var dismiss
    
    @State private var showConfirmAlert = false
    @State private var showRejectAlert = false
    @State private var showProposeTimeSheet = false
    @State private var rejectionReason = ""
    @State private var isProcessing = false
    @State private var showSuccess = false
    @State private var successMessage = ""
    
    private let reservationManager = ReservationManager.shared
    
    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(spacing: 24) {
                    // Customer Info
                    customerInfoSection
                    
                    // Appointment Info
                    appointmentInfoSection
                    
                    // Actions (only for pending appointments)
                    if appointment.status == .pending {
                        actionsSection
                    }
                    
                    // Status Info
                    statusInfoSection
                }
                .padding(20)
            }
            .background(Color.bgPrimary)
            .navigationTitle("Randevu Detayı")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("Kapat") {
                        dismiss()
                    }
                }
            }
            .alert("Randevuyu Onayla?", isPresented: $showConfirmAlert) {
                Button("İptal", role: .cancel) {}
                Button("Onayla", role: .none) {
                    confirmAppointment()
                }
            } message: {
                Text("Bu randevuyu onaylamak istediğinize emin misiniz?")
            }
            .alert("Randevuyu Reddet?", isPresented: $showRejectAlert) {
                Button("İptal", role: .cancel) {}
                Button("Reddet", role: .destructive) {
                    rejectAppointment()
                }
            } message: {
                Text("Bu randevuyu reddetmek istediğinize emin misiniz?")
            }
            .sheet(isPresented: $showProposeTimeSheet) {
                ProposeNewTimeSheet(appointment: appointment)
            }
            .alert("Başarılı", isPresented: $showSuccess) {
                Button("Tamam") {
                    dismiss()
                }
            } message: {
                Text(successMessage)
            }
        }
    }
    
    // MARK: - Customer Info Section
    private var customerInfoSection: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("Müşteri Bilgileri")
                .font(.headline)
                .foregroundColor(.textPrimary)
            
            VStack(spacing: 12) {
                AppointmentInfoRow(icon: "person.fill", title: "Ad Soyad", value: appointment.displayCustomerName)
                
                if let phone = appointment.customerPhone {
                    AppointmentInfoRow(icon: "phone.fill", title: "Telefon", value: phone)
                }
            }
            .padding()
            .background(Color.bgCard)
            .cornerRadius(12)
        }
    }
    
    // MARK: - Appointment Info Section
    private var appointmentInfoSection: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("Randevu Bilgileri")
                .font(.headline)
                .foregroundColor(.textPrimary)
            
            VStack(spacing: 12) {
                AppointmentInfoRow(
                    icon: "scissors",
                    title: "Hizmet",
                    value: appointment.serviceType
                )
                
                AppointmentInfoRow(
                    icon: "calendar",
                    title: "Tarih",
                    value: formatDateTurkish(appointment.date.dateValue())
                )
                
                AppointmentInfoRow(
                    icon: "clock",
                    title: "Saat",
                    value: appointment.timeSlot
                )
                
                AppointmentInfoRow(
                    icon: "hourglass",
                    title: "Süre",
                    value: "\(appointment.displayDuration) dakika"
                )
                
                if let notes = appointment.notes, !notes.isEmpty {
                    AppointmentInfoRow(icon: "note.text", title: "Not", value: notes)
                }
            }
            .padding()
            .background(Color.bgCard)
            .cornerRadius(12)
        }
    }
    
    // MARK: - Actions Section
    private var actionsSection: some View {
        VStack(spacing: 12) {
            Text("İşlemler")
                .font(.headline)
                .foregroundColor(.textPrimary)
                .frame(maxWidth: .infinity, alignment: .leading)
            
            // Confirm Button
            Button(action: {
                showConfirmAlert = true
            }) {
                HStack {
                    Image(systemName: "checkmark.circle.fill")
                    Text("Onayla")
                }
                .font(.headline)
                .foregroundColor(.white)
                .frame(maxWidth: .infinity)
                .padding()
                .background(LinearGradient(colors: [.green, .green.opacity(0.8)], startPoint: .leading, endPoint: .trailing))
                .cornerRadius(12)
            }
            .disabled(isProcessing)
            
            // Propose New Time Button
            Button(action: {
                showProposeTimeSheet = true
            }) {
                HStack {
                    Image(systemName: "clock.arrow.circlepath")
                    Text("Farklı Saat Öner")
                }
                .font(.headline)
                .foregroundColor(.white)
                .frame(maxWidth: .infinity)
                .padding()
                .background(LinearGradient.primaryGradient)
                .cornerRadius(12)
            }
            .disabled(isProcessing)
            
            // Reject Button
            Button(action: {
                showRejectAlert = true
            }) {
                HStack {
                    Image(systemName: "xmark.circle.fill")
                    Text("Reddet")
                }
                .font(.headline)
                .foregroundColor(.white)
                .frame(maxWidth: .infinity)
                .padding()
                .background(LinearGradient(colors: [.red, .red.opacity(0.8)], startPoint: .leading, endPoint: .trailing))
                .cornerRadius(12)
            }
            .disabled(isProcessing)
        }
    }
    
    // MARK: - Status Info Section
    private var statusInfoSection: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("Durum Bilgisi")
                .font(.headline)
                .foregroundColor(.textPrimary)
            
            HStack {
                Text("Durum:")
                    .foregroundColor(.textSecondary)
                
                Spacer()
                
                StatusBadge(status: appointment.status)
            }
            .padding()
            .background(Color.bgCard)
            .cornerRadius(12)
            
            if let proposedDate = appointment.proposedDate,
               let proposedTime = appointment.proposedTimeSlot {
                VStack(alignment: .leading, spacing: 8) {
                    Text("Önerilen Yeni Zaman")
                        .font(.subheadline)
                        .fontWeight(.semibold)
                        .foregroundColor(.primaryOrange)
                    
                    HStack {
                        Image(systemName: "calendar.badge.clock")
                        Text(proposedDate.dateValue().formatted(.dateTime.day().month().year()))
                        Text("•")
                        Text(proposedTime)
                    }
                    .font(.subheadline)
                    .foregroundColor(.textSecondary)
                }
                .padding()
                .background(Color.orange.opacity(0.1))
                .cornerRadius(12)
            }
        }
    }
    
    // MARK: - Actions
    private func confirmAppointment() {
        guard let id = appointment.id else {
            print("❌ appointment.id is nil! Cannot confirm.")
            successMessage = "Hata: Randevu ID'si bulunamadı"
            showSuccess = true
            return
        }
        
        print("✅ Confirming appointment: \(id)")
        isProcessing = true
        reservationManager.confirmReservation(reservationId: id) { result in
            DispatchQueue.main.async {
                isProcessing = false
                
                switch result {
                case .success:
                    print("✅ Appointment confirmed successfully!")
                    successMessage = "Randevu başarıyla onaylandı!"
                    showSuccess = true
                case .failure(let error):
                    print("❌ Failed to confirm: \(error)")
                    successMessage = "Hata: \(error.localizedDescription)"
                    showSuccess = true
                }
            }
        }
    }
    
    private func rejectAppointment() {
        guard let id = appointment.id else {
            print("❌ appointment.id is nil! Cannot reject.")
            successMessage = "Hata: Randevu ID'si bulunamadı"
            showSuccess = true
            return
        }
        
        print("❌ Rejecting appointment: \(id)")
        isProcessing = true
        reservationManager.rejectReservation(reservationId: id) { result in
            DispatchQueue.main.async {
                isProcessing = false
                
                switch result {
                case .success:
                    print("✅ Appointment rejected successfully!")
                    successMessage = "Randevu reddedildi."
                    showSuccess = true
                case .failure(let error):
                    print("❌ Failed to reject: \(error)")
                    successMessage = "Hata: \(error.localizedDescription)"
                    showSuccess = true
                }
            }
        }
    }
}

// MARK: - Appointment Info Row
private struct AppointmentInfoRow: View {
    let icon: String
    let title: String
    let value: String
    
    var body: some View {
        HStack(alignment: .top, spacing: 12) {
            Image(systemName: icon)
                .foregroundColor(.primaryOrange)
                .frame(width: 24)
            
            VStack(alignment: .leading, spacing: 4) {
                Text(title)
                    .font(.caption)
                    .foregroundColor(.textSecondary)
                
                Text(value)
                    .font(.subheadline)
                    .foregroundColor(.textPrimary)
            }
            
            Spacer()
        }
    }
}

// MARK: - Propose New Time Sheet
struct ProposeNewTimeSheet: View {
    let appointment: Reservation
    @Environment(\.dismiss) var dismiss
    
    @State private var proposedDate: Date
    @State private var proposedTimeSlot: String
    @State private var isProcessing = false
    @State private var showSuccess = false
    @State private var successMessage = ""
    
    private let reservationManager = ReservationManager.shared
    private let timeSlots = Util.generateTimeSlots(startHour: 9, endHour: 18, interval: 30)
    
    // Initialize with customer's original date and time
    init(appointment: Reservation) {
        self.appointment = appointment
        _proposedDate = State(initialValue: appointment.date.dateValue())
        _proposedTimeSlot = State(initialValue: appointment.timeSlot)
    }
    
    var body: some View {
        NavigationStack {
            Form {
                Section {
                    VStack(alignment: .leading, spacing: 8) {
                        HStack {
                            Image(systemName: "info.circle.fill")
                                .foregroundColor(.blue)
                            Text("Müşterinin Orijinal Randevusu")
                                .font(.subheadline)
                                .fontWeight(.semibold)
                                .foregroundColor(.blue)
                        }
                        
                        HStack {
                            Text(formatDateTurkish(appointment.date.dateValue()))
                                .font(.caption)
                                .foregroundColor(.textSecondary)
                            Text("•")
                                .foregroundColor(.textSecondary)
                            Text(appointment.timeSlot)
                                .font(.caption)
                                .fontWeight(.semibold)
                                .foregroundColor(.textPrimary)
                        }
                    }
                    .padding(.vertical, 4)
                }
                
                Section("Yeni Tarih Öner") {
                    DatePicker("Tarih", selection: $proposedDate, in: Date()..., displayedComponents: .date)
                    
                    Picker("Saat", selection: $proposedTimeSlot) {
                        ForEach(timeSlots, id: \.self) { slot in
                            Text(slot).tag(slot)
                        }
                    }
                }
                
                Section {
                    Button(action: proposeNewTime) {
                        if isProcessing {
                            HStack {
                                Spacer()
                                ProgressView()
                                Spacer()
                            }
                        } else {
                            Text("Öneriyi Gönder")
                                .frame(maxWidth: .infinity)
                        }
                    }
                    .disabled(isProcessing)
                }
            }
            .navigationTitle("Farklı Saat Öner")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button("İptal") {
                        dismiss()
                    }
                }
            }
            .alert("Başarılı", isPresented: $showSuccess) {
                Button("Tamam") {
                    dismiss()
                }
            } message: {
                Text(successMessage)
            }
        }
    }
    
    private func proposeNewTime() {
        guard let id = appointment.id else {
            print("❌ appointment.id is nil! Cannot propose new time.")
            successMessage = "Hata: Randevu ID'si bulunamadı"
            showSuccess = true
            return
        }
        
        print("🕐 Proposing new time for: \(id)")
        print("   New date: \(proposedDate)")
        print("   New time: \(proposedTimeSlot)")
        
        isProcessing = true
        reservationManager.proposeNewTime(
            reservationId: id,
            proposedDate: proposedDate,
            proposedTimeSlot: proposedTimeSlot
        ) { result in
            DispatchQueue.main.async {
                isProcessing = false
                
                switch result {
                case .success:
                    print("✅ New time proposed successfully!")
                    successMessage = "Yeni zaman önerisi müşteriye gönderildi."
                    showSuccess = true
                case .failure(let error):
                    print("❌ Failed to propose: \(error)")
                    successMessage = "Hata: \(error.localizedDescription)"
                    showSuccess = true
                }
            }
        }
    }
}

#Preview {
    AppointmentDetailSheet(appointment: Reservation(
        id: "1",
        customerId: "user1",
        customerName: "Ahmet Yılmaz",
        customerPhone: "555-1234",
        businessId: "bus1",
        businessName: "Test Salon",
        serviceType: "Saç Kesimi",
        date: Timestamp(),
        timeSlot: "14:00",
        duration: 30,
        status: .pending,
        notes: nil,
        createdAt: Timestamp(),
        updatedAt: nil,
        aiRecommended: false,
        proposedDate: nil,
        proposedTimeSlot: nil
    ))
}

