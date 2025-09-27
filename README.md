# Local Honey Shops #

**Created by Javier Fuchs on 17/09/2025**

[![Badges Placeholder]]()

---

## Project Description ##

An iOS SwiftUI app displaying Local Honey Shops, with modular architecture, detail screens, map/web integration, and on-device user reviews with ratings submission stored using SwiftData.

---

## Table of Contents ##

- [Assignment Details](#assignment-details)  
- [Grading Criteria](#grading-criteria)  
- [Getting Started](#getting-started)  
- [Architecture](#architecture)  
- [SwiftData Storage](#swiftdata-storage)  
- [Reviews Feature](#reviews-feature)  
- [Data Model](#data-model)  
- [Screens & Navigation](#screens--navigation)  
- [Testing](#testing)  
- [Future Improvements](#future-improvements)  
- [Sample Honey Shops JSON](#sample-Honey-shops-json)  
- [Sample Reviews JSON](#sample-reviews-json)  

---

## Assignment Details ##

Build a simple app that allows the user to:  
1. View a list of Local Honey Shops (with shop name, address, and star ratings).  
2. Tap an item to navigate to a detail screen containing:  
   - Shop name  
   - Shop picture  
   - Brief description  
   - Star rating  
   - Address (clickable, opens Maps app or browser)  
   - Link/button to visit the shop's website in default browser or custom tab  
3. Submit and view user reviews:  
   - Add a star rating (0.5–5.0 in 0.5 increments)  
   - Optional review title and comment  
   - Local, on-device persistence with immediate UI updates  
   - Average rating computed from user reviews (falls back to seed rating if no reviews)  

The seed shop data will be supplied in JSON format. User-generated reviews are stored locally using SwiftData in a separate table (model) from shops.

---

## Grading Criteria ##

- Solution works as expected.  
- Clean, well-written, and documented code.  
- Functional with all requirements satisfied.  
- Clear, modular architecture and clean code patterns.  
✅ SwiftUI must be used (UIKit submissions will not be accepted).  
✅ Reusable solution design, easily adaptable to different data/APIs.  
✅ Reusable components and views: Common SwiftUI views (e.g., star rating, shop card, address link) and UI building blocks are implemented once and used across multiple screens to ensure consistency and reduce code duplication.  
✅ Good UX/UI and accessibility are a plus—following recognized best practices (such as material design guidelines) for layout, navigation, and inclusive design will improve the app's usability and appearance. Thoughtful user experience, a focus on accessibility, and visually appealing, well-structured interfaces are encouraged, but pixel perfection is not required.  
- Inclusion of unit/UI/snapshot tests is a plus.  
- Other tests and thoughtful design considered.  

---

## Getting Started ##

1. Clone or download the project.  
2. Open the `.xcodeproj` or `.xcworkspace` in Xcode 15+ (SwiftData requires iOS 17+).  
3. Place the provided JSON file (see below) into the project bundle or load it locally for testing.  
4. Build and run the app on a simulator or a real device (iOS 17+).  
5. The app displays a list of Honey shops from the JSON data. Tap on any shop to view details, open maps, or visit the website.  
6. To test reviews, open any shop’s detail screen, tap “Add Review,” fill in the form, and save. Reviews are stored in SwiftData and will appear instantly.

Notes:
- No backend is required; reviews persist locally via SwiftData.  
- If you reinstall the app, local reviews will be cleared unless the device backup restores the app’s data container.

---

## Architecture ##

The app is built using **SwiftUI** with a modular and clean architecture approach.

- Layers
  - Data:
    - Honey shops: JSON decoding from bundled/local file.
    - Reviews: SwiftData storage (separate model/table), protocol-driven data access via `ReviewStore`.
  - Domain: Entities (ShopSeed, ReviewModel), mappers, validation, and business rules (average rating computation).
  - Presentation: SwiftUI views, reusable components (StarRatingView, ShopCard, AddressLink, ReviewList, ReviewForm) and observable view models.

- Principles
  - Dependency inversion via protocols for data sources.
  - Immutable structs for decoded seed data; SwiftData models for persisted entities.
  - State management with observable view models and `@Query` where appropriate.
  - Navigation via NavigationStack.

- Reusable Components
  - StarRatingView (display & interactive input variants)
  - ShopCard (used in list and featured sections)
  - AddressLink (launches Maps)
  - WebLinkButton (opens website)
  - ReviewRow, ReviewListView, ReviewFormView

---

## SwiftData Storage ##

This project integrates SwiftData to persist user reviews in a dedicated model (table) separate from the seed shop data.

- Requirements
  - iOS 17+ and Xcode 15+
  - SwiftData enabled in the target (link SwiftData framework)

- Model Container
  - The app creates a `ModelContainer` including the `ReviewEntity` model.
  - The container is injected into the environment at app launch using `.modelContainer(...)`.

- Models (Tables)
  - ShopSeed (not persisted via SwiftData; decoded from JSON)
  - ReviewEntity (@Model, persisted by SwiftData)
    - Fields: id (UUID), shopID (String), createdAt (Date), rating (Double), title (String?), comment (String?)
    - Indexed shopID for efficient queries per shop.

- Access Patterns
  - Write: Use `@Environment(\.modelContext)` to insert a new `ReviewEntity`.
  - Read:
    - Use `@Query(filter: #Predicate { $0.shopID == ... }, sort: ...)` in detail views, or
    - Fetch explicitly via `ModelContext.fetch(...)` in a view model.
  - Aggregation: Compute average rating in-memory from fetched reviews; fall back to seed rating when none exist.

- Migration
  - Previous file-based storage is replaced by SwiftData.
  - If upgrading from a build that used file storage, a one-time migration can import existing JSON files into SwiftData at first launch (optional; see “Migration” notes in code comments).

- Backup & Privacy
  - SwiftData stores within the app container, included in device backups.
  - No PII is collected; reviews are local-only.

---

## Reviews Feature ##

- Overview
  - Users can submit reviews for any shop: star rating (0.5–5.0), optional title, and optional comment.
  - Reviews are stored locally with SwiftData and shown in the shop detail screen.
  - The displayed rating is computed from user reviews when present; otherwise, the seed rating from the shop JSON is shown.

- Rating Computation
  - If there are N user reviews for a shop, the average is:
    - avg_user = sum(userRatings) / N
  - Displayed rating:
    - If N > 0: displayed = avg_user
    - Else: displayed = seed_rating (from JSON)
  - Optionally, the UI may show both “Community” and “Seed” ratings.

- Validation
  - Rating must be provided (0.5–5.0, 0.5 step).
  - Title ≤ 80 characters (optional).
  - Comment ≤ 1,000 characters (optional).
  - Basic profanity filtering and whitespace trimming (optional).

- Accessibility
  - VoiceOver labels for star input and review fields.
  - Dynamic Type support and sufficient contrast.
  - Clear error messages and input hints.

---

## Data Model ##

- ShopSeed (decoded from seed JSON; not persisted via SwiftData)
  - id: String (stable identifier derived from name/address or provided)
  - name: String
  - description: String?
  - picture: URL?
  - rating: Double (seed)
  - address: String
  - coordinates: [Double; lat, lon]
  - google_maps_link: URL?
  - website: URL?

- ReviewEntity (SwiftData @Model; separate table)
  - id: UUID
  - shopID: String (indexed)
  - createdAt: Date
  - rating: Double (0.5–5.0)
  - title: String?
  - comment: String?

- ReviewStore (protocol abstraction)
  - func reviews(for shopID: String) async throws -> [ReviewEntity]
  - func add(_ review: ReviewEntity) async throws
  - Optional: delete/edit for future moderation

Notes:
- ShopSeed remains a lightweight, decodable struct to keep the seed source simple and replaceable.
- If desired, a `ShopEntity` SwiftData model can be added later for full persistence and relationships.

---

## Screens & Navigation ##

- Shop List
  - Displays shop cards with name, address, and displayed rating.
  - Search and filters (planned).

- Shop Detail
  - Header with image, name, links (Maps, Website).
  - Description and displayed rating (with count of user reviews).
  - Reviews section:
    - List of existing reviews (most recent first).
    - “Add Review” button.

- Add Review Flow
  - Presents ReviewFormView:
    - Star rating input (0-5 step).
    - Optional title and comment fields with validation hints.
    - Save/Cancel actions.
  - On Save: Persists via SwiftData and updates the list/detail immediately.

---

## Testing ##

- Unit Tests
  ✅ JSON decoding for shops.
  - Review validation rules (rating bounds, field lengths).
  - Average rating computation logic.
  - SwiftData ReviewStore implementation (using an in-memory ModelContainer).

- UI/Interaction Tests
  - Submitting a review updates the list and average rating.
  - Accessibility: VoiceOver labels for star input and form fields.

- Snapshot Tests
  - ShopCard, StarRatingView (display/input), ReviewRow at multiple Dynamic Type sizes.

- Example using Swift Testing
  - Tests verify rating aggregation and SwiftData persistence behavior using an in-memory container.

---

## Future Improvements ##

- Add Sign in into iCloud
✅ Add offline caching of Honey shop data.
✅ Implement search and filtering on the list screen.  
- Support localization and accessibility enhancements.  
✅ Integrate a map view directly inside the app to show shop locations.  
✅ Add user reviews and ratings submission features.  
✅ Store reviews using SwiftData in a separate table.  
- Enhance image loading with caching and placeholders.  
- Include more detailed error handling and user feedback.  
- Cloud sync and/or backend integration for cross-device review sharing.  
- Moderation tools (report, edit, delete).  
- Relationship modeling with a SwiftData `ShopEntity` and cascading deletes.

---

## Sample Honey Shops JSON ##

Using https://api.jsonbin.io

```json
[
  {
    "name": "The House of Honey",
    "description": "Sanctuary for local bees, café y tienda con degustación de miel en Swan Valley, Australia",
    "picture": "https://thehouseofhoney.com.au/wp-content/uploads/2024/01/shopfront.jpg",
    "rating": 4.8,
    "address": "Mariani Ave, Henley Brook WA 6055, Australia",
    "coordinates": [ -31.8552, 116.0019],
    "google_maps_link": "https://www.google.com/maps/place/The+House+of+Honey+WA",
    "website": "https://thehouseofhoney.com.au"
  },
  {
    "name": "Montana Honey Bee Company",
    "description": "Tienda local especializada en miel sin procesar, venta de equipo apícola y degustaciones en Bozeman",
    "picture": "https://montanahoneybeecompany.com/images/storefront.jpg",
    "rating": 4.7,
    "address": "19 S Tracy Ave, Bozeman, MT 59715, USA",
    "coordinates": [45.6740, -111.0429],
    "google_maps_link": "https://www.google.com/maps/place/Montana+Honey+Bee+Company",
    "website": "https://montanahoneybeecompany.com"
  },
  {
    "name": "Walker Honey Farm",
    "description": "Apicultores familiares en Texas con tienda en sitio, venden miel silvestre y productos derivados",
    "picture": "https://walkerhoneyfarm.com/assets/images/shop.jpg",
    "rating": 4.5,
    "address": "8060 E US Hwy 190, Rogers, TX 76569, USA",
    "coordinates": [31.1305, -97.2361],
    "google_maps_link": "https://www.google.com/maps/place/Walker+Honey+Farm",
    "website": "https://www.walkerhoneyfarm.com"
  },
  {
    "name": "The Basin Backyard Honey Shop",
    "description": "Producción local de miel pura cruda y tienda en Knoxfield, Melbourne",
    "picture": "https://tbbyard.com.au/images/honey-shop.jpg",
    "rating": 4.6,
    "address": "Knoxfield VIC, Melbourne, Australia",
    "coordinates": [-37.8550, 145.2050],
    "google_maps_link": "https://www.google.com/maps/place/The+Basin+Backyard",
    "website": "https://www.tbbyard.com.au"
  },
  {
    "name": "Hani Honey Company",
    "description": "Compañía de miel al por mayor y venta directa, con horario de atención al público en Stuart, Florida",
    "picture": "https://hanihoneycompany.com/images/shop.jpg",
    "rating": 4.4,
    "address": "724 S Colorado Ave, Stuart, FL 34997, USA",
    "coordinates": [27.1942, -80.2498],
    "google_maps_link": "https://www.google.com/maps/place/Hani+Honey+Company",
    "website": "https://hanihoneycompany.com"
  }
]
```
