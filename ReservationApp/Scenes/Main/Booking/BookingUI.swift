//
//  BookingUI.swift
//  ReservationApp
//
//  Created by Mahmut Arslan on 25.10.2025.
//

import SwiftUI

struct BookingUI: View {
    let business: BusinessListing
    let service: Service
    @ObservedObject var viewModel: BookingViewModel
    let authManager: AuthManager
    let onCancel: () -> Void
    
    var body: some View {
        ScrollView {
            VStack(spacing: 24) {
                // Service Info
                serviceInfoSection
                
                // Date Selection
                dateSelectionSection
                
                // Time Slot Selection
                timeSlotSection
                
                // Notes
                notesSection
                
                // Book Button
                bookButton
            }
            .padding(20)
        }
        .background(Color.bgPrimary)
    }
    
    // MARK: - Service Info Section
    private var serviceInfoSection: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text(business.name)
                .font(.headline)
                .foregroundColor(.textPrimary)
            
            HStack {
                VStack(alignment: .leading, spacing: 6) {
                    Text(service.name)
                        .font(.title3)
                        .fontWeight(.semibold)
                        .foregroundColor(.textPrimary)
                    
                    HStack(spacing: 16) {
                        HStack(spacing: 4) {
                            Image(systemName: "clock")
                            Text("\(service.duration) dakika")
                        }
                        .font(.subheadline)
                        .foregroundColor(.textSecondary)
                        
                        Text("₺\(Int(service.price))")
                            .font(.headline)
                            .foregroundColor(.primaryOrange)
                    }
                }
                Spacer()
            }
        }
        .padding()
        .background(Color.bgCard)
        .cornerRadius(12)
    }
    
    // MARK: - Date Selection
    private var dateSelectionSection: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("Tarih Seçin")
                .font(.headline)
                .foregroundColor(.textPrimary)
            
            DatePicker("", selection: $viewModel.selectedDate, in: Date()..., displayedComponents: .date)
                .datePickerStyle(.graphical)
                .tint(.primaryOrange)
                .onChange(of: viewModel.selectedDate) { _ in
                    viewModel.loadAvailableTimeSlots()
                }
        }
        .padding()
        .background(Color.bgCard)
        .cornerRadius(12)
    }
    
    // MARK: - Time Slot Selection
    private var timeSlotSection: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("Saat Seçin")
                .font(.headline)
                .foregroundColor(.textPrimary)
            
            if viewModel.isLoadingSlots {
                ProgressView()
                    .frame(maxWidth: .infinity)
                    .padding()
            } else if viewModel.availableTimeSlots.isEmpty {
                Text("Bu tarihte müsait saat bulunmuyor")
                    .font(.subheadline)
                    .foregroundColor(.textSecondary)
                    .frame(maxWidth: .infinity)
                    .padding()
            } else {
                LazyVGrid(columns: [GridItem(.adaptive(minimum: 80))], spacing: 12) {
                    ForEach(viewModel.availableTimeSlots) { slot in
                        TimeSlotButton(
                            slot: slot,
                            isSelected: viewModel.selectedTimeSlot == slot.time
                        ) {
                            if slot.isAvailable {
                                print("⏰ Time slot tapped: \(slot.time)")
                                viewModel.selectedTimeSlot = slot.time
                            }
                        }
                    }
                }
            }
        }
        .padding()
        .background(Color.bgCard)
        .cornerRadius(12)
    }
    
    // MARK: - Notes Section
    private var notesSection: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("Not (Opsiyonel)")
                .font(.headline)
                .foregroundColor(.textPrimary)
            
            TextEditor(text: $viewModel.notes)
                .frame(height: 100)
                .padding(8)
                .background(Color.bgPrimary)
                .cornerRadius(8)
        }
        .padding()
        .background(Color.bgCard)
        .cornerRadius(12)
    }
    
    // MARK: - Book Button
    private var bookButton: some View {
        VStack(spacing: 8) {
            // Debug info
            if let selected = viewModel.selectedTimeSlot {
                Text("Seçili Saat: \(selected)")
                    .font(.caption)
                    .foregroundColor(.green)
            } else {
                Text("⚠️ Lütfen bir saat seçin")
                    .font(.caption)
                    .foregroundColor(.red)
            }
            
            Button(action: {
                print("\n" + String(repeating: "🎯", count: 50))
                print("🚀 BUTTON TAPPED - CREATE RESERVATION")
                print(String(repeating: "🎯", count: 50))
                print("Auth Info:")
                print("   ├─ Is Authenticated: \(authManager.isAuthenticated)")
                print("   ├─ Current User: \(authManager.currentUser?.name ?? "nil")")
                print("   ├─ User ID: \(authManager.currentUser?.uid ?? "nil")")
                print("   └─ User Type: \(authManager.currentUser?.userType.rawValue ?? "nil")")
                print("Selected Time Slot: \(viewModel.selectedTimeSlot ?? "NIL - ERROR!")")
                print(String(repeating: "🎯", count: 50) + "\n")
                
                if viewModel.selectedTimeSlot == nil {
                    print("❌ BLOCKED: No time slot selected!")
                    return
                }
                
                guard let uid = authManager.currentUser?.uid, !uid.isEmpty else {
                    print("❌❌❌ CRITICAL: No User ID - Cannot create reservation!")
                    return
                }
                
                print("✅ Validation passed, calling viewModel.createReservation...\n")
                
                viewModel.createReservation(
                    customerId: uid,
                    customerName: authManager.currentUser?.name ?? "",
                    customerPhone: authManager.currentUser?.phoneNumber
                )
            }) {
                if viewModel.isCreating {
                    ProgressView()
                        .progressViewStyle(CircularProgressViewStyle(tint: .white))
                        .frame(maxWidth: .infinity)
                } else {
                    Text("Randevuyu Oluştur")
                        .font(.headline)
                        .foregroundColor(.white)
                        .frame(maxWidth: .infinity)
                }
            }
            .frame(height: 56)
            .background(
                viewModel.selectedTimeSlot == nil ?
                LinearGradient(colors: [Color.gray, Color.gray], startPoint: .leading, endPoint: .trailing) :
                LinearGradient.primaryGradient
            )
            .cornerRadius(12)
            .disabled(viewModel.selectedTimeSlot == nil || viewModel.isCreating)
            .opacity((viewModel.selectedTimeSlot == nil || viewModel.isCreating) ? 0.6 : 1.0)
        }
    }
}

// MARK: - Time Slot Button
struct TimeSlotButton: View {
    let slot: BookingTimeSlot
    let isSelected: Bool
    let action: () -> Void
    
    var body: some View {
        Button(action: action) {
            Text(slot.time)
                .font(.subheadline)
                .fontWeight(isSelected ? .semibold : .regular)
                .foregroundColor(textColor)
                .strikethrough(!slot.isAvailable, color: .red.opacity(0.5))
                .frame(maxWidth: .infinity)
                .padding(.vertical, 12)
                .background(backgroundColor)
                .cornerRadius(8)
                .overlay(
                    RoundedRectangle(cornerRadius: 8)
                        .stroke(borderColor, lineWidth: 1)
                )
        }
        .buttonStyle(PlainButtonStyle())
        .disabled(!slot.isAvailable)
    }
    
    private var textColor: Color {
        if !slot.isAvailable { return .gray }
        return isSelected ? .white : .textPrimary
    }
    
    private var backgroundColor: some View {
        Group {
            if !slot.isAvailable {
                Color.gray.opacity(0.1)
            } else if isSelected {
                LinearGradient.primaryGradient
            } else {
                Color.bgPrimary
            }
        }
    }
    
    private var borderColor: Color {
        if isSelected || !slot.isAvailable { return .clear }
        return .gray.opacity(0.3)
    }
}

