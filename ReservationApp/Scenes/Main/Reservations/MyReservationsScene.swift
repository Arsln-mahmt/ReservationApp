//
//  MyReservationsScene.swift
//  ReservationApp
//
//  Created by Mahmut Arslan on 25.10.2025.
//

import SwiftUI
import FirebaseCore

struct MyReservationsScene: View {
    @EnvironmentObject var authManager: AuthManager
    @EnvironmentObject var appEnvironment: AppEnvironment
    @StateObject private var viewModel = MyReservationsViewModel()
    @State private var showLoginSheet = false
    @State private var selectedReservation: Reservation?
    @State private var refreshTrigger = UUID()  // Trigger to refresh when view appears
    
    var body: some View {
        NavigationStack {
            ZStack {
                Color.bgPrimary.ignoresSafeArea()
                
                if authManager.isAuthenticated {
                    // User is logged in, show reservations
                    reservationsView
                } else {
                    // User not logged in, show login prompt
                    loginPromptView
                }
            }
            .navigationTitle("Rezervasyonlarım")
            .navigationBarTitleDisplayMode(.large)
            .sheet(isPresented: $showLoginSheet) {
                LoginScene()
            }
            .sheet(item: $selectedReservation) { reservation in
                ReservationDetailSheet(
                    reservation: reservation,
                    onCancel: {
                        viewModel.cancelReservation(reservation: reservation)
                        selectedReservation = nil
                    }
                )
            }
            .onAppear {
                // Refresh trigger to force reload every time view appears
                refreshTrigger = UUID()
                
                if authManager.isAuthenticated {
                    if let userId = authManager.currentUser?.uid {
                        print("🔄 MyReservationsScene appeared - loading reservations")
                        viewModel.loadReservations(customerId: userId)
                    }
                }
            }
            .onReceive(NotificationCenter.default.publisher(for: NSNotification.Name("RefreshReservations"))) { _ in
                print("📢 Received refresh notification - reloading reservations immediately!")
                if authManager.isAuthenticated {
                    if let userId = authManager.currentUser?.uid {
                        viewModel.loadReservations(customerId: userId)
                    }
                }
            }
        }
    }
    
    // MARK: - Reservations View
    private var reservationsView: some View {
        ScrollView {
            if viewModel.isLoading {
                ProgressView()
                    .frame(maxWidth: .infinity)
                    .padding(.top, 100)
            } else if viewModel.reservations.isEmpty {
                VStack(spacing: 16) {
                    Image(systemName: "calendar.badge.clock")
                        .font(.system(size: 60))
                        .foregroundColor(.textLight)
                    
                    Text("Henüz Rezervasyonunuz Yok")
                        .font(.title3)
                        .fontWeight(.semibold)
                        .foregroundColor(.textPrimary)
                    
                    Text("İşletmeleri keşfedin ve ilk rezervasyonunuzu yapın!")
                        .font(.subheadline)
                        .foregroundColor(.textSecondary)
                        .multilineTextAlignment(.center)
                        .padding(.horizontal, 40)
                }
                .frame(maxWidth: .infinity)
                .padding(.top, 100)
            } else {
                LazyVStack(spacing: 16) {
                    ForEach(viewModel.reservations, id: \.uniqueID) { reservation in
                        CustomerReservationCard(
                            reservation: reservation,
                            onAcceptProposal: {
                                acceptProposedTime(for: reservation)
                            },
                            onRejectProposal: {
                                rejectProposedTime(for: reservation)
                            }
                        )
                        .onTapGesture {
                            selectedReservation = reservation
                        }
                    }
                }
                .padding(20)
            }
        }
        .refreshable {
            if let customerId = authManager.currentUser?.uid {
                viewModel.loadReservations(customerId: customerId)
            }
        }
    }
    
    // MARK: - Login Prompt View
    private var loginPromptView: some View {
        VStack(spacing: 24) {
            Image(systemName: "person.crop.circle.badge.exclamationmark")
                .font(.system(size: 80))
                .foregroundColor(.primaryOrange)
            
            VStack(spacing: 12) {
                Text("Giriş Yapın")
                    .font(.title2)
                    .fontWeight(.bold)
                    .foregroundColor(.textPrimary)
                
                Text("Rezervasyonlarınızı görmek için lütfen giriş yapın")
                    .font(.subheadline)
                    .foregroundColor(.textSecondary)
                    .multilineTextAlignment(.center)
                    .padding(.horizontal, 40)
            }
            
            Button(action: {
                showLoginSheet = true
            }) {
                Text("Giriş Yap")
                    .font(.headline)
                    .foregroundColor(.white)
                    .frame(maxWidth: 200)
                    .padding()
                    .background(LinearGradient.primaryGradient)
                    .cornerRadius(12)
                    .shadow(color: Color.primaryOrange.opacity(0.3), radius: 8, y: 4)
            }
        }
        .padding()
    }
    
    // MARK: - Proposal Actions
    private func acceptProposedTime(for reservation: Reservation) {
        guard let reservationId = reservation.id else {
            print("❌ reservation.id is nil! Cannot accept proposal.")
            return
        }
        
        guard let proposedDate = reservation.proposedDate,
              let proposedTime = reservation.proposedTimeSlot else {
            print("❌ No proposed date/time found!")
            return
        }
        
        print("✅ Accepting proposed time: \(proposedDate.dateValue()) at \(proposedTime)")
        
        // Update reservation with new date and time
        ReservationManager.shared.acceptProposedTime(
            reservationId: reservationId,
            newDate: proposedDate.dateValue(),
            newTimeSlot: proposedTime
        ) { result in
            DispatchQueue.main.async {
                switch result {
                case .success:
                    print("✅ Proposed time accepted successfully!")
                    // Reload reservations
                    if let userId = authManager.currentUser?.uid {
                        viewModel.loadReservations(customerId: userId)
                    }
                case .failure(let error):
                    print("❌ Failed to accept proposed time: \(error.localizedDescription)")
                }
            }
        }
    }
    
    private func rejectProposedTime(for reservation: Reservation) {
        guard let reservationId = reservation.id else {
            print("❌ reservation.id is nil! Cannot reject proposal.")
            return
        }
        
        print("❌ Rejecting proposed time for reservation: \(reservationId)")
        
        // Cancel the reservation and clear proposal fields
        ReservationManager.shared.rejectProposedTime(reservationId: reservationId) { result in
            DispatchQueue.main.async {
                switch result {
                case .success:
                    print("✅ Proposed time rejected and reservation cancelled!")
                    // Reload reservations
                    if let userId = authManager.currentUser?.uid {
                        viewModel.loadReservations(customerId: userId)
                    }
                case .failure(let error):
                    print("❌ Failed to reject proposed time: \(error.localizedDescription)")
                }
            }
        }
    }
}

#Preview {
    MyReservationsScene()
        .environmentObject(AuthManager.shared)
        .environmentObject(AppEnvironment.shared)
}
