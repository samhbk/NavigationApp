//
//  Route.swift
//  MyMapsApp
//
//  Created by samh on 03/12/2024.
//

import Foundation
import CoreLocation

// Define the Route model to match the JSON response structure
struct Route: Codable {
    let routes: [GoogleRoute]
}

struct GoogleRoute: Codable {
    let legs: [Leg]
}

struct Leg: Codable {
    let start_address: String
    let end_address: String
//    let startLocation: Location?
//    let endLocation: Location?
    let steps: [Step]
}

struct Location: Codable {
    let lat: Double
    let lng: Double
}

struct Step: Codable {
    let distance: Distance
    let duration: Duration
    let polyline: Polyline?
}

struct Distance: Codable {
    let text: String
    let value: Int
}

struct Duration: Codable {
    let text: String
    let value: Int
}

struct Polyline: Codable {
    let points: String
}
