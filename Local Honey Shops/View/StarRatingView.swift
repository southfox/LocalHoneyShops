// StarRatingView.swift
// Local Honey Shops
// Created by Javier Fuchs on 18/09/2025.

import SwiftUI

struct StarRatingView: View {
    let rating: Double
    let max: Int
    var body: some View {
        HStack(spacing: 2) {
            ForEach(0..<max, id: \.self) { index in
                Image(systemName: index < Int(rating.rounded()) ? "star.fill" : "star")
                    .foregroundColor(.yellow)
                    .font(.body)
            }
        }
    }
}

#Preview {
    StarRatingView(rating: 0, max: 5)
    StarRatingView(rating: 4.2, max: 5)
}
