// ShopDetailView.swift
// Local Honey Shops
// Created by Javier Fuchs on 18/09/2025.
import SwiftUI

struct ShopDetailView: View {
    let shop: Item
    @Environment(\.openURL) private var openURL

    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 16) {
                if let picture = shop.picture, let url = URL(string: picture) {
                    AsyncImage(url: url) { image in
                        image.resizable().aspectRatio(contentMode: .fill)
                    } placeholder: {
                        Color.gray.opacity(0.2)
                    }
                    .frame(height: 180)
                    .clipShape(RoundedRectangle(cornerRadius: 12))
                }
                Text(shop.name).font(.title.bold())
                Text(shop.itemDescription)
                StarRatingView(rating: shop.rating, max: 5)

                // Embedded mini map preview (reused ShopsMapView)
                if shop.coordinate2D != nil {
                    ShopsMapView(shops: [shop])
                        .frame(height: 160)
                        .clipShape(RoundedRectangle(cornerRadius: 12))
                        // Disable interactions inside the map to avoid presenting another detail
                        .allowsHitTesting(false)
                        // Visual button overlay in bottom-right (kept as-is)
                        .overlay(alignment: .bottomTrailing) {
                            if let mapsURL = URL(string: shop.googleMapsLink) {
                                Link(destination: mapsURL) {
                                    Label("Open Maps", systemImage: "map")
                                        .font(.caption.bold())
                                        .padding(8)
                                        .background(.ultraThinMaterial, in: Capsule())
                                }
                                .padding(8)
                            }
                        }
                        // Full-surface invisible tap target to open Maps when tapping anywhere
                        .overlay {
                            if let mapsURL = URL(string: shop.googleMapsLink) {
                                Color.clear
                                    .contentShape(Rectangle())
                                    .onTapGesture {
                                        openURL(mapsURL)
                                    }
                                    .accessibilityLabel("Open in Maps")
                                    .accessibilityAddTraits(.isButton)
                            }
                        }
                }

                // Address with clickable link to Maps
                if let mapsURL = URL(string: shop.googleMapsLink) {
                    Link(shop.address, destination: mapsURL)
                        .font(.subheadline)
                        .foregroundStyle(.blue)
                } else {
                    Text(shop.address)
                        .font(.subheadline)
                        .foregroundStyle(.secondary)
                }
                // Website link
                if let websiteURL = URL(string: shop.website) {
                    Link("Visit Website", destination: websiteURL)
                        .font(.headline)
                        .foregroundStyle(.blue)
                }
            }
            .padding()
            .navigationTitle(shop.name)
            .navigationBarTitleDisplayMode(.inline)
        }
    }
}

#Preview {
    ShopDetailView(shop: .default)
}
