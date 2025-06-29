//
//  NotificationsView.swift
//  Yurtify
//
//  Created by dark type on 14.06.2025.
//

import SwiftUI

struct NotificationsView: View {
    @StateObject private var viewModel = NotificationsViewModel()
    
    var body: some View {
        NavigationStack {
            List {
                ForEach(groupedNotifications.keys.sorted(by: >), id: \.self) { date in
                    Section {
                        ForEach(groupedNotifications[date] ?? []) { notification in
                            NotificationItemView(
                                notification: notification,
                                viewModel: viewModel,
                                onTap: {
                                    viewModel.markAsRead(notification)
                                }
                            )
                            .listRowInsets(EdgeInsets())
                            .listRowSeparator(.hidden)
                            .listRowBackground(Color.clear)
                        }
                    } header: {
                        SectionHeaderBackground {
                            HStack {
                                Text(sectionTitle(for: date))
                                    .font(.app.headline())
                                    .foregroundColor(.app.textPrimary)
                                    .padding(.vertical, 8)
                                Spacer()
                            }
                        }
                    }
                    .listSectionSeparator(.hidden)
                }
                
                Section {
                    Color.clear
                        .frame(height: 150)
                        .listRowInsets(EdgeInsets())
                        .listRowSeparator(.hidden)
                        .listRowBackground(Color.app.base)
                }
            }
            .listStyle(PlainListStyle())
            .scrollContentBackground(.hidden)
            .background(Color.app.base)
            .navigationTitle(L10n.TabBar.notifications)
            .navigationBarTitleDisplayMode(.large)
            .customNavigationBarAppearance(
                backgroundColor: Color.app.base,
                titleColor: Color.app.textPrimary
            )
        }
    }
    
    private var groupedNotifications: [Date: [NotificationItem]] {
        let calendar = Calendar.current
        var result = [Date: [NotificationItem]]()
        
        for notification in viewModel.notifications {
            let components = calendar.dateComponents([.year, .month, .day], from: notification.timestamp)
            if let date = calendar.date(from: components) {
                var array = result[date] ?? []
                array.append(notification)
                result[date] = array
            }
        }
        
        for (date, notifications) in result {
            result[date] = notifications.sorted { $0.timestamp > $1.timestamp }
        }
        
        return result
    }
    
    private func sectionTitle(for date: Date) -> String {
        let calendar = Calendar.current
        
        if calendar.isDateInToday(date) {
            return L10n.Notifications.today
        } else if calendar.isDateInYesterday(date) {
            return L10n.Notifications.yesterday
        } else if isDateInLastWeek(date, using: calendar) {
            let formatter = DateFormatter()
            formatter.dateFormat = "EEEE"
            return formatter.string(from: date)
        } else {
            let formatter = DateFormatter()
            formatter.dateStyle = .medium
            formatter.timeStyle = .none
            return formatter.string(from: date)
        }
    }
    
    private func isDateInLastWeek(_ date: Date, using calendar: Calendar) -> Bool {
        let now = Date()
        if let oneWeekAgo = calendar.date(byAdding: .day, value: -7, to: now) {
            return date > oneWeekAgo && date < now
        }
        return false
    }
}

struct SectionHeaderBackground<Content: View>: View {
    let content: Content
    
    init(@ViewBuilder content: () -> Content) {
        self.content = content()
    }
    
    var body: some View {
        content
            .frame(maxWidth: .infinity, alignment: .leading)
            .padding(.horizontal, 16)
            .background(
                GeometryReader { geometry in
                    Color.app.base
                        .frame(width: geometry.size.width + 32)
                        .offset(x: -16)
                }
            )
            .listRowInsets(EdgeInsets(top: 0, leading: 0, bottom: 0, trailing: 0))
            .textCase(nil)
    }
}

#Preview {
    NotificationsView()
}
