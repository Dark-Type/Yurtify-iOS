//
//  BookingDateSheet.swift
//  Yurtify
//
//  Created by dark type on 29.06.2025.
//

import SwiftUI

struct BookingDateSheet: View {
    @ObservedObject var viewModel: OfferDetailViewModel
    @Binding var isPresented: Bool
    
    var body: some View {
        NavigationView {
            VStack(spacing: 24) {
                headerSection
                
                if let property = viewModel.property {
                    unavailableDatesInfo(property: property)
                }
                
                dateSelectionSection
                
                if let error = viewModel.bookingError {
                    errorSection(error: error)
                }
                
                Spacer()
                
                bookingButton
            }
            .padding()
            .navigationTitle("Select Dates")
            .navigationBarTitleDisplayMode(.inline)
            .navigationBarItems(
                leading: Button("Cancel") {
                    isPresented = false
                },
                trailing: EmptyView()
            )
        }
    }
    
    private var headerSection: some View {
        VStack(spacing: 16) {
            Image(systemName: "calendar.badge.clock")
                .font(.system(size: 50))
                .foregroundColor(Color.app.primaryVariant)
            
            Text("Choose Your Stay")
                .font(.app.latoBold(size: 24))
                .foregroundColor(Color.app.textPrimary)
            
            Text("Select your check-in and check-out dates")
                .font(.app.latoRegular(size: 16))
                .foregroundColor(Color.app.textFade)
                .multilineTextAlignment(.center)
        }
    }
    
    private func unavailableDatesInfo(property: UnifiedPropertyModel) -> some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("Availability Information")
                .font(.app.latoBold(size: 18))
                .foregroundColor(Color.app.textPrimary)
            
            VStack(alignment: .leading, spacing: 8) {
                HStack {
                    Image(systemName: "calendar.badge.checkmark")
                        .foregroundColor(.green)
                    Text("Available from: \(formatDate(property.firstFreeDate))")
                        .font(.app.latoRegular(size: 14))
                        .foregroundColor(Color.app.textPrimary)
                }
                
                if let lastDate = property.firstClosedDate {
                    HStack {
                        Image(systemName: "calendar.badge.exclamationmark")
                            .foregroundColor(.orange)
                        Text("Available until: \(formatDate(lastDate))")
                            .font(.app.latoRegular(size: 14))
                            .foregroundColor(Color.app.textPrimary)
                    }
                }
                
                if !property.closedDates.isEmpty {
                    HStack {
                        Image(systemName: "calendar.badge.minus")
                            .foregroundColor(.red)
                        Text("Unavailable dates: \(property.closedDates.count) day(s)")
                            .font(.app.latoRegular(size: 14))
                            .foregroundColor(Color.app.textPrimary)
                    }
                }
            }
        }
        .padding()
        .background(Color.app.accentLight)
        .cornerRadius(12)
    }
    
    private var dateSelectionSection: some View {
        VStack(spacing: 20) {
            VStack(alignment: .leading, spacing: 12) {
                Text("Check-in Date")
                    .font(.app.latoBold(size: 16))
                    .foregroundColor(Color.app.textPrimary)
                
                DatePicker(
                    "",
                    selection: $viewModel.selectedStartDate,
                    in: dateRange,
                    displayedComponents: .date
                )
                .datePickerStyle(.compact)
                .labelsHidden()
            }
            
            VStack(alignment: .leading, spacing: 12) {
                Text("Check-out Date")
                    .font(.app.latoBold(size: 16))
                    .foregroundColor(Color.app.textPrimary)
                
                DatePicker(
                    "",
                    selection: $viewModel.selectedEndDate,
                    in: checkoutDateRange,
                    displayedComponents: .date
                )
                .datePickerStyle(.compact)
                .labelsHidden()
            }
            
            VStack(spacing: 8) {
                Text("Duration: \(numberOfNights) night(s)")
                    .font(.app.latoBold(size: 16))
                    .foregroundColor(Color.app.textPrimary)
                
                if let property = viewModel.property {
                    Text("Total: \(calculateTotalPrice(property: property))")
                        .font(.app.latoBold(size: 20))
                        .foregroundColor(Color.app.primaryVariant)
                }
            }
            .padding()
            .background(Color.app.accentLight)
            .cornerRadius(12)
        }
    }
    
    private func errorSection(error: String) -> some View {
        HStack {
            Image(systemName: "exclamationmark.triangle.fill")
                .foregroundColor(.red)
            Text(error)
                .font(.app.latoRegular(size: 14))
                .foregroundColor(.red)
        }
        .padding()
        .background(Color.red.opacity(0.1))
        .cornerRadius(8)
    }
    
    private var bookingButton: some View {
        Button(action: {
            Task {
                await viewModel.bookProperty()
            }
        }) {
            HStack {
                if viewModel.isBooking {
                    ProgressView()
                        .scaleEffect(0.8)
                        .tint(.white)
                } else {
                    Text("Book Now")
                }
            }
            .font(.app.latoBold(size: 16))
            .foregroundColor(.white)
            .frame(maxWidth: .infinity)
            .padding()
            .background(
                viewModel.isBooking ? Color.gray : Color.app.primaryVariant
            )
            .cornerRadius(12)
        }
        .disabled(viewModel.isBooking)
    }
    
    // MARK: - Helper Properties
    
    private var dateRange: ClosedRange<Date> {
        let startDate = viewModel.property?.firstFreeDate ?? Date()
        let endDate = viewModel.property?.firstClosedDate ?? 
            Calendar.current.date(byAdding: .year, value: 1, to: Date()) ?? Date()
        return startDate...endDate
    }
    
    private var checkoutDateRange: ClosedRange<Date> {
        let startDate = Calendar.current.date(byAdding: .day, value: 1, to: viewModel.selectedStartDate) ?? 
            viewModel.selectedStartDate
        let endDate = viewModel.property?.firstClosedDate ?? 
            Calendar.current.date(byAdding: .year, value: 1, to: Date()) ?? Date()
        return startDate...endDate
    }
    
    private var numberOfNights: Int {
        Calendar.current.dateComponents([.day], from: viewModel.selectedStartDate, to: viewModel.selectedEndDate).day ?? 0
    }
    
    private func formatDate(_ date: Date) -> String {
        let formatter = DateFormatter()
        formatter.dateStyle = .medium
        return formatter.string(from: date)
    }
    
    private func calculateTotalPrice(property: UnifiedPropertyModel) -> String {
        let nights = numberOfNights
        let totalPrice: Double
        
        switch property.period {
        case .perDay:
            totalPrice = property.cost * Double(nights)
        case .perWeek:
            totalPrice = property.cost * Double(nights) / 7.0
        case .perMonth:
            totalPrice = property.cost * Double(nights) / 30.0
        }
        
        return "\(totalPrice)" + " с"
    }
}
