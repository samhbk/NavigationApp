//
//  ViewController.swift
//  mapp
//
//  Created by samh on 03/12/2024.
//

import UIKit
import GoogleMaps
import GooglePlaces
import CoreLocation

class MapViewController: UIViewController, GMSMapViewDelegate, GMSAutocompleteViewControllerDelegate {
    
    var mapView: GMSMapView!
    var addressInputView: AddressInputView!
    
    // This property will store which field is being edited
    var currentFieldType: FieldType?
    
    enum FieldType {
        case start
        case end
    }
    
    var startCoordinate: CLLocationCoordinate2D?
    var endCoordinate: CLLocationCoordinate2D?
    
    private let viewModel = MapViewModel()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Setup MapView
        setupMapView()
        
        // Setup AddressInputView programmatically
        setupAddressInputView()
        
        // Set up the map view
        mapView.delegate = self
        mapView.isMyLocationEnabled = true
        
        setupActions()
        
        // Setup Autocomplete delegate
        setupAutocomplete()
    }
    
    private func setupMapView() {
        
        // Create GMSMapViewOptions and customize it
        let mapOptions = GMSMapViewOptions()
        
        // Create GMSMapView with the options
        mapView = GMSMapView.init(options: mapOptions)
        
        mapView.delegate = self
        mapView.isMyLocationEnabled = true
        view.addSubview(mapView)
        
        // Constraints for map view
        mapView.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            mapView.topAnchor.constraint(equalTo: view.topAnchor),
            mapView.leftAnchor.constraint(equalTo: view.leftAnchor),
            mapView.rightAnchor.constraint(equalTo: view.rightAnchor),
            mapView.bottomAnchor.constraint(equalTo: view.bottomAnchor)
        ])
    }
    
    private func setupAddressInputView() {
        addressInputView = AddressInputView()
        view.addSubview(addressInputView)
        
        // Constraints for AddressInputView
        addressInputView.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            addressInputView.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 16),
            addressInputView.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -16),
            addressInputView.bottomAnchor.constraint(equalTo: view.bottomAnchor, constant: -50),
        ])
    }
    
    // Set up Autocomplete for Address Fields
    private func setupAutocomplete() {
        addressInputView.startAddressField.addTarget(self, action: #selector(startAddressFieldDidChange), for: .touchDown)
        addressInputView.endAddressField.addTarget(self, action: #selector(endAddressFieldDidChange), for: .touchDown)
    }
    
    private func setupActions() {
        addressInputView.routeButton.addTarget(self, action: #selector(showRoute), for: .touchUpInside)
    }
    
    @objc private func showRoute() {
        guard
            let startAddress = addressInputView.startAddressField.text, !startAddress.isEmpty,
            let endAddress = addressInputView.endAddressField.text, !endAddress.isEmpty
        else {
            showAlert("Please enter both addresses.")
            return
        }
        
        // Use Google Maps API to fetch the route
        print("Start Address: \(startAddress)")
        print("End Address: \(endAddress)")
        
        // Call a method to fetch and display the route on the map
        fetchRoute(startAddress: startAddress, endAddress: endAddress)
    }
    
    private func showAlert(_ message: String) {
        let alert = UIAlertController(title: "Error", message: message, preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "OK", style: .default))
        present(alert, animated: true)
    }
    
    func fetchRouteView(start: CLLocationCoordinate2D, end: CLLocationCoordinate2D) {
        viewModel.fetchRoute(start: start, end: end) { [self] route in
            self.drawRoute(route: route!)
        }
    }
    
    // MARK: - Autocomplete
    
    // Show autocomplete for start address
    @objc func startAddressFieldDidChange() {
        openAutocomplete(for: .start)
    }
    
    // Show autocomplete for end address
    @objc func endAddressFieldDidChange() {
        openAutocomplete(for: .end)
    }
    
    // Open the Autocomplete View Controller
    private func openAutocomplete(for fieldType: FieldType) {
        let autocompleteController = GMSAutocompleteViewController()
        autocompleteController.delegate = self
        
        // Set a filter to limit suggestions (optional)
        let filter = GMSAutocompleteFilter()
        autocompleteController.autocompleteFilter = filter
        
        // Present the autocomplete controller
        present(autocompleteController, animated: true, completion: nil)
        
        // Set field type for callback handling
        currentFieldType = fieldType
    }
    
    // MARK: - GMSAutocompleteViewControllerDelegate
    
    // Called when an address is selected from the autocomplete suggestions
    func viewController(_ viewController: GMSAutocompleteViewController, didAutocompleteWith place: GMSPlace) {
        // Get the selected place's coordinates
        let coordinate = place.coordinate
        
        // Set the appropriate coordinate (start or end)
        if currentFieldType == .start {
            startCoordinate = coordinate
            addressInputView.startAddressField.text = place.formattedAddress
        } else {
            endCoordinate = coordinate
            addressInputView.endAddressField.text = place.formattedAddress
        }
        
        // Dismiss the autocomplete view controller
        dismiss(animated: true, completion: nil)
    }
    
    // Called when autocomplete fails (no suggestions or error)
    func viewController(_ viewController: GMSAutocompleteViewController, didFailAutocompleteWithError error: Error) {
        print("Autocomplete error: \(error.localizedDescription)")
        dismiss(animated: true, completion: nil)
    }
    
    // Called when the user cancels autocomplete
    func wasCancelled(_ viewController: GMSAutocompleteViewController) {
        dismiss(animated: true, completion: nil)
    }
}

extension MapViewController {
    
    func fetchRoute(startAddress: String, endAddress: String) {
        // Geocode start and end addresses
        viewModel.geocodeUsingGoogle(address: startAddress) { startCoordinate in
            guard let startCoordinate = startCoordinate else {
                self.showAlert("Unable to find the start address.")
                return
            }
            self.viewModel.geocodeUsingGoogle(address: endAddress) { endCoordinate in
                guard let endCoordinate = endCoordinate else {
                    self.showAlert("Unable to find the destination address.")
                    return
                }
                // Fetch the route using the NetworkManager
                self.fetchRouteView(start: startCoordinate, end: endCoordinate)
            }
        }
    }
    
    func geocssode(address: String, completion: @escaping (CLLocationCoordinate2D?) -> Void) {
        let sanitizedAddress = address.addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed) ?? address
        
        let geocoder = CLGeocoder()
        geocoder.geocodeAddressString(sanitizedAddress) { placemarks, error in
            if let error = error {
                print("Geocoding error: \(error.localizedDescription)")
                completion(nil)
                return
            }
            
            if let placemark = placemarks?.first, let location = placemark.location {
                completion(location.coordinate)
            } else {
                completion(nil)
            }
        }
    }
    
    
    private func fetchRoute(from start: CLLocationCoordinate2D, to end: CLLocationCoordinate2D) {
        NetworkManager.shared.fetchRoute(from: start, to: end) { result in
            switch result {
            case .success(let route):
                // Handle the route data (e.g., draw the polyline on the map)
                self.drawRoute(route: route)
            case .failure(let error):
                self.showAlert("Failed to fetch route: \(error.localizedDescription)")
            }
        }
    }
    
    private func drawRoute(route: Route) {
        guard let firstRoute = route.routes.first, let firstLeg = firstRoute.legs.first else {
            print("No route available")
            return
        }
        
        
        var bounds = GMSCoordinateBounds()
        
        // Add polylines for each step in the route
        for step in firstLeg.steps {
            if let polyline = step.polyline {
                let encodedPath = polyline.points
                if let path = GMSPath(fromEncodedPath: encodedPath) {
                    DispatchQueue.main.async {
                        // Add polyline to the map
                        let polyline = GMSPolyline(path: path)
                        polyline.strokeWidth = 4
                        polyline.strokeColor = .blue
                        polyline.map = self.mapView
                        
                        // Update the bounds with the polyline's coordinates
                        bounds = bounds.includingPath(path)
                    }
                }
            }
        }
        
//        // Geocode and add markers for the start and end locations
//        geocode(address: firstLeg.start_address) { [weak self] coordinate in
//            guard let self = self, let coordinate = coordinate else { return }
//            DispatchQueue.main.async {
//                let startMarker = GMSMarker(position: coordinate)
//                startMarker.title = "Start"
//                startMarker.icon = GMSMarker.markerImage(with: .green)
//                startMarker.map = self.mapView
//                bounds = bounds.includingCoordinate(coordinate)
//            }
//        }
//        
//        geocode(address: firstLeg.end_address) { [weak self] coordinate in
//            guard let self = self, let coordinate = coordinate else { return }
//            DispatchQueue.main.async {
//                let endMarker = GMSMarker(position: coordinate)
//                endMarker.title = "End"
//                endMarker.icon = GMSMarker.markerImage(with: .red)
//                endMarker.map = self.mapView
//                bounds = bounds.includingCoordinate(coordinate)
//                
//                // Adjust camera after adding both markers
//                let cameraUpdate = GMSCameraUpdate.fit(bounds, withPadding: 50.0)
//                self.mapView.animate(with: cameraUpdate)
//            }
//        }
        
        // Move the camera to fit the bounds of the polyline with some padding
        DispatchQueue.main.async {
            let cameraUpdate = GMSCameraUpdate.fit(bounds, withPadding: 50.0) // Adjust padding as needed
            self.mapView.animate(with: cameraUpdate)
        }
    }
    
    func geocode(address: String, completion: @escaping (CLLocationCoordinate2D?) -> Void) {
        let geocoder = CLGeocoder()
        geocoder.geocodeAddressString(address) { placemarks, error in
            if let error = error {
                print("Geocoding error: \(error.localizedDescription)")
                completion(nil)
                return
            }
            
            if let location = placemarks?.first?.location {
                completion(location.coordinate)
            } else {
                completion(nil)
            }
        }
    }
    
}

