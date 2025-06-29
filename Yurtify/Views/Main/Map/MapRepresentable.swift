//
//  MapRepresentable.swift
//  Yurtify
//
//  Created by dark type on 24.06.2025.
//

import MapKit
import SwiftUI

struct MapRepresentable: UIViewRepresentable {
    @Binding var region: MKCoordinateRegion
    let offers: [UnifiedPropertyModel]
    let selectedOfferId: String?
    let onSelectOffer: (String) -> Void
    
    func makeCoordinator() -> Coordinator {
        Coordinator(
            region: $region,
            onSelectOffer: onSelectOffer
        )
    }
    
    func makeUIView(context: Context) -> MKMapView {
        let mapView = MKMapView()
        mapView.delegate = context.coordinator
        mapView.showsUserLocation = true
        
        mapView.register(
            OfferMarkerView.self,
            forAnnotationViewWithReuseIdentifier: MKMapViewDefaultAnnotationViewReuseIdentifier
        )
        
        mapView.register(
            OfferClusterView.self,
            forAnnotationViewWithReuseIdentifier: MKMapViewDefaultClusterAnnotationViewReuseIdentifier
        )
        
        return mapView
    }
    
    func updateUIView(_ mapView: MKMapView, context: Context) {
        mapView.setRegion(region, animated: false)
        
        let now = Date()
        if now.timeIntervalSince(context.coordinator.lastUpdateTime) < 0.5 {
            return
        }
        context.coordinator.lastUpdateTime = now
        
        let maxAnnotations = 200
        let offersToProcess = offers.count > maxAnnotations ?
            Array(offers.prefix(maxAnnotations)) :
            offers
        
        var processedOfferIds = Set<String>()
        
        for offer in offersToProcess {
            processedOfferIds.insert(offer.id)
            
            if let existingAnnotation = context.coordinator.currentAnnotations[offer.id] {
                let needsUpdate = existingAnnotation.coordinate.latitude != offer.coordinates.latitude ||
                    existingAnnotation.coordinate.longitude != offer.coordinates.longitude ||
                existingAnnotation.price != offer.cost ||
                    existingAnnotation.period != offer.period ||
                    existingAnnotation.isSelected != (selectedOfferId == offer.id)
                
                if needsUpdate {
                    existingAnnotation.coordinate = offer.coordinates.clLocation
                    existingAnnotation.price = offer.cost
                    existingAnnotation.period = offer.period
                    existingAnnotation.isSelected = (selectedOfferId == offer.id)
                    
                    if let view = mapView.view(for: existingAnnotation) as? OfferMarkerView {
                        view.prepareForDisplay()
                    }
                }
            }
            else {
                let annotation = OfferAnnotation(
                    offerId: offer.id,
                    coordinate: offer.coordinates.clLocation,
                    price: offer.cost,
                    period: offer.period,
                    isSelected: selectedOfferId == offer.id
                )
                context.coordinator.currentAnnotations[offer.id] = annotation
                mapView.addAnnotation(annotation)
            }
        }
        
        let annotationsToRemove = context.coordinator.currentAnnotations.keys.filter { !processedOfferIds.contains($0) }
        for offerId in annotationsToRemove {
            if let annotation = context.coordinator.currentAnnotations.removeValue(forKey: offerId) {
                mapView.removeAnnotation(annotation)
            }
        }
        
        for annotation in mapView.annotations {
            if let clusterAnnotation = annotation as? MKClusterAnnotation,
               let view = mapView.view(for: clusterAnnotation) as? OfferClusterView
            {
                view.prepareForDisplay()
            }
        }
    }
    
    class Coordinator: NSObject, MKMapViewDelegate {
        var currentAnnotations = [String: OfferAnnotation]()
        var lastUpdateTime = Date.distantPast
        var isUpdatingSelection = false
        
        var region: Binding<MKCoordinateRegion>
        var onSelectOffer: (String) -> Void
        
        init(region: Binding<MKCoordinateRegion>, onSelectOffer: @escaping (String) -> Void) {
            self.region = region
            self.onSelectOffer = onSelectOffer
            super.init()
        }
        
        func mapView(_ mapView: MKMapView, viewFor annotation: MKAnnotation) -> MKAnnotationView? {
            if annotation is MKUserLocation {
                return nil
            }
            return nil
        }
        
        func mapView(_ mapView: MKMapView, didSelect annotation: MKAnnotation) {
            mapView.deselectAnnotation(annotation, animated: false)
            
            if isUpdatingSelection {
                return
            }
            isUpdatingSelection = true
            
            if let clusterAnnotation = annotation as? MKClusterAnnotation {
                if clusterAnnotation.memberAnnotations.count <= 5 {
                    let region = MKCoordinateRegion(
                        center: clusterAnnotation.coordinate,
                        span: MKCoordinateSpan(
                            latitudeDelta: max(mapView.region.span.latitudeDelta / 5.0, 0.005),
                            longitudeDelta: max(mapView.region.span.longitudeDelta / 5.0, 0.005)
                        )
                    )
                    mapView.setRegion(region, animated: true)
                }
                else if let offerAnnotation = clusterAnnotation.memberAnnotations.first as? OfferAnnotation {
                    DispatchQueue.main.async {
                        self.onSelectOffer(offerAnnotation.offerId)
                        self.isUpdatingSelection = false
                    }
                    return
                }
            }
            else if let offerAnnotation = annotation as? OfferAnnotation {
                DispatchQueue.main.async {
                    self.onSelectOffer(offerAnnotation.offerId)
                    self.isUpdatingSelection = false
                }
                return
            }
            
            isUpdatingSelection = false
        }
        
        func mapView(_ mapView: MKMapView, regionDidChangeAnimated animated: Bool) {
            DispatchQueue.main.async {
                if !self.region.wrappedValue.isApproximatelyEqual(to: mapView.region) {
                    self.region.wrappedValue = mapView.region
                }
            }
        }
    }
}

extension MKCoordinateRegion {
    func isApproximatelyEqual(to other: MKCoordinateRegion, epsilon: Double = 0.0001) -> Bool {
        return abs(center.latitude - other.center.latitude) < epsilon &&
            abs(center.longitude - other.center.longitude) < epsilon &&
            abs(span.latitudeDelta - other.span.latitudeDelta) < epsilon &&
            abs(span.longitudeDelta - other.span.longitudeDelta) < epsilon
    }
}
