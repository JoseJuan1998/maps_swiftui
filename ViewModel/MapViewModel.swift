//
//  MapViewModel.swift
//  maps
//
//  Created by jose juan alcantara rincon on 08/11/21.
//

import SwiftUI
import MapKit
import CoreLocation

class MapViewModel: NSObject,ObservableObject,CLLocationManagerDelegate {
    @Published var mapView = MKMapView()
    @Published var region: MKCoordinateRegion!
    @Published var permissionDenied = false
    @Published var mapType: MKMapType = .standard
    @Published var searchTxt = ""
    @Published var places: [Place] = []
    @Published var selectedPlace: [Place] = []
    
    func updateMapType() {
        if mapType == .standard{
            mapType = .hybrid
            mapView.mapType = mapType
        } else {
            mapType = .standard
            mapView.mapType = mapType
        }
    }
    
    func focusLocation() {
        guard let _ = region else{return}
        let overlays = mapView.overlays
        let annotations = mapView.annotations
        mapView.setRegion(region, animated: true)
        mapView.removeOverlays(overlays)
        mapView.removeAnnotations(annotations)
        mapView.setVisibleMapRect(mapView.visibleMapRect, animated: true)
    }
    
    func searchQuery(){
        places.removeAll()
        
        let request = MKLocalSearch.Request()
        request.naturalLanguageQuery = searchTxt
        
        MKLocalSearch(request: request).start { (response, _) in
            guard let result = response else {return}
            self.places = result.mapItems.compactMap({(item) -> Place? in
                return Place(place: item.placemark)
            })
        }
    }
    
    func selectPlace(place: Place) {
        searchTxt = ""
        
        guard let coordinate = place.place.location?.coordinate else {return}
        
        selectedPlace.removeAll()
        selectedPlace.append(place)
        
        let pointAnnotation = MKPointAnnotation()
        pointAnnotation.coordinate = coordinate
        pointAnnotation.title = place.place.name ?? "No name"
        
        mapView.removeAnnotations(mapView.annotations)
        mapView.addAnnotation(pointAnnotation)
        
        let coordinateRegion = MKCoordinateRegion(center: coordinate, latitudinalMeters: 10000, longitudinalMeters: 10000)
        
        mapView.setRegion(coordinateRegion, animated: true)
        mapView.setVisibleMapRect(mapView.visibleMapRect, animated: true)
    }
    
    func makeRoute(){
        let p1 = MKPlacemark(coordinate: region.center)
        guard let p2_coordinate = selectedPlace[0].place.location?.coordinate else {return}
        let p2 = MKPlacemark(coordinate: p2_coordinate)
        
        let request = MKDirections.Request()
        request.source = MKMapItem(placemark: p1)
        request.destination = MKMapItem(placemark: p2)
        request.transportType = .any
        
        let directions = MKDirections(request: request)
        directions.calculate { response, error in
            guard let route = response?.routes.first else {return}
            self.mapView.addAnnotations([p1, p2])
            self.mapView.addOverlay(route.polyline)
            self.mapView.setVisibleMapRect(route.polyline.boundingMapRect, edgePadding: UIEdgeInsets(top: 100, left: 20, bottom: 40, right: 20), animated: true)
        }
    }
    
    func locationManagerDidChangeAuthorization(_ manager: CLLocationManager) {
        switch manager.authorizationStatus {
        case .denied:
            permissionDenied.toggle()
        case .notDetermined:
            manager.requestWhenInUseAuthorization()
        case .authorizedWhenInUse:
            manager.requestLocation()
        default:
            ()
        }
    }
    
    func locationManager(_ manager: CLLocationManager, didFailWithError error: Error) {
        print(error.localizedDescription)
    }
    
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        guard let location = locations.last else {return}
        
        self.region = MKCoordinateRegion(center: location.coordinate, latitudinalMeters: 10000, longitudinalMeters: 10000)
        self.mapView.setRegion(self.region, animated: true)
        self.mapView.setVisibleMapRect(self.mapView.visibleMapRect, animated: true)
    }
    
    
}
