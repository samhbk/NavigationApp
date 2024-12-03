//
//  MapViewModel.swift
//  MyMapsApp
//
//  Created by samh on 03/12/2024.
//

import Foundation
import CoreLocation

class MapViewModel {
    private var route: Route?
    
    func fetchRoute(start: CLLocationCoordinate2D, end: CLLocationCoordinate2D, completion: @escaping (Route?) -> Void) {
        NetworkManager.shared.fetchRoute(from: start, to: end) { result in
            switch result {
            case .success(let route):
                self.route = route
                completion(route)
            case .failure:
                completion(nil)
            }
        }
    }
    
    func geocodeUsingGoogle(address: String, completion: @escaping (CLLocationCoordinate2D?) -> Void) {
        NetworkManager.shared.geocode(address: address) { result in
            switch result {
            case .success(let route):
                completion(route)
            case .failure:
                completion(nil)
            }
        }
    }
    
}
