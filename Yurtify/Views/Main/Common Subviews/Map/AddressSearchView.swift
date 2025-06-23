//
//  AddressSearchView.swift
//  Yurtify
//
//  Created by dark type on 23.06.2025.
//

import MapKit
import SwiftUI

class SearchCompleterDelegateWrapper: NSObject, ObservableObject, MKLocalSearchCompleterDelegate {
    var onResults: (([MKLocalSearchCompletion]) -> Void) = { _ in }
    
    func completerDidUpdateResults(_ completer: MKLocalSearchCompleter) {
        onResults(completer.results)
    }
    
    func completer(_ completer: MKLocalSearchCompleter, didFailWithError error: Error) {
        print("Search completer error: \(error)")
        onResults([])
    }
}

struct AddressSearchView: View {
    @Binding var address: Address
    @State private var searchText = ""
    @State private var searchResults = [MKLocalSearchCompletion]()
    @State private var isSearching = false
    @Binding var isPresented: Bool
    
    var onAddressSelected: ((Address) -> Void)?
    
    @StateObject private var searchCompleterDelegate = SearchCompleterDelegateWrapper()
    @State private var searchCompleter: MKLocalSearchCompleter?
    
    var body: some View {
        NavigationView {
            VStack(spacing: 0) {
                VStack(spacing: 0) {
                    HStack {
                        Image(systemName: "magnifyingglass")
                            .foregroundColor(.gray)
                        
                        TextField("Search for address...", text: $searchText)
                            .disableAutocorrection(true)
                            .foregroundColor(.black)
                            .autocapitalization(.none)
                        
                        if !searchText.isEmpty {
                            Button(action: {
                                searchText = ""
                            }) {
                                Image(systemName: "xmark.circle.fill")
                                    .foregroundColor(.gray)
                            }
                        }
                    }
                    .padding(10)
                    .background(Color.white)
                    .cornerRadius(10)
                    .overlay(
                        RoundedRectangle(cornerRadius: 10)
                            .stroke(Color.gray.opacity(0.3), lineWidth: 1)
                    )
                    .padding(.horizontal)
                    .padding(.top, 8)
                    
                    Divider()
                        .padding(.top, 8)
                }
                .background(Color(.systemBackground))
                .zIndex(1)
                
                ZStack {
                    if isSearching {
                        ProgressView()
                            .padding()
                    } else if searchText.isEmpty {
                        VStack(spacing: 12) {
                            Image(systemName: "location.magnifyingglass")
                                .font(.system(size: 40))
                                .foregroundColor(.gray)
                            
                            Text("Search for an Address")
                                .font(.headline)
                            
                            Text("Type to search for streets, house numbers, or places")
                                .font(.subheadline)
                                .foregroundColor(.secondary)
                                .multilineTextAlignment(.center)
                                .padding(.horizontal)
                        }
                        .padding()
                    } else {
                        ScrollView {
                            LazyVStack(alignment: .leading, spacing: 0) {
                                ForEach(searchResults, id: \.self) { result in
                                    Button(action: {
                                        selectSearchResult(result)
                                    }) {
                                        VStack(alignment: .leading, spacing: 4) {
                                            Text(result.title)
                                                .font(.headline)
                                                .foregroundColor(.primary)
                                            
                                            Text(result.subtitle)
                                                .font(.subheadline)
                                                .foregroundColor(.secondary)
                                        }
                                        .padding(.vertical, 12)
                                        .padding(.horizontal, 16)
                                        .frame(maxWidth: .infinity, alignment: .leading)
                                        .contentShape(Rectangle())
                                    }
                                    .buttonStyle(PlainButtonStyle())
                                    
                                    Divider()
                                        .padding(.leading, 16)
                                }
                            }
                        }
                        .background(Color(.systemBackground))
                    }
                }
                .frame(maxWidth: .infinity, maxHeight: .infinity)
            }
            .navigationTitle("Search Address")
            .navigationBarTitleDisplayMode(.inline)
            .navigationBarItems(leading: Button("Cancel") {
                isPresented = false
            })
            .onAppear {
                setupSearchCompleter()
            }
            .onChange(of: searchText) { _ in
                updateSearchResults()
            }
        }
    }
    
    private func setupSearchCompleter() {
        let completer = MKLocalSearchCompleter()
        
        completer.resultTypes = [.address, .pointOfInterest]
        
        searchCompleterDelegate.onResults = { (results: [MKLocalSearchCompletion]) in
            DispatchQueue.main.async {
                self.searchResults = results
                self.isSearching = false
            }
        }
        
        completer.delegate = searchCompleterDelegate
        
        searchCompleter = completer
    }
    
    private func updateSearchResults() {
        if searchText.count > 2 {
            isSearching = true
            searchCompleter?.queryFragment = searchText
        } else {
            searchResults = []
            isSearching = false
        }
    }
    
    private func selectSearchResult(_ result: MKLocalSearchCompletion) {
        isSearching = true
        
        
        let searchRequest = MKLocalSearch.Request()
        searchRequest.naturalLanguageQuery = result.title + ", " + result.subtitle
        
        let search = MKLocalSearch(request: searchRequest)
        search.start { response, error in
            DispatchQueue.main.async {
                self.isSearching = false
                
                guard error == nil, let mapItem = response?.mapItems.first else {
                    print("Search failed or no results")
                    return
                }
                
                let placemark = mapItem.placemark
                let selectedCoordinate = placemark.coordinate
                
                var updatedAddress = self.address
                
                updatedAddress.street = placemark.thoroughfare ?? ""
                
                var houseNumber = ""
                
                if let subThoroughfare = placemark.subThoroughfare, !subThoroughfare.isEmpty {
                    houseNumber = subThoroughfare
                }
                
                updatedAddress.houseNumber = houseNumber
                
                updatedAddress.city = placemark.locality ?? ""
                updatedAddress.postalCode = placemark.postalCode ?? ""
                updatedAddress.country = placemark.country ?? ""
                updatedAddress.coordinates = Coordinates(
                    latitude: selectedCoordinate.latitude,
                    longitude: selectedCoordinate.longitude
                )
                
                self.address = updatedAddress
                self.onAddressSelected?(updatedAddress)
                
                self.isPresented = false
            }
        }
    }
}
