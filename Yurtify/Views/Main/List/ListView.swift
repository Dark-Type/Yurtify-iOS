//
//  ListView.swift
//  Yurtify
//
//  Created by dark type on 14.06.2025.
//

import SwiftUI

struct ListView: View {
    @StateObject private var viewModel = OffersViewModel()
    @State private var selectedOffer: UnifiedPropertyModel?
    @EnvironmentObject var apiService: APIService
    @EnvironmentObject var authManager: AuthManager
    @State private var navigationPath = NavigationPath()

    var body: some View {
        NavigationStack(path: $navigationPath) {
            VStack(spacing: 0) {
                SearchBar(
                    text: $viewModel.searchText,
                    placeholder: L10n.search,
                    onSearch: {},
                    onCancel: {}
                )
                 
                if !viewModel.isLoading {
                    HStack {
                        if viewModel.isSearching {
                            Text("🔍 \(viewModel.filteredOffers.count) результатов поиска")
                                .font(.app.footnote())
                                .foregroundColor(.app.primaryVariant)
                        } else {
                            Text("\(viewModel.filteredOffers.count) \(L10n.Detail.similarOffers)")
                                .font(.app.footnote())
                                .foregroundColor(.app.textFade)
                        }
                        
                        Spacer()
                        
                        if viewModel.isSearching && !viewModel.searchText.isEmpty {
                            Text("для '\(viewModel.searchText)'")
                                .font(.app.caption1())
                                .foregroundColor(.app.textFade)
                                .italic()
                        }
                    }
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .padding(.horizontal, 20)
                    .padding(.top, 10)
                }
                 
                ZStack {
                    if viewModel.isLoading {
                        loadingView
                    } else if viewModel.filteredOffers.isEmpty {
                        emptyResultsView
                    } else {
                        offerListView
                    }
                }
                .animation(.easeInOut, value: viewModel.isLoading)
                .animation(.easeInOut, value: viewModel.filteredOffers.isEmpty)
            }
            .background(Color.app.base)
            .navigationTitle(L10n.TabBar.list)
            .navigationBarTitleDisplayMode(.large)
            .navigationTitleColor(.app.textPrimary)
            .refreshable {
                viewModel.refresh()
            }
            .navigationDestination(for: UnifiedPropertyModel.self) { offer in
                OfferDetailView(property: offer, onDismiss: {
                    navigationPath.removeLast()
                })
            }
        }
        .onAppear {
            viewModel.setAPIService(apiService)
        }
        .environmentObject(apiService)
    }
     
    private var loadingView: some View {
        VStack(spacing: 20) {
            ProgressView()
                .scaleEffect(1.5)
                .tint(.app.primaryVariant)
             
            Text("Loading accommodations...")
                .font(.app.subheadline())
                .foregroundColor(.app.textFade)
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
    }
     
    private var emptyResultsView: some View {
        VStack(spacing: 16) {
            Image(systemName: "house.slash")
                .font(.system(size: 60))
                .foregroundColor(.app.textFade)
             
            Text("No accommodations found")
                .font(.app.title3())
                .foregroundColor(.app.textPrimary)
             
            Text("Try adjusting your search filters")
                .font(.app.subheadline())
                .foregroundColor(.app.textFade)
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
    }
     
    private var offerListView: some View {
        ScrollView {
            LazyVStack(spacing: 16) {
                ForEach(viewModel.filteredOffers) { property in
                    Button(action: {
                        navigationPath.append(property)
                    }) {
                        OfferView(property: property)
                            .environmentObject(apiService)
                            .environmentObject(authManager)
                            .background(Color.app.base)
                            .cornerRadius(12)
                    }
                    .buttonStyle(PlainButtonStyle())
                    .onAppear {
                        viewModel.loadMoreOffersIfNeeded(currentOffer: property)
                    }
                }
            }
            .padding(.horizontal, 16)
            .padding(.bottom, 24)
        }
    }
}

#Preview {
    ListView()
}
