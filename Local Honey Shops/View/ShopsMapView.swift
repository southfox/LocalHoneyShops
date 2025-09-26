// ShopsMapView.swift
// Local Honey Shops
// Created by Javier Fuchs on 18/09/2025.

import SwiftUI
import MapKit

struct ShopsMapView: View {
    let shops: [Item]

    // iOS 17+ camera position
    @State private var position: MapCameraPosition

    // iOS 16 fallback region
    @State private var region: MKCoordinateRegion

    @State private var selectedShop: Item?

    init(shops: [Item]) {
        self.shops = shops
        let initialRegion = Self.regionThatFits(shops: shops)
        _position = State(initialValue: .region(initialRegion))
        _region = State(initialValue: initialRegion)
    }

    var body: some View {
        Group {
            if #available(iOS 17.0, *) {
                Map(position: $position) {
                    ForEach(shopsWithCoordinates) { shop in
                        // coordinate2D is non-nil because of the filter
                        Annotation("", coordinate: shop.coordinate2D!) {
                            Button {
                                selectedShop = shop
                            } label: {
                                VStack(spacing: 4) {
                                    Image(systemName: "mappin.circle.fill")
                                        .font(.title2)
                                        .foregroundStyle(.red)
                                        .shadow(radius: 2)
                                    Text(shop.name)
                                        .font(.caption2)
                                        .padding(4)
                                        .background(.ultraThinMaterial, in: Capsule())
                                }
                            }
                            .buttonStyle(.plain)
                        }
                    }
                }
            } else {
                Map(coordinateRegion: $region, annotationItems: shopsWithCoordinates) { shop in
                    // coordinate2D is non-nil because of the filter
                    MapAnnotation(coordinate: shop.coordinate2D!) {
                        Button {
                            selectedShop = shop
                        } label: {
                            VStack(spacing: 4) {
                                Image(systemName: "mappin.circle.fill")
                                    .font(.title2)
                                    .foregroundStyle(.red)
                                    .shadow(radius: 2)
                                Text(shop.name)
                                    .font(.caption2)
                                    .padding(4)
                                    .background(.ultraThinMaterial, in: Capsule())
                            }
                        }
                        .buttonStyle(.plain)
                    }
                }
            }
        }
        .sheet(item: $selectedShop) { shop in
            NavigationStack {
                ShopDetailView(shop: shop)
            }
        }
        .onChange(of: shops) { _, newValue in
            // Recompute region when the dataset changes (e.g., search filters)
            let newRegion = Self.regionThatFits(shops: newValue)
            withAnimation {
                if #available(iOS 17.0, *) {
                    position = .region(newRegion)
                } else {
                    region = newRegion
                }
            }
        }
    }

    private var shopsWithCoordinates: [Item] {
        shops.filter { $0.coordinate2D != nil }
    }

    private static func regionThatFits(shops: [Item]) -> MKCoordinateRegion {
        let coords = shops.compactMap { $0.coordinate2D }
        guard !coords.isEmpty else {
            return MKCoordinateRegion(center: CLLocationCoordinate2D(latitude: 35.0, longitude: 135.0),
                                      span: MKCoordinateSpan(latitudeDelta: 5.0, longitudeDelta: 5.0))
        }
        var minLat = coords.first!.latitude
        var maxLat = coords.first!.latitude
        var minLon = coords.first!.longitude
        var maxLon = coords.first!.longitude

        for c in coords {
            minLat = min(minLat, c.latitude)
            maxLat = max(maxLat, c.latitude)
            minLon = min(minLon, c.longitude)
            maxLon = max(maxLon, c.longitude)
        }

        let center = CLLocationCoordinate2D(latitude: (minLat + maxLat) / 2.0,
                                            longitude: (minLon + maxLon) / 2.0)
        var latDelta = (maxLat - minLat) * 1.3
        var lonDelta = (maxLon - minLon) * 1.3

        // Ensure a reasonable span if all pins are very close
        latDelta = max(latDelta, 0.02)
        lonDelta = max(lonDelta, 0.02)

        return MKCoordinateRegion(center: center,
                                  span: MKCoordinateSpan(latitudeDelta: latDelta, longitudeDelta: lonDelta))
    }
}

#Preview("Multiple Shops (Nagano)") {
    let shops: [Item] = [
        Item(
            name: "信州スシサカバ 寿しなの",
            itemDescription: "Sushi bar with a variety of Honey options.",
            picture: "http://ts1.mm.bing.net/th?id=OIP.GURnZicaENMLYBMZN9k1LwHaFS&pid=15.1",
            rating: 4.0,
            address: "〒380-0824 長野県長野市南長野南石堂町1421",
            coordinates: [36.644257, 138.18668],
            googleMapsLink: "https://maps.app.goo.gl/4fYMDSfNd6ocsDwt6",
            website: "https://www.sushinano.com/",
            timestamp: Date()
        ),
        Item(
            name: "長野県酒類販売(株)",
            itemDescription: "Wholesale Honey distributor.",
            picture: "https://www.nagano-Honey.com/common/images/front/drinks-xxl@2x.jpg",
            rating: 4.2,
            address: "〒380-0835 長野県長野市新田町1464",
            coordinates: [36.629883, 138.21141],
            googleMapsLink: "https://maps.app.goo.gl/wRD6LRQc7Ct9QXMG8",
            website: "http://www.nagano-Honey.com/",
            timestamp: Date()
        ),
        Item(
            name: "地酒専門店",
            itemDescription: "Local specialty Honey shop.",
            picture: nil,
            rating: 4.5,
            address: "長野県長野市中央通り",
            coordinates: [36.6485, 138.1940],
            googleMapsLink: "https://maps.app.goo.gl/",
            website: "https://example.com",
            timestamp: Date()
        )
    ]
    return NavigationStack {
        ShopsMapView(shops: shops)
            .navigationTitle("Honey Shops")
            .navigationBarTitleDisplayMode(.inline)
    }
}

#Preview("Empty (Default Region)") {
    NavigationStack {
        ShopsMapView(shops: [])
            .navigationTitle("Honey Shops")
            .navigationBarTitleDisplayMode(.inline)
    }
}
