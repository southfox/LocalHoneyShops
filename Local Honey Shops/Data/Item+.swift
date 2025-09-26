// Item+.swift
// Local Honey Shops
// Created by Javier Fuchs on 18/09/2025.

import Foundation
import CoreLocation

extension Item {
    var coordinate2D: CLLocationCoordinate2D? {
        guard coordinates.count >= 2 else { return nil }
        let lat = coordinates[0]
        let lon = coordinates[1]
        guard (-90.0...90.0).contains(lat), (-180.0...180.0).contains(lon) else { return nil }
        return CLLocationCoordinate2D(latitude: lat, longitude: lon)
    }
}
