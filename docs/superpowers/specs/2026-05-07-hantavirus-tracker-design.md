# HantaTracker — Design Spec
**Date:** 2026-05-07  
**Platform:** iOS  
**Stack:** SwiftUI + MapKit + URLSession (async/await)  
**Goal:** Submit to App Store in one session

---

## What We're Building

A dark-themed iOS dashboard app that shows confirmed hantavirus case locations on a 2D map. Users can tap a location dot to see case details. Data comes from the HealthMap API with a hardcoded fallback for offline/empty states.

Inspired by worldmonitor.app: dark, data-dense, live-feeling.

---

## Architecture

```
HantaTrackerApp
├── ContentView                  (root — hosts MapView + overlays)
├── MapView                      (SwiftUI Map with custom annotations)
├── CaseAnnotationView           (color-coded dot for each case location)
├── CaseDetailSheet              (bottom sheet on tap)
├── HeaderView                   (app name + last-updated timestamp)
├── ViewModel
│   └── OutbreakViewModel        (@MainActor ObservableObject — state + fetch logic)
└── Services
    ├── HealthMapService         (API fetch, decode)
    └── CacheService             (persist last response to disk)
```

**Data flow:**
1. App launches → `OutbreakViewModel.load()` called
2. `HealthMapService` fetches HealthMap API filtered for "hantavirus"
3. Response decoded into `[CaseLocation]` array
4. `CacheService` persists response to disk
5. If fetch fails → `CacheService` loads last-known data
6. `MapView` renders `CaseAnnotationView` for each location
7. User taps dot → `selectedCase` set → `CaseDetailSheet` presented

---

## Data Models

```swift
struct CaseLocation: Identifiable, Codable {
    let id: String
    let country: String
    let region: String?
    let latitude: Double
    let longitude: Double
    let confirmedCount: Int?
    let severity: Severity
    let lastUpdated: Date
    let description: String
    let sourceURL: String?
}

enum Severity: String, Codable {
    case high        // red dot
    case elevated    // orange dot
    case monitoring  // yellow dot
}
```

---

## Screens

### 1. Main Screen (ContentView)

- Full-screen `Map` in `.dark` color scheme
- Custom dark map style (`.standard` with dark appearance)
- `CaseAnnotationView` dots overlaid for each `CaseLocation`
- `HeaderView` pinned at top: "HANTAWATCH" title + "LIVE" badge + last updated time
- Pull-to-refresh gesture triggers re-fetch
- Loading spinner while fetching

### 2. Case Annotation Dots (CaseAnnotationView)

- Circle, 14pt diameter
- Color by severity: red (`#FF3B30`) / orange (`#FF9500`) / yellow (`#FFCC00`)
- Subtle pulsing animation on `high` severity dots
- Tap selects the case → presents detail sheet

### 3. Case Detail Bottom Sheet (CaseDetailSheet)

Presented as `.sheet` with `.presentationDetents([.medium])`.

Contents:
- Country name (large, bold)
- Region (if available, smaller subtitle)
- Severity badge (colored pill: "HIGH ACTIVITY" / "ELEVATED" / "MONITORING")
- Confirmed cases count (if available)
- Last updated date
- Description text (2-3 sentences from HealthMap)
- "View Source" link button (opens `sourceURL` in Safari) — only shown if URL exists

### 4. Launch Screen + App Icon

- Launch screen: black background, white "HANTAWATCH" text centered
- App icon: dark background with a red location pin or biohazard-style marker

---

## Data Source

**Primary:** HealthMap API  
- Endpoint: `https://healthmap.org/getHTML5Alerts.php` (verify exact endpoint)
- Filter: query for "hantavirus" keyword
- Parse response into `[CaseLocation]`
- Fetch on launch + on pull-to-refresh
- 15-minute minimum between auto-refreshes (don't hammer the API)

**Fallback (hardcoded JSON — always bundled):**  
15 historical hantavirus hotspots used when:
- Network unavailable
- API returns empty/error
- First launch before any cache exists

Fallback locations include:
- Chile (Andes strain, high activity)
- Argentina (Andes strain)
- USA — Four Corners region, NM/AZ/CO/UT (Sin Nombre strain)
- USA — Western states general
- Panama
- Brazil
- Bolivia
- Paraguay
- Germany (Puumala strain)
- Finland
- Sweden
- Russia (Siberia)
- China (Hantaan strain)
- South Korea
- Thailand

---

## What Is NOT In This Version

The following are explicitly out of scope for v1 and must not be added:

- Layer toggle panel
- Severity badge / DEFCON-style header indicator
- Bottom news feed
- Search or filter by country
- 3D globe
- Push notifications
- User accounts or login
- Multiple disease comparison
- Historical timeline slider
- Real-time WebSocket (polling on refresh only)
- iPad-specific layout
- Widgets or Apple Watch app
- Localization / multi-language

---

## App Store Requirements Checklist

- [ ] App icon (all required sizes via asset catalog)
- [ ] Launch screen storyboard or SwiftUI launch view
- [ ] Privacy manifest (no tracking, no user data collected)
- [ ] App description for App Store Connect
- [ ] Screenshots (at least 3, iPhone 6.5")
- [ ] Support URL (can be a GitHub repo URL)
- [ ] Privacy policy URL (required — simple one hosted on GitHub Pages is fine)

---

## Verification

1. Launch app → map loads with dots in known hantavirus regions
2. Tap a dot → sheet slides up with correct country/severity/description
3. Kill network → restart app → cached data still shows with "last updated" timestamp
4. Pull down on map → spinner appears → data refreshes
5. No crashes on empty API response (fallback data kicks in)
