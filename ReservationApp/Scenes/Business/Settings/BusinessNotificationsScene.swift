//
//  BusinessNotificationsScene.swift
//  ReservationApp
//
//  Created by Mahmut Arslan on 23.12.2025.
//

import SwiftUI

struct BusinessNotificationsScene: View {
    @Environment(\.dismiss) var dismiss
    @EnvironmentObject var authManager: AuthManager
    @StateObject private var notificationManager = BusinessNotificationManager.shared
    
    var body: some View {
        NavigationStack {
            ZStack {
                Color.bgPrimary.ignoresSafeArea()
                
                if notificationManager.notifications.isEmpty {
                    emptyStateView
                } else {
                    notificationsList
                }
            }
            .navigationTitle("Bildirimler")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button("Kapat") { dismiss() }
                }
                
                if notificationManager.unreadCount > 0 {
                    ToolbarItem(placement: .navigationBarTrailing) {
                        Button("Tümünü Okundu İşaretle") {
                            if let businessId = authManager.currentUser?.uid {
                                notificationManager.markAllAsRead(businessId: businessId)
                            }
                        }
                        .font(.caption)
                    }
                }
            }
            .onAppear {
                if let businessId = authManager.currentUser?.uid {
                    notificationManager.startListening(businessId: businessId)
                }
            }
            .onDisappear {
                // Keep listening in background for badge updates
                // notificationManager.stopListening()
            }
        }
    }
    
    // MARK: - Empty State
    private var emptyStateView: some View {
        VStack(spacing: 20) {
            Image(systemName: "bell.slash")
                .font(.system(size: 60))
                .foregroundColor(.textLight)
            
            Text("Henüz Bildirim Yok")
                .font(.title3)
                .fontWeight(.semibold)
                .foregroundColor(.textPrimary)
            
            Text("Müşterileriniz randevu aldığında veya iptal ettiğinde burada bildirimler göreceksiniz.")
                .font(.subheadline)
                .foregroundColor(.textSecondary)
                .multilineTextAlignment(.center)
                .padding(.horizontal, 40)
        }
    }
    
    // MARK: - Notifications List
    private var notificationsList: some View {
        ScrollView {
            LazyVStack(spacing: 12) {
                ForEach(notificationManager.notifications) { notification in
                    BusinessNotificationCard(notification: notification) {
                        if let id = notification.id, !notification.isRead {
                            notificationManager.markAsRead(notificationId: id)
                        }
                    }
                }
            }
            .padding(20)
        }
    }
}

// MARK: - Business Notification Card
struct BusinessNotificationCard: View {
    let notification: BusinessNotification
    let onTap: () -> Void
    
    var body: some View {
        Button(action: onTap) {
            HStack(alignment: .top, spacing: 16) {
                // Icon
                ZStack {
                    Circle()
                        .fill(iconBackgroundColor.opacity(0.15))
                        .frame(width: 50, height: 50)
                    
                    Image(systemName: notification.type.icon)
                        .font(.title3)
                        .foregroundColor(iconBackgroundColor)
                }
                
                // Content
                VStack(alignment: .leading, spacing: 6) {
                    HStack {
                        Text(notification.title)
                            .font(.subheadline)
                            .fontWeight(notification.isRead ? .regular : .bold)
                            .foregroundColor(.textPrimary)
                        
                        Spacer()
                        
                        if !notification.isRead {
                            Circle()
                                .fill(Color.primaryOrange)
                                .frame(width: 8, height: 8)
                        }
                    }
                    
                    Text(notification.message)
                        .font(.caption)
                        .foregroundColor(.textSecondary)
                        .lineLimit(3)
                        .multilineTextAlignment(.leading)
                    
                    // Time and details
                    HStack(spacing: 12) {
                        Text(notification.relativeTime)
                            .font(.caption2)
                            .foregroundColor(.textLight)
                        
                        if let date = notification.appointmentDate,
                           let time = notification.appointmentTime {
                            HStack(spacing: 4) {
                                Image(systemName: "calendar")
                                    .font(.caption2)
                                Text("\(date) - \(time)")
                                    .font(.caption2)
                            }
                            .foregroundColor(.textLight)
                        }
                    }
                }
            }
            .padding(16)
            .background(
                Group {
                    if notification.isRead {
                        Color.bgCard
                    } else {
                        Color.bgCard.overlay(Color.primaryOrange.opacity(0.05))
                    }
                }
            )
            .cornerRadius(16)
            .shadow(color: Color.black.opacity(0.05), radius: 5, y: 2)
        }
        .buttonStyle(PlainButtonStyle())
    }
    
    private var iconBackgroundColor: Color {
        switch notification.type.color {
        case "green": return .green
        case "red": return .red
        case "orange": return .orange
        case "blue": return .blue
        case "purple": return .purple
        default: return .primaryOrange
        }
    }
}

// MARK: - Settings Button with Badge
struct SettingsButtonWithBadge: View {
    let icon: String
    let title: String
    let subtitle: String?
    let badgeCount: Int
    let action: () -> Void
    
    var body: some View {
        Button(action: action) {
            HStack(spacing: 16) {
                // Icon with badge
                ZStack(alignment: .topTrailing) {
                    Image(systemName: icon)
                        .font(.title3)
                        .foregroundColor(.primaryOrange)
                        .frame(width: 30)
                    
                    if badgeCount > 0 {
                        Text(badgeCount > 99 ? "99+" : "\(badgeCount)")
                            .font(.system(size: 10, weight: .bold))
                            .foregroundColor(.white)
                            .padding(.horizontal, 5)
                            .padding(.vertical, 2)
                            .background(Color.red)
                            .clipShape(Capsule())
                            .offset(x: 8, y: -8)
                    }
                }
                
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

#Preview {
    BusinessNotificationsScene()
        .environmentObject(AuthManager.shared)
}
