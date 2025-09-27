//  Item.swift
//  Local Honey Shops
//  Created by Javier Fuchs on 17/09/2025.

import Foundation
import SwiftData

@Model
final class Item {
    var name: String
    var itemDescription: String
    var picture: String?
    var rating: Double
    var address: String
    var coordinates: [Double]
    var map: String
    var website: String
    var timestamp: Date

    init(
        name: String,
        itemDescription: String,
        picture: String?,
        rating: Double,
        address: String,
        coordinates: [Double],
        map: String,
        website: String,
        timestamp: Date
    ) {
        self.name = name
        self.itemDescription = itemDescription
        self.picture = picture
        self.rating = rating
        self.address = address
        self.coordinates = coordinates
        self.map = map
        self.website = website
        self.timestamp = timestamp
    }

    static let `default` = Item(
        name: "Hani Honey Company",
        itemDescription: "Compañía de miel al por mayor y venta directa, con horario de atención al público en Stuart, Florida",
        picture: "https://hanihoneycompany.com/images/shop.jpg",
        rating: 4.4,
        address: "724 S Colorado Ave, Stuart, FL 34997, USA",
        coordinates: [27.1942, -80.2498],
        map: "https://www.google.com/maps/place/Hani+Honey+Company",
        website: "https://hanihoneycompany.com",
        timestamp: Date()
    )
}

struct JSONResponse: Decodable {
    let record: [Item]
}

extension Item: Codable {
    enum CodingKeys: String, CodingKey {
        case name
        case itemDescription = "description"
        case picture
        case rating
        case address
        case coordinates
        case map
        case website
    }

    convenience init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        self.init(
            name: try container.decode(String.self, forKey: .name),
            itemDescription: try container.decode(String.self, forKey: .itemDescription),
            picture: try container.decodeIfPresent(String.self, forKey: .picture),
            rating: try container.decode(Double.self, forKey: .rating),
            address: try container.decode(String.self, forKey: .address),
            coordinates: try container.decode([Double].self, forKey: .coordinates),
            map: try container.decode(String.self, forKey: .map),
            website: try container.decode(String.self, forKey: .website),
            timestamp: Date()
        )
    }

    func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        try container.encode(name, forKey: .name)
        try container.encode(itemDescription, forKey: .itemDescription)
        try container.encodeIfPresent(picture, forKey: .picture)
        try container.encode(rating, forKey: .rating)
        try container.encode(address, forKey: .address)
        try container.encode(coordinates, forKey: .coordinates)
        try container.encode(map, forKey: .map)
        try container.encode(website, forKey: .website)
    }
}
