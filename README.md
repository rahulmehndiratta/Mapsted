


https://github.com/user-attachments/assets/f61b3981-c7d9-49c7-9f39-781963cb343f


# Mapsted

iOS analytics dashboard app built with SwiftUI. Consumes Mapsted R&D interview APIs to display building and purchase analytics with filterable dropdowns and computed totals.

## Features

- **Purchase Costs** — Filter by Manufacturer, Category, Country, and State; view total costs per selection
- **Number of Purchases** — Select an item and see purchase count
- **Most Total Purchases** — Displays the building with the highest total purchase costs
- **Searchable selection sheets** — Full-screen pickers with search for all dropdowns
- **Offline handling** — Detects no network and shows a retry option
- **Themed UI** — Light blue section headers, light grey rows, dark grey buttons; layout constants and strings centralized for easy tuning and localization

## Requirements

- Xcode 16+
- iOS 15.0+
- Swift 5.9+

## Architecture

- **MVVM** — `DashboardView` binds to `DashboardViewModel`; all business logic and API usage live in the ViewModel
- **Factory + Protocol** — `APIClientProtocol` defines the data contract; `APIClientFactory` provides the concrete `MapstedAPIClient` (or a mock for tests)
- **Structured constants** — `AppConstants` (URLs, layout, formatting), `AppStrings` (user-facing text), `AppTheme` (colors)

## Project Structure

```
Mapsted/
├── Models/
│   ├── BuildingInfo.swift      # Building from GetBuildingData API
│   └── AnalyticsModels.swift   # DeviceUsage, SessionInfo, Purchase (GetAnalyticData)
├── Network/
│   ├── APIClientProtocol.swift # Protocol for API clients
│   ├── APIClientFactory.swift  # Factory for default/mock client
│   └── MapstedAPIClient.swift # Production implementation + APIClientError
├── ViewModels/
│   └── DashboardViewModel.swift
├── Views/
│   ├── DashboardView.swift     # Main dashboard (sections, rows, selection buttons)
│   └── Components/
│       ├── SelectionSheetView.swift  # Full-screen searchable picker
│       ├── LoadingView.swift        # Loading indicator (inline or full-screen)
│       └── DropdownRowView.swift
├── Theme/
│   └── AppTheme.swift         # Colors (light blue, grey, text)
├── Support/
│   ├── AppConstants.swift    # URLs, layout, formatting
│   └── AppStrings.swift      # Localizable strings
├── Config/
│   └── Info.plist             # ATS exception for Mapsted API (HTTP)
└── SwiftUITestApp.swift       # App entry point
```

## Setup & Run

1. Clone the repo and open the project (e.g. `Mapsted.xcodeproj` or `SwiftUITest.xcodeproj` if not yet renamed).
2. Select an iOS Simulator or device (target: iOS 15.0+).
3. Build and run (⌘R).

The app will load building and analytics data from:

- `http://rnd-interview.mapsted.com/GetBuildingData/`
- `http://rnd-interview.mapsted.com/GetAnalyticData/`

HTTP is allowed via App Transport Security settings in `Info.plist` for the Mapsted domain.

## Testing

Unit tests for `DashboardViewModel` live in **MapstedTests** (or SwiftUITestTests, depending on target name):

- **DashboardViewModelTests** — `MockAPIClient` injects success/failure; tests cover:
  - Successful load and default selections
  - Optional uniqueness and sorting (manufacturer, country, state, category, item)
  - Computed totals (manufacturer, category, country, state, item count, building with most purchases)
  - Unknown building when building ID is missing
  - Buildings-only failure (error prefix, analytics still applied)
  - Combined failures (both error prefixes)
  - No-connection sets `isOffline` and shows the no-internet message

Run tests: **Product → Test** (⌘U) or `xcodebuild test -scheme Mapsted -destination 'platform=iOS Simulator,name=iPhone 15'`.

## API

| Endpoint           | Description |
|--------------------|-------------|
| GetBuildingData/   | List of buildings (id, name, city, state, country) |
| GetAnalyticData/   | Device usage and purchase sessions (manufacturer, building_id, item_id, item_category_id, cost) |

Data is loaded in parallel; on success, dropdown options are derived from the data and default selections are set. All displayed totals and “most total purchases” are computed from the ViewModel’s flattened purchase data and building list.

## License

Proprietary — Mapsted test case #8.
