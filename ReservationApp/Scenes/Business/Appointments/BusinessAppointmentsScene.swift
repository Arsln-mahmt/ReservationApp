//
//  BusinessAppointmentsScene.swift
//  ReservationApp
//
//  Created by Mahmut Arslan on 25.10.2025.
//

import SwiftUI
import FirebaseCore

// MARK: - Helper Functions
private func formatDateTurkish(_ date: Date) -> String {
    let formatter = DateFormatter()
    formatter.locale = Locale(identifier: "tr_TR")
    formatter.dateFormat = "d MMM yyyy"
    return formatter.string(from: date)
}

struct BusinessAppointmentsScene: View {
    @StateObject private var viewModel = BusinessAppointmentsViewModel()
    
    var body: some View {
        NavigationStack {
            ZStack {
                Color.bgPrimary.ignoresSafeArea()
                
                if viewModel.appointments.isEmpty {
                    emptyView
                } else {
                    appointmentsList
                }
            }
            .navigationTitle("Randevular")
            .navigationBarTitleDisplayMode(.large)
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Menu {
                        Button(action: { viewModel.selectedFilter = .all }) {
                            Label("Tümü", systemImage: "calendar")
                        }
                        Button(action: { viewModel.selectedFilter = .today }) {
                            Label("Bugün", systemImage: "calendar.badge.clock")
                        }
                        Button(action: { viewModel.selectedFilter = .upcoming }) {
                            Label("Yaklaşan", systemImage: "clock")
                        }
                        Button(action: { viewModel.selectedFilter = .completed }) {
                            Label("Tamamlanan", systemImage: "checkmark.circle")
                        }
                    } label: {
                        Image(systemName: "line.3.horizontal.decrease.circle")
                            .foregroundColor(.primaryOrange)
                    }
                }
            }
        }
    }
    
    // MARK: - Empty View
    private var emptyView: some View {
        VStack(spacing: 16) {
            Image(systemName: "calendar.badge.exclamationmark")
                .font(.system(size: 60))
                .foregroundColor(.textLight)
            
            Text("Henüz Randevu Yok")
                .font(.title3)
                .fontWeight(.semibold)
                .foregroundColor(.textPrimary)
            
            Text("Müşterileriniz randevu oluşturduğunda burada görünecek")
                .font(.subheadline)
                .foregroundColor(.textSecondary)
                .multilineTextAlignment(.center)
                .padding(.horizontal, 40)
        }
    }
    
    // MARK: - Appointments List
    private var appointmentsList: some View {
        ScrollView {
            LazyVStack(spacing: 16) {
                ForEach(viewModel.filteredAppointments, id: \.uniqueID) { appointment in
                    AppointmentCard(appointment: appointment, onRefresh: {
                        viewModel.loadAppointments()
                    })
                }
            }
            .padding(20)
        }
        .refreshable {
            viewModel.loadAppointments()
        }
    }
}

// MARK: - Appointment Card
struct AppointmentCard: View {
    let appointment: Reservation
    let onRefresh: () -> Void
    
    @State private var showDetail = false
    
    var body: some View {
        Button(action: {
            showDetail = true
        }) {
            VStack(alignment: .leading, spacing: 12) {
                HStack {
                    VStack(alignment: .leading, spacing: 4) {
                        Text(appointment.displayCustomerName)
                            .font(.headline)
                            .foregroundColor(.textPrimary)
                        
                        Text(appointment.serviceType)
                            .font(.subheadline)
                            .foregroundColor(.textSecondary)
                    }
                    
                    Spacer()
                    
                    StatusBadge(status: appointment.status)
                }
                
                Divider()
                
                HStack(spacing: 16) {
                HStack(spacing: 6) {
                    Image(systemName: "calendar")
                        .font(.caption)
                        .foregroundColor(.textSecondary)
                    Text(formatDateTurkish(appointment.date.dateValue()))
                        .font(.caption)
                        .foregroundColor(.textSecondary)
                }
                    
                    HStack(spacing: 6) {
                        Image(systemName: "clock")
                            .font(.caption)
                            .foregroundColor(.textSecondary)
                        Text(appointment.timeSlot)
                            .font(.caption)
                            .foregroundColor(.textSecondary)
                    }
                }
                
                // Pending indicator
                if appointment.status == .pending {
                    HStack(spacing: 6) {
                        Image(systemName: "hand.tap")
                            .font(.caption2)
                        Text("Onay bekliyor - Detaylar için tıklayın")
                            .font(.caption2)
                    }
                    .foregroundColor(.orange)
                    .padding(.top, 4)
                }
            }
            .padding()
            .background(Color.bgCard)
            .cornerRadius(16)
            .shadow(color: Color.black.opacity(0.05), radius: 8, y: 2)
            .overlay(
                RoundedRectangle(cornerRadius: 16)
                    .stroke(appointment.status == .pending ? Color.orange : Color.clear, lineWidth: 2)
            )
        }
        .buttonStyle(PlainButtonStyle())
        .sheet(isPresented: $showDetail, onDismiss: {
            onRefresh()
        }) {
            AppointmentDetailSheet(appointment: appointment)
        }
    }
}

// MARK: - Status Badge
struct StatusBadge: View {
    let status: ReservationStatus
    
    var body: some View {
        Text(status.displayName)
            .font(.caption)
            .fontWeight(.semibold)
            .foregroundColor(statusColor)
            .padding(.horizontal, 10)
            .padding(.vertical, 5)
            .background(statusColor.opacity(0.15))
            .cornerRadius(8)
    }
    
    private var statusColor: Color {
        switch status {
        case .pending:
            return .orange
        case .confirmed:
            return .green
        case .cancelled:
            return .red
        case .completed:
            return .blue
        case .noShow:
            return .yellow
        case .blocked:
            return .red.opacity(0.8)
        }
    }
}

#Preview {
    BusinessAppointmentsScene()
}

