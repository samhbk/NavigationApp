//
//  NetworkManager.swift
//  MyMapsApp
//
//  Created by samh on 03/12/2024.
//

import Foundation
import CoreLocation

class NetworkManager {
    static let shared = NetworkManager()
    
    func fetchRoute(from start: CLLocationCoordinate2D, to end: CLLocationCoordinate2D, completion: @escaping (Result<Route, Error>) -> Void) {
        
        guard let apiKey = Bundle.main.object(forInfoDictionaryKey: "GMSApiKey") as? String else { return }
        
        let urlString = "https://maps.googleapis.com/maps/api/directions/json?origin=\(start.latitude),\(start.longitude)&destination=\(end.latitude),\(end.longitude)&mode=driving&key=\(apiKey)"
        guard let url = URL(string: urlString) else { return }
        
        URLSession.shared.dataTask(with: url) { data, _, error in
            if let error = error {
                completion(.failure(error))
                return
            }
            guard let data = data else { return }
            do {
                let route = try JSONDecoder().decode(Route.self, from: data)
                completion(.success(route))
            } catch {
                completion(.failure(error))
            }
        }.resume()
    }
    
    func geocode(address: String, completion: @escaping (Result<CLLocationCoordinate2D?, Error>) -> Void) {
        
        guard let apiKey = Bundle.main.object(forInfoDictionaryKey: "GMSApiKey") as? String else { return }
        
        let urlString = "https://maps.googleapis.com/maps/api/geocode/json?address=\(address.addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed) ?? "")&key=\(apiKey)"
        
        guard let url = URL(string: urlString) else { return }
        
        URLSession.shared.dataTask(with: url) { data, _, error in
            if let error = error {
                completion(.failure(error))
                return
            }
            guard let data = data else { return }
            do {
                if let json = try JSONSerialization.jsonObject(with: data, options: []) as? [String: Any],
                   let results = json["results"] as? [[String: Any]],
                   let firstResult = results.first,
                   let geometry = firstResult["geometry"] as? [String: Any],
                   let location = geometry["location"] as? [String: Double],
                   let lat = location["lat"],
                   let lng = location["lng"] {
                    completion(.success(CLLocationCoordinate2D(latitude: lat, longitude: lng)))
                }
            } catch {
                completion(.failure(error))
            }
        }.resume()
        
    }
    
}
