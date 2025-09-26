// HoneyShopServiceTests.swift
// Unit tests for HoneyShopService and JSON parsing
// Created by Javier Fuchs on 18/09/2025.

import Testing
@testable import Local_Honey_Shops

@Suite("HoneyShopService JSON Decoding")
struct HoneyShopServiceTests {
    let sampleJSON = """
    [
        {
          "name": "The House of Honey",
          "description": "Sanctuary for local bees, café y tienda con degustación de miel en Swan Valley, Australia",
          "picture": "https://thehouseofhoney.com.au/wp-content/uploads/2024/01/shopfront.jpg",
          "rating": 4.8,
          "address": "Mariani Ave, Henley Brook WA 6055, Australia",
          "coordinates": {
            "lat": -31.8552,
            "lng": 116.0019
          },
          "google_maps_link": "https://www.google.com/maps/place/The+House+of+Honey+WA",
          "website": "https://thehouseofhoney.com.au"
        },
        {
          "name": "Montana Honey Bee Company",
          "description": "Tienda local especializada en miel sin procesar, venta de equipo apícola y degustaciones en Bozeman",
          "picture": "https://montanahoneybeecompany.com/images/storefront.jpg",
          "rating": 4.7,
          "address": "19 S Tracy Ave, Bozeman, MT 59715, USA",
          "coordinates": {
            "lat": 45.6740,
            "lng": -111.0429
          },
          "google_maps_link": "https://www.google.com/maps/place/Montana+Honey+Bee+Company",
          "website": "https://montanahoneybeecompany.com"
        }
    ]
    """
    
    @Test("Mock service decodes JSON correctly")
    func testMockFetch() async throws {
        let mock = HoneyShopServiceMock(json: sampleJSON)
        let items = try await mock.fetch()
        #expect(items.count == 2)
        #expect(items[0].name == "The House of Honey")
        #expect(items[1].rating == 4.7)
        #expect(items[0].address.contains("Mariani"))
    }
    
    @Test("Handles empty JSON array")
    func testEmptyArray() async throws {
        let mock = HoneyShopServiceMock(json: "[]")
        let items = try await mock.fetch()
        #expect(items.isEmpty)
    }
    
    @Test("Invalid JSON throws error")
    func testInvalidJSONThrows() async throws {
        let mock = HoneyShopServiceMock(json: "invalid json")
        do {
            _ = try await mock.fetch()
            #expect(Bool(false), "Should throw on invalid JSON")
        } catch {
            #expect(true)
        }
    }
}

