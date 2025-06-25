//
//  NotificationItemView.swift
//  Yurtify
//
//  Created by dark type on 25.06.2025.
//

import SwiftUI

struct NotificationItemView: View {
    let notification: NotificationItem
    @State private var isProfilePopoverPresented = false
    var onTap: () -> Void
    
    var body: some View {
        Button(action: {
            onTap()
            isProfilePopoverPresented.toggle()
        }) {
            HStack(spacing: 16) {
                ZStack {
                    Circle()
                        .fill(notification.type == .owner ? AppColors.accentLight : AppColors.alternativeVariant)
                        .frame(width: 44, height: 44)
                    
                    if notification.type == .owner {
                        AppIcons.mailbox.image
                            .resizable()
                            .renderingMode(.template)
                            .aspectRatio(contentMode: .fit)
                            .frame(width: 24, height: 24)
                            .foregroundColor(AppColors.accentDark)
                    } else {
                        Image(systemName: "calendar")
                            .resizable()
                            .aspectRatio(contentMode: .fit)
                            .frame(width: 24, height: 24)
                            .foregroundColor(AppColors.base)
                    }
                }
                
                VStack(alignment: .leading, spacing: 4) {
                    HStack {
                        Text(notification.title)
                            .font(.app.headline())
                            .foregroundColor(AppColors.textPrimary)
                        
                        Spacer()
                        
                        Text(formatTime(notification.timestamp))
                            .font(.app.caption2())
                            .foregroundColor(AppColors.textSecondary)
                    }
                    
                    Text(notification.description)
                        .font(.app.subheadline())
                        .foregroundColor(AppColors.textSecondary)
                        .lineLimit(2)
                }
                
                if !notification.isRead {
                    Circle()
                        .fill(notification.type == .owner ? AppColors.accentDark : AppColors.primaryVariant)
                        .frame(width: 8, height: 8)
                }
            }
            .padding(.vertical, 12)
            .padding(.horizontal, 16)
            .background(
                RoundedRectangle(cornerRadius: 12)
                    .fill(notification.isRead ? AppColors.accentLight : AppColors.secondaryVariant.opacity(0.3))
            )
            .clipShape(RoundedRectangle(cornerRadius: 12))
            .contentShape(RoundedRectangle(cornerRadius: 12))
        }
        .buttonStyle(PlainButtonStyle())
        .padding(.horizontal, 16)
        .padding(.vertical, 4)
        .popover(isPresented: $isProfilePopoverPresented, arrowEdge: .top) {
            CompactUserProfileView(userContacts: notification.userContacts)
                .presentationCompactAdaptation(.popover)
        }
    }
    
    private func formatTime(_ date: Date) -> String {
        let formatter = DateFormatter()
        formatter.dateFormat = "HH:mm"
        return formatter.string(from: date)
    }
}
