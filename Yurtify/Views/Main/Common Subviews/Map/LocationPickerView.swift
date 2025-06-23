//
//  LocationPickerView.swift
//  Yurtify
//
//  Created by dark type on 23.06.2025.
//

import MapKit
import SwiftUI

struct LocationPickerView: View {
    // MARK: - Properties

    @Binding var address: Address
    @State private var region: MKCoordinateRegion
    @State private var isPresentingSearch = false
    @State private var isAddressSearchInProgress = false
    @StateObject private var locationManager = LocationManager()
    @State private var annotations = [MapAnnotation]()
    
    init(address: Binding<Address>) {
        self._address = address
        
        if address.wrappedValue.coordinates.latitude != 0 && address.wrappedValue.coordinates.longitude != 0 {
            _region = State(initialValue: MKCoordinateRegion(
                center: address.wrappedValue.coordinates.clLocation,
                span: MKCoordinateSpan(latitudeDelta: 0.01, longitudeDelta: 0.01)
            ))
        } else {
            _region = State(initialValue: MKCoordinateRegion(
                center: CLLocationCoordinate2D(latitude: 42.8746, longitude: 74.5698),
                span: MKCoordinateSpan(latitudeDelta: 0.05, longitudeDelta: 0.05)
            ))
        }
    }
    
    // MARK: - Body

    var body: some View {
        VStack(spacing: 16) {
            MapContainerView(
                region: $region,
                annotations: annotations,
                onTapLocation: { coordinate in
                    updateLocation(coordinate)
                }
            )
            .frame(height: 220)
            .cornerRadius(16)
            .overlay(
                VStack {
                    Spacer()
                    HStack {
                        Spacer()
                        Button(action: {
                            Task {
                                await requestUserLocation()
                            }
                        }) {
                            Image(systemName: "location")
                                .padding(12)
                                .tint(.primaryVariant)
                                .background(Color.white)
                                .clipShape(Circle())
                                .shadow(radius: 2)
                        }
                        .padding(16)
                    }
                }
            )
            
            Button(action: {
                isPresentingSearch = true
            }) {
                HStack {
                    Image.appIcon(.search)
                    Text("Search for address").foregroundStyle(Color.app.textSecondary)
                    Spacer()
                }
                .padding()
                .background(Color(.accentLight))
                .cornerRadius(12)
                .overlay(
                    RoundedRectangle(cornerRadius: 12)
                        .stroke(Color.gray.opacity(0.3), lineWidth: 1)
                )
            }
            .sheet(isPresented: $isPresentingSearch) {
                AddressSearchView(
                    address: $address,
                    isPresented: $isPresentingSearch,
                    onAddressSelected: { newAddress in
                        if newAddress.coordinates.latitude != 0 {
                            updateLocationUI(newAddress.coordinates.clLocation)
                        }
                    }
                )
            }
            
            if !address.formattedAddress.isEmpty {
                VStack(alignment: .leading, spacing: 8) {
                    Text("Selected Address")
                        .font(.app.latoRegular(size: 14))
                        .foregroundColor(.textFade)
                    
                    VStack(alignment: .leading, spacing: 4) {
                        Text(address.formattedAddress)
                            .font(.app.latoBold(size: 16))
                            .foregroundColor(.textPrimary)
                            .multilineTextAlignment(.leading)
                        
                        if !address.street.isEmpty {
                            HStack {
                                Text("Street:")
                                    .font(.app.latoRegular(size: 14))
                                    .foregroundColor(.textFade)
                                
                                Text("\(address.street) \(address.houseNumber)")
                                    .font(.app.latoRegular(size: 14))
                                    .foregroundColor(.textPrimary)
                            }
                        }
                        
                        if !address.city.isEmpty {
                            HStack {
                                Text("City:")
                                    .font(.app.latoRegular(size: 14))
                                    .foregroundColor(.textFade)
                                
                                Text(address.city)
                                    .font(.app.latoRegular(size: 14))
                                    .foregroundColor(.textPrimary)
                            }
                        }
                        
                        if !address.postalCode.isEmpty {
                            HStack {
                                Text("Postal Code:")
                                    .font(.app.latoRegular(size: 14))
                                    .foregroundColor(.textFade)
                                
                                Text(address.postalCode)
                                    .font(.app.latoRegular(size: 14))
                                    .foregroundColor(.textPrimary)
                            }
                        }
                    }
                }
                .frame(maxWidth: .infinity, alignment: .leading)
                .padding()
                .background(Color(.accentLight))
                .cornerRadius(12)
            }
        }
        .onAppear {
            if address.coordinates.latitude != 0 {
                annotations = [
                    MapAnnotation(
                        coordinate: address.coordinates.clLocation,
                        title: "Selected Location"
                    )
                ]
            }
        }
    }
    
    // MARK: - Methods

    private func updateLocation(_ coordinate: CLLocationCoordinate2D) {
        address.coordinates = Coordinates(
            latitude: coordinate.latitude,
            longitude: coordinate.longitude
        )
        
        updateLocationUI(coordinate)
        
        reverseGeocodeLocation(coordinate)
    }
    
    private func updateLocationUI(_ coordinate: CLLocationCoordinate2D) {
        withAnimation {
            region = MKCoordinateRegion(
                center: coordinate,
                span: MKCoordinateSpan(latitudeDelta: 0.01, longitudeDelta: 0.01)
            )
            
            annotations = [
                MapAnnotation(
                    coordinate: coordinate,
                    title: "Selected Location"
                )
            ]
        }
    }
    
    private func reverseGeocodeLocation(_ location: CLLocationCoordinate2D) {
        isAddressSearchInProgress = true
        
        let geocoder = CLGeocoder()
        let clLocation = CLLocation(latitude: location.latitude, longitude: location.longitude)
        
        geocoder.reverseGeocodeLocation(clLocation) { placemarks, error in
            DispatchQueue.main.async {
                self.isAddressSearchInProgress = false
                
                guard error == nil else {
                    print("Reverse geocoding error: \(error!.localizedDescription)")
                    return
                }
                
                guard let placemark = placemarks?.first else {
                    print("No placemark found")
                    return
                }
                
                self.address.street = placemark.thoroughfare ?? ""
                
                let houseNumber = placemark.subThoroughfare ?? ""
                self.address.houseNumber = houseNumber
                
                if houseNumber.isEmpty, let name = placemark.name {
                    let components = name.components(separatedBy: " ")
                    for component in components {
                        if component.rangeOfCharacter(from: .decimalDigits) != nil {
                            self.address.houseNumber = component
                            break
                        }
                    }
                }
                
                self.address.city = placemark.locality ?? ""
                self.address.postalCode = placemark.postalCode ?? ""
                self.address.country = placemark.country ?? ""
                
                print("Updated address: \(self.address.street) \(self.address.houseNumber), \(self.address.city)")
            }
        }
    }
    
    private func requestUserLocation() async {
        let authStatus = await locationManager.requestLocationPermission()
        
        if authStatus == .authorizedWhenInUse || authStatus == .authorizedAlways {
            if let userLocation = locationManager.currentLocation {
                await MainActor.run {
                    updateLocation(userLocation.coordinate)
                }
            } else {
                try? await Task.sleep(for: .seconds(1))
                
                await MainActor.run {
                    if let userLocation = locationManager.currentLocation {
                        updateLocation(userLocation.coordinate)
                    } else {
                        print("Could not get user location")
                    }
                }
            }
        }
    }
}

// MARK: - Map Annotation Model

struct MapAnnotation: Identifiable {
    let id = UUID()
    let coordinate: CLLocationCoordinate2D
    let title: String
}

// MARK: - Map Container

struct MapContainerView: UIViewRepresentable {
    @Binding var region: MKCoordinateRegion
    var annotations: [MapAnnotation]
    var onTapLocation: (CLLocationCoordinate2D) -> Void
    
    func makeUIView(context: Context) -> MKMapView {
        let mapView = MKMapView()
        mapView.delegate = context.coordinator
        mapView.showsUserLocation = true
        
        let tapGesture = UITapGestureRecognizer(target: context.coordinator, action: #selector(Coordinator.mapTapped(_:)))
        mapView.addGestureRecognizer(tapGesture)
        
        return mapView
    }
    
    func updateUIView(_ mapView: MKMapView, context: Context) {
        mapView.setRegion(region, animated: true)
        
        let existingAnnotations = mapView.annotations.filter { !($0 is MKUserLocation) }
        mapView.removeAnnotations(existingAnnotations)
        
        let mapAnnotations = annotations.map { annotation -> MKPointAnnotation in
            let point = MKPointAnnotation()
            point.coordinate = annotation.coordinate
            point.title = annotation.title
            return point
        }
        mapView.addAnnotations(mapAnnotations)
    }
    
    func makeCoordinator() -> Coordinator {
        Coordinator(self)
    }
    
    class Coordinator: NSObject, MKMapViewDelegate {
        var parent: MapContainerView
        
        init(_ parent: MapContainerView) {
            self.parent = parent
        }
        
        @objc func mapTapped(_ gesture: UITapGestureRecognizer) {
            guard let mapView = gesture.view as? MKMapView else { return }
            
            let point = gesture.location(in: mapView)
            let coordinate = mapView.convert(point, toCoordinateFrom: mapView)
            
            parent.onTapLocation(coordinate)
        }
        
        func mapView(_ mapView: MKMapView, viewFor annotation: MKAnnotation) -> MKAnnotationView? {
            if annotation is MKUserLocation {
                return nil
            }
            
            let identifier = "LocationPin"
            var annotationView = mapView.dequeueReusableAnnotationView(withIdentifier: identifier) as? MKMarkerAnnotationView
            
            if annotationView == nil {
                annotationView = MKMarkerAnnotationView(annotation: annotation, reuseIdentifier: identifier)
                annotationView?.canShowCallout = true
                annotationView?.markerTintColor = UIColor(.primaryVariant)
                annotationView?.glyphImage = UIImage(systemName: "mappin")
            } else {
                annotationView?.annotation = annotation
            }
            
            return annotationView
        }
        
        func mapView(_ mapView: MKMapView, regionDidChangeAnimated animated: Bool) {
            DispatchQueue.main.async {
                let currentRegion = self.parent.region
                let newRegion = mapView.region
                
                let centerChanged = currentRegion.center.latitude != newRegion.center.latitude ||
                    currentRegion.center.longitude != newRegion.center.longitude
                let spanChanged = currentRegion.span.latitudeDelta != newRegion.span.latitudeDelta ||
                    currentRegion.span.longitudeDelta != newRegion.span.longitudeDelta
                
                if centerChanged || spanChanged {
                    self.parent.region = newRegion
                }
            }
        }
    }
}
