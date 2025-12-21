//
//  MyReservationsUI.swift
//  ReservationApp
//
//  Created by Mahmut Arslan on 25.10.2025.
//

import SwiftUI
import FirebaseCore

// MARK: - Customer Reservation Card
struct CustomerReservationCard: View {
    let reservation: Reservation
    var onAcceptProposal: (() -> Void)?
    var onRejectProposal: (() -> Void)?
    
    private var timeUntilReservation: String {
        // Combine date and timeSlot to get the actual reservation datetime
        let reservationDate = reservation.date.dateValue()
        
        // Parse timeSlot (format: "HH:mm")
        let timeComponents = reservation.timeSlot.split(separator: ":").compactMap { Int($0) }
        guard timeComponents.count == 2 else {
            return "Geçmiş"
        }
        
        // Create full datetime with hour and minute
        var calendar = Calendar.current
        calendar.timeZone = TimeZone.current
        
        var components = calendar.dateComponents([.year, .month, .day], from: reservationDate)
        components.hour = timeComponents[0]
        components.minute = timeComponents[1]
        components.second = 0
        
        guard let fullReservationDateTime = calendar.date(from: components) else {
            return "Geçmiş"
        }
        
        let now = Date()
        let interval = fullReservationDateTime.timeIntervalSince(now)
        
        if interval < 0 {
            return "Geçmiş"
        } else if interval < 3600 {
            let minutes = Int(interval / 60)
            return "\(minutes) dakika kaldı"
        } else if interval < 86400 {
            let hours = Int(interval / 3600)
            return "\(hours) saat kaldı"
        } else {
            let days = Int(interval / 86400)
            return "\(days) gün kaldı"
        }
    }
    
    var body: some View {
        VStack(alignment: .leading, spacing: 0) {
            // Header with business name and status
            HStack(alignment: .top) {
                VStack(alignment: .leading, spacing: 6) {
                    Text(reservation.displayBusinessName)
                        .font(.title3)
                        .fontWeight(.bold)
                        .foregroundColor(.textPrimary)
                    
                    Text(reservation.serviceType)
                        .font(.subheadline)
                        .foregroundColor(.primaryOrange)
                        .fontWeight(.medium)
                }
                
                Spacer()
                
                StatusBadge(status: reservation.status)
            }
            .padding()
            .background(Color.bgCard)
            
            Divider()
            
            // Date, Time, Duration info
            VStack(spacing: 12) {
                HStack {
                    Image(systemName: "calendar")
                        .foregroundColor(.primaryOrange)
                        .frame(width: 24)
                    Text(formatDate(reservation.date.dateValue()))
                        .font(.subheadline)
                        .foregroundColor(.textPrimary)
                    
                    Spacer()
                    
                    Image(systemName: "clock")
                        .foregroundColor(.primaryOrange)
                        .frame(width: 24)
                    Text(reservation.timeSlot)
                        .font(.subheadline)
                        .fontWeight(.semibold)
                        .foregroundColor(.textPrimary)
                }
                
                HStack {
                    Image(systemName: "hourglass")
                        .foregroundColor(.primaryOrange)
                        .frame(width: 24)
                    Text("\(reservation.displayDuration) dakika")
                        .font(.subheadline)
                        .foregroundColor(.textPrimary)
                    
                    Spacer()
                }
            }
            .padding()
            .background(Color.bgPrimary.opacity(0.5))
            
            // Time until reservation or rescheduled message
            if let proposedDate = reservation.proposedDate,
               let proposedTime = reservation.proposedTimeSlot {
                // Show rescheduled info with action buttons
                VStack(spacing: 12) {
                    HStack {
                        Image(systemName: "hourglass")
                            .foregroundColor(.orange)
                        VStack(alignment: .leading, spacing: 4) {
                            Text("İşletme farklı bir zaman önerdi")
                                .font(.caption)
                                .fontWeight(.semibold)
                                .foregroundColor(.orange)
                            Text("\(formatDateShort(proposedDate.dateValue())) - \(proposedTime)")
                                .font(.caption2)
                                .foregroundColor(.textSecondary)
                        }
                        Spacer()
                    }
                    
                    // Action Buttons
                    HStack(spacing: 8) {
                        Button(action: {
                            onAcceptProposal?()
                        }) {
                            HStack(spacing: 4) {
                                Image(systemName: "checkmark.circle.fill")
                                    .font(.caption)
                                Text("Onayla")
                                    .font(.caption)
                                    .fontWeight(.semibold)
                            }
                            .foregroundColor(.white)
                            .frame(maxWidth: .infinity)
                            .padding(.vertical, 8)
                            .background(Color.green)
                            .cornerRadius(8)
                        }
                        
                        Button(action: {
                            onRejectProposal?()
                        }) {
                            HStack(spacing: 4) {
                                Image(systemName: "xmark.circle.fill")
                                    .font(.caption)
                                Text("İptal Et")
                                    .font(.caption)
                                    .fontWeight(.semibold)
                            }
                            .foregroundColor(.white)
                            .frame(maxWidth: .infinity)
                            .padding(.vertical, 8)
                            .background(Color.red)
                            .cornerRadius(8)
                        }
                    }
                }
                .padding()
                .background(Color.orange.opacity(0.15))
            } else if reservation.status != .cancelled && reservation.status != .completed {
                HStack {
                    Image(systemName: "timer")
                        .foregroundColor(.green)
                    Text(timeUntilReservation)
                        .font(.caption)
                        .fontWeight(.semibold)
                        .foregroundColor(.green)
                    
                    Spacer()
                    
                    Text("Detaylar için tıklayın")
                        .font(.caption2)
                        .foregroundColor(.textLight)
                }
                .padding()
                .background(Color.green.opacity(0.1))
            }
        }
        .background(Color.bgCard)
        .cornerRadius(16)
        .shadow(color: Color.black.opacity(0.1), radius: 10, y: 4)
    }
    
    private func formatDate(_ date: Date) -> String {
        let formatter = DateFormatter()
        formatter.dateFormat = "d MMMM yyyy, EEEE"
        formatter.locale = Locale(identifier: "tr_TR")
        return formatter.string(from: date)
    }
    
    private func formatDateShort(_ date: Date) -> String {
        let formatter = DateFormatter()
        formatter.dateFormat = "d MMM yyyy"
        formatter.locale = Locale(identifier: "tr_TR")
        return formatter.string(from: date)
    }
}

// MARK: - Reservation Detail Sheet
struct ReservationDetailSheet: View {
    let reservation: Reservation
    let onCancel: () -> Void
    
    @Environment(\.dismiss) var dismiss
    @State private var showCancelAlert = false
    
    private var canCancel: Bool {
        // Can cancel if reservation is pending and within 10 minutes of creation
        guard reservation.status == .pending else { return false }
        
        let createdDate = reservation.createdAt.dateValue()
        let now = Date()
        let interval = now.timeIntervalSince(createdDate)
        
        return interval <= 600 // 10 minutes = 600 seconds
    }
    
    private var minutesUntilCancelExpires: Int {
        let createdDate = reservation.createdAt.dateValue()
        let now = Date()
        let interval = now.timeIntervalSince(createdDate)
        let remaining = 600 - interval // 600 seconds = 10 minutes
        
        return max(0, Int(remaining / 60))
    }
    
    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(spacing: 20) {
                    // Header
                    headerSection
                    
                    // Business Info
                    businessInfoSection
                    
                    // Reservation Details
                    reservationDetailsSection
                    
                    // Proposed Time (if any)
                    if reservation.proposedDate != nil {
                        proposedTimeSection
                    }
                    
                    // Customer Info
                    customerInfoSection
                    
                    // Notes
                    if let notes = reservation.notes {
                        notesSection(notes)
                    }
                    
                    // Cancel Button (if eligible)
                    if canCancel {
                        cancelSection
                    }
                }
                .padding(20)
            }
            .background(Color.bgPrimary)
            .navigationTitle("Randevu Detayları")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("Kapat") {
                        dismiss()
                    }
                }
            }
            .alert("Randevuyu İptal Et", isPresented: $showCancelAlert) {
                Button("İptal", role: .cancel) {}
                Button("Evet, İptal Et", role: .destructive) {
                    onCancel()
                }
            } message: {
                Text("Bu randevuyu iptal etmek istediğinize emin misiniz?")
            }
        }
    }
    
    // MARK: - Header Section
    private var headerSection: some View {
        VStack(spacing: 12) {
            ZStack {
                Circle()
                    .fill(statusGradient)
                    .frame(width: 80, height: 80)
                
                Image(systemName: statusIcon)
                    .font(.system(size: 40))
                    .foregroundColor(.white)
            }
            
            Text(reservation.displayBusinessName)
                .font(.title2)
                .fontWeight(.bold)
                .foregroundColor(.textPrimary)
            
            StatusBadge(status: reservation.status)
        }
        .frame(maxWidth: .infinity)
        .padding(.vertical, 20)
    }
    
    private var statusIcon: String {
        switch reservation.status {
        case .cancelled:
            return "xmark.circle.fill"
        case .confirmed:
            return "checkmark.circle.fill"
        case .completed:
            return "checkmark.seal.fill"
        case .pending:
            if reservation.proposedDate != nil {
                return "hourglass"
            }
            return "clock.fill"
        case .noShow:
            return "exclamationmark.triangle.fill"
        }
    }
    
    private var statusGradient: LinearGradient {
        switch reservation.status {
        case .cancelled:
            return LinearGradient(colors: [.red, .red.opacity(0.8)], startPoint: .topLeading, endPoint: .bottomTrailing)
        case .confirmed, .completed:
            return LinearGradient(colors: [.green, .green.opacity(0.8)], startPoint: .topLeading, endPoint: .bottomTrailing)
        case .pending:
            if reservation.proposedDate != nil {
                return LinearGradient(colors: [.orange, .orange.opacity(0.8)], startPoint: .topLeading, endPoint: .bottomTrailing)
            }
            return LinearGradient.primaryGradient
        case .noShow:
            return LinearGradient(colors: [.gray, .gray.opacity(0.8)], startPoint: .topLeading, endPoint: .bottomTrailing)
        }
    }
    
    // MARK: - Business Info Section
    private var businessInfoSection: some View {
        VStack(alignment: .leading, spacing: 16) {
            Text("İşletme Bilgileri")
                .font(.headline)
                .foregroundColor(.textPrimary)
            
            DetailRow(icon: "building.2.fill", title: "İşletme", value: reservation.displayBusinessName)
            DetailRow(icon: "scissors", title: "Hizmet", value: reservation.serviceType)
            DetailRow(icon: "hourglass", title: "Süre", value: "\(reservation.displayDuration) dakika")
        }
        .padding()
        .background(Color.bgCard)
        .cornerRadius(12)
    }
    
    // MARK: - Proposed Time Section
    private var proposedTimeSection: some View {
        VStack(alignment: .leading, spacing: 16) {
            HStack {
                Image(systemName: "hourglass")
                    .foregroundColor(.orange)
                Text("İşletme Farklı Zaman Önerdi")
                    .font(.headline)
                    .foregroundColor(.orange)
            }
            
            VStack(alignment: .leading, spacing: 12) {
                HStack {
                    VStack(alignment: .leading, spacing: 4) {
                        Text("Orijinal Randevu")
                            .font(.caption)
                            .foregroundColor(.textSecondary)
                        HStack(spacing: 8) {
                            Text(formatDateShort(reservation.date.dateValue()))
                                .font(.subheadline)
                                .foregroundColor(.textPrimary)
                            Text("•")
                                .foregroundColor(.textSecondary)
                            Text(reservation.timeSlot)
                                .font(.subheadline)
                                .fontWeight(.semibold)
                                .foregroundColor(.textPrimary)
                        }
                    }
                    
                    Spacer()
                }
                
                Divider()
                
                if let proposedDate = reservation.proposedDate,
                   let proposedTime = reservation.proposedTimeSlot {
                    HStack {
                        VStack(alignment: .leading, spacing: 4) {
                            Text("Önerilen Yeni Zaman")
                                .font(.caption)
                                .foregroundColor(.orange)
                                .fontWeight(.semibold)
                            HStack(spacing: 8) {
                                Text(formatDateShort(proposedDate.dateValue()))
                                    .font(.subheadline)
                                    .foregroundColor(.orange)
                                Text("•")
                                    .foregroundColor(.orange)
                                Text(proposedTime)
                                    .font(.subheadline)
                                    .fontWeight(.bold)
                                    .foregroundColor(.orange)
                            }
                        }
                        
                        Spacer()
                        
                        Image(systemName: "arrow.right.circle.fill")
                            .font(.title2)
                            .foregroundColor(.orange)
                    }
                }
            }
            
            Text("Lütfen işletmeyle iletişime geçerek yeni zamanı onaylayın veya iptal edin.")
                .font(.caption)
                .foregroundColor(.textSecondary)
                .padding(.top, 4)
        }
        .padding()
        .background(Color.orange.opacity(0.1))
        .cornerRadius(12)
        .overlay(
            RoundedRectangle(cornerRadius: 12)
                .stroke(Color.orange.opacity(0.5), lineWidth: 2)
        )
    }
    
    // MARK: - Reservation Details Section
    private var reservationDetailsSection: some View {
        VStack(alignment: .leading, spacing: 16) {
            Text("Randevu Bilgileri")
                .font(.headline)
                .foregroundColor(.textPrimary)
            
            DetailRow(
                icon: "calendar",
                title: "Tarih",
                value: formatDate(reservation.date.dateValue())
            )
            DetailRow(icon: "clock", title: "Saat", value: reservation.timeSlot)
            DetailRow(
                icon: "calendar.badge.clock",
                title: "Oluşturulma",
                value: formatDateTime(reservation.createdAt.dateValue())
            )
            
            if let aiRecommended = reservation.aiRecommended, aiRecommended {
                HStack {
                    Image(systemName: "sparkles")
                        .foregroundColor(.primaryOrange)
                    Text("AI Önerisi")
                        .font(.caption)
                        .foregroundColor(.primaryOrange)
                }
            }
        }
        .padding()
        .background(Color.bgCard)
        .cornerRadius(12)
    }
    
    // MARK: - Customer Info Section
    private var customerInfoSection: some View {
        VStack(alignment: .leading, spacing: 16) {
            Text("Müşteri Bilgileri")
                .font(.headline)
                .foregroundColor(.textPrimary)
            
            DetailRow(icon: "person.fill", title: "Ad Soyad", value: reservation.displayCustomerName)
            
            if let phone = reservation.customerPhone {
                DetailRow(icon: "phone.fill", title: "Telefon", value: phone)
            }
        }
        .padding()
        .background(Color.bgCard)
        .cornerRadius(12)
    }
    
    // MARK: - Notes Section
    private func notesSection(_ notes: String) -> some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("Notlar")
                .font(.headline)
                .foregroundColor(.textPrimary)
            
            Text(notes)
                .font(.subheadline)
                .foregroundColor(.textSecondary)
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .padding()
        .background(Color.bgCard)
        .cornerRadius(12)
    }
    
    // MARK: - Cancel Section
    private var cancelSection: some View {
        VStack(spacing: 12) {
            HStack {
                Image(systemName: "info.circle.fill")
                    .foregroundColor(.orange)
                
                Text("İlk 10 dakika içinde ücretsiz iptal edebilirsiniz")
                    .font(.caption)
                    .foregroundColor(.textSecondary)
                
                Spacer()
            }
            .padding()
            .background(Color.orange.opacity(0.1))
            .cornerRadius(8)
            
            if minutesUntilCancelExpires > 0 {
                Text("İptal hakkınız \(minutesUntilCancelExpires) dakika içinde sona erecek")
                    .font(.caption2)
                    .foregroundColor(.orange)
            }
            
            Button(action: {
                showCancelAlert = true
            }) {
                HStack {
                    Image(systemName: "xmark.circle.fill")
                    Text("Randevuyu İptal Et")
                }
                .font(.headline)
                .foregroundColor(.white)
                .frame(maxWidth: .infinity)
                .padding()
                .background(Color.red)
                .cornerRadius(12)
            }
        }
    }
    
    // MARK: - Helper Functions
    private func formatDate(_ date: Date) -> String {
        let formatter = DateFormatter()
        formatter.dateFormat = "d MMMM yyyy, EEEE"
        formatter.locale = Locale(identifier: "tr_TR")
        return formatter.string(from: date)
    }
    
    private func formatDateTime(_ date: Date) -> String {
        let formatter = DateFormatter()
        formatter.dateFormat = "d MMM yyyy, HH:mm"
        formatter.locale = Locale(identifier: "tr_TR")
        return formatter.string(from: date)
    }
    
    private func formatDateShort(_ date: Date) -> String {
        let formatter = DateFormatter()
        formatter.dateFormat = "d MMM yyyy"
        formatter.locale = Locale(identifier: "tr_TR")
        return formatter.string(from: date)
    }
}

// MARK: - Detail Row
struct DetailRow: View {
    let icon: String
    let title: String
    let value: String
    
    var body: some View {
        HStack(spacing: 12) {
            Image(systemName: icon)
                .foregroundColor(.primaryOrange)
                .frame(width: 30)
            
            VStack(alignment: .leading, spacing: 4) {
                Text(title)
                    .font(.caption)
                    .foregroundColor(.textSecondary)
                
                Text(value)
                    .font(.subheadline)
                    .fontWeight(.medium)
                    .foregroundColor(.textPrimary)
            }
            
            Spacer()
        }
    }
}

