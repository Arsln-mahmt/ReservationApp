//
//  NotificationsScene.swift
//  ReservationApp
//
//  Created by Mahmut Arslan on 25.10.2025.
//

import SwiftUI

struct NotificationsScene: View {
    @Environment(\.dismiss) var dismiss
    @State private var notifications: [NotificationItem] = []
    
    var body: some View {
        NavigationStack {
            ScrollView {
                if notifications.isEmpty {
                    emptyView
                } else {
                    LazyVStack(spacing: 12) {
                        ForEach(notifications) { notification in
                            NotificationCard(notification: notification)
                        }
                    }
                    .padding(20)
                }
            }
            .background(Color.bgPrimary)
            .navigationTitle("Bildirimler")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button("Geri") {
                        dismiss()
                    }
                }
            }
            .onAppear {
                loadNotifications()
            }
        }
    }
    
    private var emptyView: some View {
        VStack(spacing: 16) {
            Image(systemName: "bell.slash")
                .font(.system(size: 60))
                .foregroundColor(.textLight)
            
            Text("Henüz Bildirim Yok")
                .font(.title3)
                .fontWeight(.semibold)
                .foregroundColor(.textPrimary)
            
            Text("Yeni bildirimler burada görünecek")
                .font(.subheadline)
                .foregroundColor(.textSecondary)
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .padding(.top, 100)
    }
    
    private func loadNotifications() {
        // TODO: Load actual notifications from Firebase
        // For now, show empty state
        notifications = []
    }
}

// MARK: - Notification Item Model
struct NotificationItem: Identifiable {
    let id = UUID()
    let title: String
    let message: String
    let date: Date
    let isRead: Bool
    let icon: String
}

// MARK: - Notification Card
struct NotificationCard: View {
    let notification: NotificationItem
    
    var body: some View {
        HStack(alignment: .top, spacing: 16) {
            ZStack {
                Circle()
                    .fill(notification.isRead ? Color.gray.opacity(0.2) : Color.primaryOrange.opacity(0.2))
                    .frame(width: 50, height: 50)
                
                Image(systemName: notification.icon)
                    .foregroundColor(notification.isRead ? .gray : .primaryOrange)
            }
            
            VStack(alignment: .leading, spacing: 8) {
                Text(notification.title)
                    .font(.subheadline)
                    .fontWeight(notification.isRead ? .regular : .semibold)
                    .foregroundColor(.textPrimary)
                
                Text(notification.message)
                    .font(.caption)
                    .foregroundColor(.textSecondary)
                    .lineLimit(2)
                
                Text(notification.date, style: .relative)
                    .font(.caption2)
                    .foregroundColor(.textLight)
            }
            
            Spacer()
            
            if !notification.isRead {
                Circle()
                    .fill(Color.primaryOrange)
                    .frame(width: 8, height: 8)
            }
        }
        .padding()
        .background(Color.bgCard)
        .cornerRadius(12)
    }
}

#Preview {
    NotificationsScene()
}

