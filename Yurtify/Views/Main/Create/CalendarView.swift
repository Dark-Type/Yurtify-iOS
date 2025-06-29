//
//  CalendarView.swift
//  Yurtify
//
//  Created by dark type on 29.06.2025.
//

import SwiftUI

struct CalendarView: View {
    @Binding var unavailableDates: Set<Date>
    let startDate: Date
    let endDate: Date
    
    @State private var currentMonth = Date()
    
    private let calendar = Calendar.current
    private let dateFormatter: DateFormatter = {
        let formatter = DateFormatter()
        formatter.dateFormat = "MMMM yyyy"
        return formatter
    }()
    
    var body: some View {
        VStack(spacing: 0) {
            HStack {
                Button(action: previousMonth) {
                    Image(systemName: "chevron.left")
                        .foregroundColor(Color.app.primaryVariant)
                }
                
                Spacer()
                
                Text(dateFormatter.string(from: currentMonth))
                    .font(.app.latoBold(size: 18))
                    .foregroundColor(Color.app.textPrimary)
                
                Spacer()
                
                Button(action: nextMonth) {
                    Image(systemName: "chevron.right")
                        .foregroundColor(Color.app.primaryVariant)
                }
            }
            .padding(.horizontal)
            .padding(.bottom, 16)
            
            HStack {
                ForEach(calendar.shortWeekdaySymbols, id: \.self) { day in
                    Text(day)
                        .font(.app.latoRegular(size: 12))
                        .foregroundColor(Color.app.textFade)
                        .frame(maxWidth: .infinity)
                }
            }
            .padding(.bottom, 8)
            
            LazyVGrid(columns: Array(repeating: GridItem(.flexible()), count: 7), spacing: 8) {
                ForEach(daysInMonth, id: \.self) { date in
                    if let date = date {
                        DayView(
                            date: date,
                            isInRange: isDateInRange(date),
                            isUnavailable: unavailableDates.contains(date),
                            isStartDate: calendar.isDate(date, inSameDayAs: startDate),
                            isEndDate: calendar.isDate(date, inSameDayAs: endDate)
                        ) {
                            toggleDate(date)
                        }
                    } else {
                        Color.clear
                            .frame(height: 36)
                    }
                }
            }
        }
        .padding()
        .background(Color.app.accentLight)
        .cornerRadius(12)
    }
    
    private var daysInMonth: [Date?] {
        guard let monthInterval = calendar.dateInterval(of: .month, for: currentMonth) else {
            return []
        }
        
        let firstOfMonth = monthInterval.start
        let firstWeekday = calendar.component(.weekday, from: firstOfMonth)
        let daysInMonth = calendar.range(of: .day, in: .month, for: currentMonth)?.count ?? 0
        
        var days: [Date?] = []
        
        for _ in 1 ..< firstWeekday {
            days.append(nil)
        }
        
        for day in 1 ... daysInMonth {
            if let date = calendar.date(byAdding: .day, value: day - 1, to: firstOfMonth) {
                days.append(date)
            }
        }
        
        return days
    }
    
    private func isDateInRange(_ date: Date) -> Bool {
        return date >= startDate && date <= endDate
    }
    
    private func toggleDate(_ date: Date) {
        if unavailableDates.contains(date) {
            unavailableDates.remove(date)
        } else {
            unavailableDates.insert(date)
        }
    }
    
    private func previousMonth() {
        withAnimation {
            currentMonth = calendar.date(byAdding: .month, value: -1, to: currentMonth) ?? currentMonth
        }
    }
    
    private func nextMonth() {
        withAnimation {
            currentMonth = calendar.date(byAdding: .month, value: 1, to: currentMonth) ?? currentMonth
        }
    }
}

struct DayView: View {
    let date: Date
    let isInRange: Bool
    let isUnavailable: Bool
    let isStartDate: Bool
    let isEndDate: Bool
    let action: () -> Void
    
    private let day = Calendar.current.component(.day, from: Date())
    
    var body: some View {
        Button(action: action) {
            Text("\(Calendar.current.component(.day, from: date))")
                .font(.app.latoRegular(size: 14))
                .foregroundColor(textColor)
                .frame(width: 36, height: 36)
                .background(backgroundColor)
                .cornerRadius(8)
                .overlay(
                    RoundedRectangle(cornerRadius: 8)
                        .stroke(borderColor, lineWidth: borderWidth)
                )
        }
        .disabled(!isInRange)
    }
    
    private var textColor: Color {
        if !isInRange {
            return Color.app.textFade.opacity(0.3)
        } else if isStartDate || isEndDate {
            return Color.white
        } else if isUnavailable {
            return Color.white
        } else {
            return Color.app.textPrimary
        }
    }
    
    private var backgroundColor: Color {
        if isStartDate || isEndDate {
            return Color.app.primaryVariant
        } else if isUnavailable {
            return Color.red.opacity(0.7)
        } else if isInRange {
            return Color.app.accentLight
        } else {
            return Color.clear
        }
    }
    
    private var borderColor: Color {
        if isStartDate || isEndDate {
            return Color.app.primaryVariant
        } else {
            return Color.clear
        }
    }
    
    private var borderWidth: CGFloat {
        return (isStartDate || isEndDate) ? 2 : 0
    }
}
