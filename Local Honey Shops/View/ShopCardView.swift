// ShopCardView.swift
// Local Honey Shops
// Created by Javier Fuchs on 18/09/2025.

import SwiftUI

struct ShopCardView: View {
    let shop: Item
    let searchText: String?

    init(shop: Item, searchText: String? = nil) {
        self.shop = shop
        self.searchText = searchText
    }

    var body: some View {
        HStack {
            VStack(alignment: .leading) {
                // Name: default color when no search, highlight matches when searching
                highlightedText(shop.name, search: searchText, nonMatchStyle: nil)
                    .font(.headline)
                
                // Address: secondary for non-matching parts; highlight matches when searching
                highlightedText(shop.address, search: searchText, nonMatchStyle: .secondary)
                    .font(.subheadline)
            }
            Spacer()
            StarRatingView(rating: shop.rating, max: 5)
        }
    }
    
    /// Builds a Text where matching substring is highlighted with color,
    /// and non-matching parts can use a given style (e.g., .secondary).
    func highlightedText(
        _ string: String,
        search: String?,
        nonMatchStyle: (any ShapeStyle)?,
        highlightColor: Color = .red
    ) -> Text {
        guard let search, !search.isEmpty else {
            var base = Text(string)
            if let nonMatchStyle {
                base = base.foregroundStyle(nonMatchStyle)
            }
            return base
        }
        
        let lcString = string.lowercased()
        let lcSearch = search.lowercased()
        guard let range = lcString.range(of: lcSearch) else {
            var base = Text(string)
            if let nonMatchStyle {
                base = base.foregroundStyle(nonMatchStyle)
            }
            return base
        }
        
        let start = String(string[..<range.lowerBound])
        let match = String(string[range])
        let end = String(string[range.upperBound...])
        
        let startText = nonMatchStyle.map { Text(start).foregroundStyle($0) } ?? Text(start)
        let endText = nonMatchStyle.map { Text(end).foregroundStyle($0) } ?? Text(end)
        let matchText = Text(match).bold().foregroundStyle(highlightColor)
        
        // Use Text interpolation instead of '+' concatenation (deprecated)
        return Text("\(startText)\(matchText)\(endText)")
    }
}

#Preview {
    ShopCardView(shop: .default)
    ShopCardView(shop: .default, searchText: "New")
}
