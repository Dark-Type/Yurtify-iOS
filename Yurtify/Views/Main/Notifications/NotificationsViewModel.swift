//
//  NotificationType.swift
//  Yurtify
//
//  Created by dark type on 25.06.2025.
//

import SwiftUI

enum NotificationType {
    case owner
    case customer
}

enum NotificationActionState {
    case pending
    case approved
    case declined
    case cancelled
}

struct NotificationItem: Identifiable {
    let id = UUID()
    let type: NotificationType
    let title: String
    let description: String
    let timestamp: Date
    var isRead: Bool
    let userContacts: UserContacts
    var actionState: NotificationActionState = .pending
    var isReservationActive: Bool = true
}

class NotificationsViewModel: ObservableObject {
    @Published var notifications: [NotificationItem] = []
    private var apiService: APIService!
    
    func setAPIService(_ apiService: APIService) {
        self.apiService = apiService
    }

    init() {
        loadMockData()
    }
    
    func markAsRead(_ notification: NotificationItem) {
        if let index = notifications.firstIndex(where: { $0.id == notification.id }) {
            notifications[index].isRead = true
        }
    }
    
    func approveRentOffer(_ notification: NotificationItem) {
        if let index = notifications.firstIndex(where: { $0.id == notification.id }) {
            notifications[index].actionState = .approved
        }
    }
    
    func declineRentOffer(_ notification: NotificationItem) {
        if let index = notifications.firstIndex(where: { $0.id == notification.id }) {
            notifications[index].actionState = .declined
        }
    }
    
    func cancelReservation(_ notification: NotificationItem) {
        if let index = notifications.firstIndex(where: { $0.id == notification.id }) {
            notifications[index].actionState = .cancelled
        }
    }
    
    private func loadMockData() {
        let calendar = Calendar.current
        
        let placeholderOwnerContact = UserContacts(
            image: Image(systemName: "person.circle.fill")
                .resizable(),
            firstName: "Alex",
            lastName: "Smith",
            patronymic: nil,
            email: "alex.smith@example.com",
            phoneNumber: "+1 (555) 123-4567"
        )
        
        let placeholderCustomerContact = UserContacts(
            image: Image(systemName: "person.2.circle.fill")
                .resizable(),
            firstName: "Maria",
            lastName: "Johnson",
            patronymic: "Ivanovna",
            email: "maria.johnson@example.com",
            phoneNumber: "+1 (555) 987-6543"
        )
        
        let now = Date()
        notifications.append(NotificationItem(
            type: .owner,
            title: L10n.Notifications.title,
            description: L10n.Notifications.confirmation,
            timestamp: now.addingTimeInterval(-3600),
            isRead: false,
            userContacts: placeholderOwnerContact,
            actionState: .pending,
            isReservationActive: true
        ))
        
        notifications.append(NotificationItem(
            type: .customer,
            title: L10n.Notifications.title,
            description: L10n.Notifications.client,
            timestamp: now.addingTimeInterval(-7200),
            isRead: true,
            userContacts: placeholderCustomerContact,
            actionState: .pending,
            isReservationActive: true
        ))
        
        if let yesterday = calendar.date(byAdding: .day, value: -1, to: now) {
            notifications.append(NotificationItem(
                type: .owner,
                title: L10n.Notifications.title,
                description: L10n.Notifications.confirmation,
                timestamp: yesterday.addingTimeInterval(-3600),
                isRead: true,
                userContacts: placeholderOwnerContact,
                actionState: .approved,
                isReservationActive: true
            ))
            
            notifications.append(NotificationItem(
                type: .customer,
                title: L10n.Notifications.title,
                description: L10n.Notifications.client,
                timestamp: yesterday.addingTimeInterval(-7200),
                isRead: false,
                userContacts: placeholderCustomerContact,
                actionState: .pending,
                isReservationActive: false
            ))
        }
        
        if let lastWeek = calendar.date(byAdding: .day, value: -5, to: now) {
            notifications.append(NotificationItem(
                type: .owner,
                title: L10n.Notifications.title,
                description: L10n.Notifications.confirmation,
                timestamp: lastWeek,
                isRead: true,
                userContacts: placeholderOwnerContact,
                actionState: .declined,
                isReservationActive: true
            ))
        }
        
        if let oldDate = calendar.date(byAdding: .day, value: -15, to: now) {
            notifications.append(NotificationItem(
                type: .customer,
                title: L10n.Notifications.title,
                description: L10n.Notifications.client,
                timestamp: oldDate,
                isRead: true,
                userContacts: placeholderCustomerContact,
                actionState: .cancelled,
                isReservationActive: true
            ))
        }
    }
}
