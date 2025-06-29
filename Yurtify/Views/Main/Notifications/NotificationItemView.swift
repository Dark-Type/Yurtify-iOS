//
//  NotificationItemView.swift
//  Yurtify
//
//  Created by dark type on 25.06.2025.
//

import SwiftUI

struct NotificationItemView: View {
    let notification: NotificationItem
    let viewModel: NotificationsViewModel
    @State private var isProfilePopoverPresented = false
    @State private var showingApprovalAlert = false
    @State private var showingDeclineAlert = false
    @State private var showingCancelAlert = false
    var onTap: () -> Void
    
    var body: some View {
        VStack(spacing: 0) {
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
                        
                        Button(action: {
                            onTap()
                            isProfilePopoverPresented = true
                        }) {
                            Image(systemName: "info.circle")
                                .font(.system(size: 16))
                                .foregroundColor(AppColors.primaryVariant)
                                .padding(4)
                        }
                        .buttonStyle(PlainButtonStyle())
                        
                        Text(formatTime(notification.timestamp))
                            .font(.app.caption2())
                            .foregroundColor(AppColors.textSecondary)
                    }
                    
                    Text(notification.description)
                        .font(.app.subheadline())
                        .foregroundColor(AppColors.textSecondary)
                        .lineLimit(2)
                        .multilineTextAlignment(.leading)
                }
                
                VStack {
                    if !notification.isRead {
                        Circle()
                            .fill(notification.type == .owner ? AppColors.accentDark : AppColors.primaryVariant)
                            .frame(width: 8, height: 8)
                    }
                    Spacer()
                }
            }
            .padding(.vertical, 12)
            .padding(.horizontal, 16)
            .contentShape(Rectangle())
            .onTapGesture {
                if !notification.isRead {
                    onTap()
                }
            }
            
            if notification.actionState == .pending {
                actionButtonsSection
                    .padding(.horizontal, 16)
                    .padding(.bottom, 12)
            } else {
                actionStatusSection
                    .padding(.horizontal, 16)
                    .padding(.bottom, 12)
            }
        }
        .background(
            RoundedRectangle(cornerRadius: 12)
                .fill(notification.isRead ? AppColors.accentLight : AppColors.secondaryVariant.opacity(0.3))
        )
        .clipShape(RoundedRectangle(cornerRadius: 12))
        .padding(.horizontal, 16)
        .padding(.vertical, 4)
        .popover(isPresented: $isProfilePopoverPresented, arrowEdge: .top) {
            CompactUserProfileView(userContacts: notification.userContacts)
                .presentationCompactAdaptation(.popover)
        }
        .alert("Approve Rent Request", isPresented: $showingApprovalAlert) {
            Button("Cancel", role: .cancel) {}
            Button("Approve", role: .destructive) {
                viewModel.approveRentOffer(notification)
            }
        } message: {
            Text("Are you sure you want to approve this rent request?")
        }
        .alert("Decline Rent Request", isPresented: $showingDeclineAlert) {
            Button("Cancel", role: .cancel) {}
            Button("Decline", role: .destructive) {
                viewModel.declineRentOffer(notification)
            }
        } message: {
            Text("Are you sure you want to decline this rent request?")
        }
        .alert("Cancel Reservation", isPresented: $showingCancelAlert) {
            Button("Cancel", role: .cancel) {}
            Button("Cancel Reservation", role: .destructive) {
                viewModel.cancelReservation(notification)
            }
        } message: {
            Text("Are you sure you want to cancel your reservation?")
        }
    }
    
    @ViewBuilder
    private var actionButtonsSection: some View {
        if notification.type == .owner {
            HStack(spacing: 12) {
                Button(action: {
                    showingApprovalAlert = true
                }) {
                    HStack(spacing: 6) {
                        Image(systemName: "checkmark.circle")
                            .font(.system(size: 14))
                        Text("Approve")
                    }
                    .font(.app.subheadline(.semiBold))
                    .foregroundColor(.white)
                    .frame(maxWidth: .infinity)
                    .padding(.vertical, 10)
                    .background(AppColors.primaryVariant)
                    .cornerRadius(8)
                }
                .buttonStyle(PlainButtonStyle())
                
                Button(action: {
                    showingDeclineAlert = true
                }) {
                    HStack(spacing: 6) {
                        Image(systemName: "xmark.circle")
                            .font(.system(size: 14))
                        Text("Decline")
                    }
                    .font(.app.subheadline(.semiBold))
                    .foregroundColor(AppColors.primaryVariant)
                    .frame(maxWidth: .infinity)
                    .padding(.vertical, 10)
                    .background(AppColors.base)
                    .overlay(
                        RoundedRectangle(cornerRadius: 8)
                            .stroke(AppColors.primaryVariant, lineWidth: 1)
                    )
                    .cornerRadius(8)
                }
                .buttonStyle(PlainButtonStyle())
            }
        } else {
            Button(action: {
                showingCancelAlert = true
            }) {
                HStack(spacing: 6) {
                    Image(systemName: "minus.circle")
                        .font(.system(size: 14))
                    Text("Cancel Reservation")
                }
                .font(.app.subheadline(.semiBold))
                .foregroundColor(notification.isReservationActive ? .white : AppColors.textFade)
                .frame(maxWidth: .infinity)
                .padding(.vertical, 10)
                .background(notification.isReservationActive ? .red : AppColors.textFade.opacity(0.3))
                .cornerRadius(8)
            }
            .buttonStyle(PlainButtonStyle())
            .disabled(!notification.isReservationActive)
        }
    }
    
    @ViewBuilder
    private var actionStatusSection: some View {
        HStack {
            Image(systemName: statusIcon)
                .foregroundColor(statusColor)
                .font(.system(size: 14))
            
            Text(statusText)
                .font(.app.caption1())
                .foregroundColor(statusColor)
            
            Spacer()
        }
        .padding(.vertical, 8)
        .padding(.horizontal, 12)
        .background(statusColor.opacity(0.1))
        .cornerRadius(8)
    }
    
    private var statusIcon: String {
        switch notification.actionState {
        case .approved:
            return "checkmark.circle.fill"
        case .declined:
            return "xmark.circle.fill"
        case .cancelled:
            return "minus.circle.fill"
        case .pending:
            return "clock.fill"
        }
    }
    
    private var statusColor: Color {
        switch notification.actionState {
        case .approved:
            return .green
        case .declined:
            return .red
        case .cancelled:
            return .orange
        case .pending:
            return AppColors.textFade
        }
    }
    
    private var statusText: String {
        switch notification.actionState {
        case .approved:
            return "Request Approved"
        case .declined:
            return "Request Declined"
        case .cancelled:
            return "Reservation Cancelled"
        case .pending:
            return "Pending Action"
        }
    }
    
    private func formatTime(_ date: Date) -> String {
        let formatter = DateFormatter()
        formatter.dateFormat = "HH:mm"
        return formatter.string(from: date)
    }
}
