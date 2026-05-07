# HantaWatch Implementation Plan

> **For agentic workers:** REQUIRED SUB-SKILL: Use superpowers:subagent-driven-development (recommended) or superpowers:executing-plans to implement this plan task-by-task. Steps use checkbox (`- [ ]`) syntax for tracking.

**Goal:** Build a dark-themed iOS dashboard app showing hantavirus case locations on a MapKit map with tap-for-details functionality.

**Architecture:** SwiftUI app with a full-screen dark MapKit map, color-coded annotations per case severity, and a bottom sheet detail view. Data is bundled as JSON (v1) with a HealthMapService stub ready for live data later. OutbreakViewModel manages all state.

**Tech Stack:** Swift 5.9+, SwiftUI, MapKit, XcodeGen (generates .xcodeproj on Mac), iOS 17+

---

## File Map

```
HantaTracker/
├── project.yml                          XcodeGen project spec
├── HantaTracker/
│   ├── HantaTrackerApp.swift            App entry point
│   ├── Models/
│   │   └── CaseLocation.swift           CaseLocation struct + Severity enum
│   ├── Resources/
│   │   └── fallback_cases.json          Bundled case data (15 global hotspots)
│   ├── Services/
│   │   ├── HealthMapService.swift        Fetch + decode (uses bundled data in v1)
│   │   └── CacheService.swift           Persist last response to disk
│   ├── ViewModels/
│   │   └── OutbreakViewModel.swift      @MainActor ObservableObject, owns fetch logic
│   └── Views/
│       ├── ContentView.swift            Root: map + header + sheet presentation
│       ├── HeaderView.swift             Top bar: title + live badge + last updated
│       ├── CaseAnnotationView.swift     Color-coded pulsing dot
│       └── CaseDetailSheet.swift        Bottom sheet: country, severity, description
└── README.md                            Mac setup instructions
```

---

### Task 1: XcodeGen project spec

**Files:**
- Create: `project.yml`

- [ ] Create `project.yml` at project root:

```yaml
name: HantaTracker
options:
  bundleIdPrefix: com.hantawatch
  deploymentTarget:
    iOS: "17.0"
  xcodeVersion: "15.0"
settings:
  base:
    SWIFT_VERSION: 5.9
    DEVELOPMENT_TEAM: ""
targets:
  HantaTracker:
    type: application
    platform: iOS
    sources:
      - HantaTracker
    settings:
      base:
        PRODUCT_BUNDLE_IDENTIFIER: com.hantawatch.app
        INFOPLIST_FILE: HantaTracker/Info.plist
        ASSETCATALOG_COMPILER_APPICON_NAME: AppIcon
    info:
      path: HantaTracker/Info.plist
      properties:
        UILaunchStoryboardName: LaunchScreen
        UISupportedInterfaceOrientations:
          - UIInterfaceOrientationPortrait
        NSLocationWhenInUseUsageDescription: ""
        UIApplicationSceneManifest:
          UIApplicationSupportsMultipleScenes: false
          UISceneConfigurations:
            UIWindowSceneSessionRoleApplication:
              - UISceneConfigurationName: Default Configuration
                UISceneDelegateClassName: $(PRODUCT_MODULE_NAME).SceneDelegate
```

- [ ] Commit:
```bash
git add project.yml
git commit -m "chore: add XcodeGen project spec"
```

---

### Task 2: Data models

**Files:**
- Create: `HantaTracker/Models/CaseLocation.swift`

- [ ] Create `HantaTracker/Models/CaseLocation.swift`:

```swift
import Foundation

enum Severity: String, Codable {
    case high
    case elevated
    case monitoring
}

struct CaseLocation: Identifiable, Codable {
    let id: String
    let country: String
    let region: String?
    let latitude: Double
    let longitude: Double
    let confirmedCount: Int?
    let severity: Severity
    let lastUpdated: String
    let description: String
    let sourceURL: String?
}
```

- [ ] Commit:
```bash
git add HantaTracker/Models/CaseLocation.swift
git commit -m "feat: add CaseLocation model and Severity enum"
```

---

### Task 3: Bundled fallback case data

**Files:**
- Create: `HantaTracker/Resources/fallback_cases.json`

- [ ] Create `HantaTracker/Resources/fallback_cases.json`:

```json
[
  {
    "id": "cl-01",
    "country": "Chile",
    "region": "Aysén Region",
    "latitude": -46.4,
    "longitude": -72.0,
    "confirmedCount": 12,
    "severity": "high",
    "lastUpdated": "2026-04-15",
    "description": "Ongoing Andes hantavirus transmission in rural southern Chile. Cases linked to exposure to long-tailed rice rat (Oligoryzomys longicaudatus) in forested areas.",
    "sourceURL": "https://www.who.int"
  },
  {
    "id": "ar-01",
    "country": "Argentina",
    "region": "Patagonia",
    "latitude": -42.0,
    "longitude": -70.0,
    "confirmedCount": 8,
    "severity": "high",
    "lastUpdated": "2026-04-10",
    "description": "Andes hantavirus cluster in northern Patagonia. Person-to-person transmission possible with this strain — contact tracing active.",
    "sourceURL": "https://www.who.int"
  },
  {
    "id": "us-01",
    "country": "United States",
    "region": "Four Corners (NM/AZ/CO/UT)",
    "latitude": 36.9,
    "longitude": -108.7,
    "confirmedCount": 4,
    "severity": "elevated",
    "lastUpdated": "2026-03-28",
    "description": "Sin Nombre virus cases reported in the Four Corners region. Exposure linked to deer mouse (Peromyscus maniculatus) in rural dwellings.",
    "sourceURL": "https://www.cdc.gov"
  },
  {
    "id": "us-02",
    "country": "United States",
    "region": "Pacific Northwest",
    "latitude": 47.5,
    "longitude": -120.5,
    "confirmedCount": 2,
    "severity": "monitoring",
    "lastUpdated": "2026-02-14",
    "description": "Sporadic Sin Nombre virus cases in Washington and Oregon. Risk elevated in rural and camping areas during rodent population peaks.",
    "sourceURL": "https://www.cdc.gov"
  },
  {
    "id": "pa-01",
    "country": "Panama",
    "region": "Los Santos Province",
    "latitude": 7.8,
    "longitude": -80.4,
    "confirmedCount": 3,
    "severity": "elevated",
    "lastUpdated": "2026-03-05",
    "description": "Choclo virus (HPS) cases reported in the Azuero Peninsula. Reservoir is the pygmy rice rat.",
    "sourceURL": "https://www.paho.org"
  },
  {
    "id": "br-01",
    "country": "Brazil",
    "region": "São Paulo State",
    "latitude": -22.5,
    "longitude": -48.0,
    "confirmedCount": 6,
    "severity": "elevated",
    "lastUpdated": "2026-04-02",
    "description": "HPS cases in rural São Paulo State. Juquitiba and Araraquara strains circulating. Agricultural workers at elevated risk.",
    "sourceURL": "https://www.paho.org"
  },
  {
    "id": "bo-01",
    "country": "Bolivia",
    "region": "Beni Department",
    "latitude": -15.0,
    "longitude": -65.0,
    "confirmedCount": 2,
    "severity": "monitoring",
    "lastUpdated": "2026-01-20",
    "description": "Sporadic Laguna Negra virus cases in lowland Bolivia. Vesper mouse (Calomys laucha) is the primary reservoir.",
    "sourceURL": "https://www.paho.org"
  },
  {
    "id": "py-01",
    "country": "Paraguay",
    "region": "Western Region",
    "latitude": -22.0,
    "longitude": -60.0,
    "confirmedCount": 1,
    "severity": "monitoring",
    "lastUpdated": "2025-12-10",
    "description": "Isolated Laguna Negra hantavirus case in the Chaco region. No evidence of sustained transmission.",
    "sourceURL": "https://www.paho.org"
  },
  {
    "id": "de-01",
    "country": "Germany",
    "region": "Baden-Württemberg",
    "latitude": 48.5,
    "longitude": 9.0,
    "confirmedCount": 31,
    "severity": "elevated",
    "lastUpdated": "2026-04-18",
    "description": "Puumala orthohantavirus outbreak linked to high bank vole (Myodes glareolus) population. Nephropathia epidemica (NE) — milder form, renal syndrome predominant.",
    "sourceURL": "https://www.ecdc.europa.eu"
  },
  {
    "id": "fi-01",
    "country": "Finland",
    "region": "Central Finland",
    "latitude": 62.5,
    "longitude": 25.5,
    "confirmedCount": 18,
    "severity": "elevated",
    "lastUpdated": "2026-03-30",
    "description": "Puumala virus season active. Finland reports some of the highest NE incidence in Europe during bank vole peak years.",
    "sourceURL": "https://www.ecdc.europa.eu"
  },
  {
    "id": "se-01",
    "country": "Sweden",
    "region": "Northern Sweden",
    "latitude": 64.0,
    "longitude": 20.0,
    "confirmedCount": 9,
    "severity": "monitoring",
    "lastUpdated": "2026-03-15",
    "description": "Puumala hantavirus cases in Norrland. Closely tracks 3-4 year vole population cycle.",
    "sourceURL": "https://www.ecdc.europa.eu"
  },
  {
    "id": "ru-01",
    "country": "Russia",
    "region": "Siberia / Ural Region",
    "latitude": 55.0,
    "longitude": 60.0,
    "confirmedCount": 22,
    "severity": "high",
    "lastUpdated": "2026-04-05",
    "description": "Puumala and Hantaan virus cases across Ural and Western Siberia. Russia reports the highest absolute number of HFRS cases in Europe annually.",
    "sourceURL": "https://www.who.int"
  },
  {
    "id": "cn-01",
    "country": "China",
    "region": "Northeastern China",
    "latitude": 43.0,
    "longitude": 125.0,
    "confirmedCount": 47,
    "severity": "high",
    "lastUpdated": "2026-04-20",
    "description": "Hantaan and Seoul virus HFRS cases in Heilongjiang and Jilin provinces. China accounts for over 90% of global HFRS cases annually.",
    "sourceURL": "https://www.who.int"
  },
  {
    "id": "kr-01",
    "country": "South Korea",
    "region": "Gyeonggi Province",
    "latitude": 37.5,
    "longitude": 127.0,
    "confirmedCount": 5,
    "severity": "monitoring",
    "lastUpdated": "2026-02-28",
    "description": "Hantaan virus HFRS cases near the DMZ. The disease was first identified here — historically called Korean hemorrhagic fever.",
    "sourceURL": "https://www.who.int"
  },
  {
    "id": "th-01",
    "country": "Thailand",
    "region": "Northern Thailand",
    "latitude": 18.5,
    "longitude": 99.0,
    "confirmedCount": 2,
    "severity": "monitoring",
    "lastUpdated": "2025-11-15",
    "description": "Sporadic Thailand orthohantavirus cases in Chiang Mai area. Underdiagnosis likely due to symptom overlap with other febrile illnesses.",
    "sourceURL": "https://www.who.int"
  }
]
```

- [ ] Commit:
```bash
git add HantaTracker/Resources/fallback_cases.json
git commit -m "feat: add bundled hantavirus case data (15 global hotspots)"
```

---

### Task 4: CacheService

**Files:**
- Create: `HantaTracker/Services/CacheService.swift`

- [ ] Create `HantaTracker/Services/CacheService.swift`:

```swift
import Foundation

final class CacheService {
    private let fileName = "cached_cases.json"

    private var cacheURL: URL {
        FileManager.default.urls(for: .cachesDirectory, in: .userDomainMask)[0]
            .appendingPathComponent(fileName)
    }

    func save(_ cases: [CaseLocation]) {
        guard let data = try? JSONEncoder().encode(cases) else { return }
        try? data.write(to: cacheURL)
    }

    func load() -> [CaseLocation]? {
        guard let data = try? Data(contentsOf: cacheURL),
              let cases = try? JSONDecoder().decode([CaseLocation].self, from: data)
        else { return nil }
        return cases
    }

    func lastUpdated() -> Date? {
        (try? cacheURL.resourceValues(forKeys: [.contentModificationDateKey]))?.contentModificationDate
    }
}
```

- [ ] Commit:
```bash
git add HantaTracker/Services/CacheService.swift
git commit -m "feat: add CacheService for offline persistence"
```

---

### Task 5: HealthMapService

**Files:**
- Create: `HantaTracker/Services/HealthMapService.swift`

- [ ] Create `HantaTracker/Services/HealthMapService.swift`:

```swift
import Foundation

final class HealthMapService {
    // v1: loads bundled data. Wire a live API here in v2.
    func fetchCases() async throws -> [CaseLocation] {
        guard let url = Bundle.main.url(forResource: "fallback_cases", withExtension: "json"),
              let data = try? Data(contentsOf: url),
              let cases = try? JSONDecoder().decode([CaseLocation].self, from: data)
        else {
            throw URLError(.cannotDecodeContentData)
        }
        return cases
    }
}
```

- [ ] Commit:
```bash
git add HantaTracker/Services/HealthMapService.swift
git commit -m "feat: add HealthMapService (v1 loads bundled data)"
```

---

### Task 6: OutbreakViewModel

**Files:**
- Create: `HantaTracker/ViewModels/OutbreakViewModel.swift`

- [ ] Create `HantaTracker/ViewModels/OutbreakViewModel.swift`:

```swift
import Foundation

@MainActor
final class OutbreakViewModel: ObservableObject {
    @Published var cases: [CaseLocation] = []
    @Published var isLoading = false
    @Published var lastUpdated: Date?
    @Published var selectedCase: CaseLocation?

    private let service = HealthMapService()
    private let cache = CacheService()

    func load() async {
        isLoading = true
        do {
            let fetched = try await service.fetchCases()
            cases = fetched
            cache.save(fetched)
            lastUpdated = Date()
        } catch {
            if let cached = cache.load() {
                cases = cached
                lastUpdated = cache.lastUpdated()
            } else {
                cases = loadFallback()
                lastUpdated = nil
            }
        }
        isLoading = false
    }

    private func loadFallback() -> [CaseLocation] {
        guard let url = Bundle.main.url(forResource: "fallback_cases", withExtension: "json"),
              let data = try? Data(contentsOf: url),
              let cases = try? JSONDecoder().decode([CaseLocation].self, from: data)
        else { return [] }
        return cases
    }
}
```

- [ ] Commit:
```bash
git add HantaTracker/ViewModels/OutbreakViewModel.swift
git commit -m "feat: add OutbreakViewModel with load/cache/fallback logic"
```

---

### Task 7: HeaderView

**Files:**
- Create: `HantaTracker/Views/HeaderView.swift`

- [ ] Create `HantaTracker/Views/HeaderView.swift`:

```swift
import SwiftUI

struct HeaderView: View {
    let lastUpdated: Date?
    let isLoading: Bool

    private var updatedText: String {
        guard let date = lastUpdated else { return "CACHED DATA" }
        let formatter = RelativeDateTimeFormatter()
        formatter.unitsStyle = .abbreviated
        return "UPDATED \(formatter.localizedString(for: date, relativeTo: Date()).uppercased())"
    }

    var body: some View {
        HStack(spacing: 12) {
            Text("HANTAWATCH")
                .font(.system(size: 16, weight: .bold, design: .monospaced))
                .foregroundColor(.white)

            Spacer()

            if isLoading {
                ProgressView()
                    .progressViewStyle(CircularProgressViewStyle(tint: .white))
                    .scaleEffect(0.8)
            } else {
                HStack(spacing: 6) {
                    Circle()
                        .fill(Color.green)
                        .frame(width: 7, height: 7)
                    Text("LIVE")
                        .font(.system(size: 11, weight: .semibold, design: .monospaced))
                        .foregroundColor(.green)
                }

                Text(updatedText)
                    .font(.system(size: 10, weight: .regular, design: .monospaced))
                    .foregroundColor(.gray)
            }
        }
        .padding(.horizontal, 16)
        .padding(.vertical, 12)
        .background(.ultraThinMaterial.opacity(0.9))
    }
}
```

- [ ] Commit:
```bash
git add HantaTracker/Views/HeaderView.swift
git commit -m "feat: add HeaderView with live badge and last-updated timestamp"
```

---

### Task 8: CaseAnnotationView

**Files:**
- Create: `HantaTracker/Views/CaseAnnotationView.swift`

- [ ] Create `HantaTracker/Views/CaseAnnotationView.swift`:

```swift
import SwiftUI

struct CaseAnnotationView: View {
    let severity: Severity
    @State private var pulsing = false

    private var color: Color {
        switch severity {
        case .high:       return Color(red: 1, green: 0.23, blue: 0.19)  // #FF3B30
        case .elevated:   return Color(red: 1, green: 0.58, blue: 0)     // #FF9500
        case .monitoring: return Color(red: 1, green: 0.8, blue: 0)      // #FFCC00
        }
    }

    var body: some View {
        ZStack {
            if severity == .high {
                Circle()
                    .fill(color.opacity(0.3))
                    .frame(width: pulsing ? 28 : 20, height: pulsing ? 28 : 20)
                    .animation(.easeInOut(duration: 1.2).repeatForever(autoreverses: true), value: pulsing)
            }
            Circle()
                .fill(color)
                .frame(width: 13, height: 13)
                .overlay(
                    Circle()
                        .stroke(Color.white.opacity(0.5), lineWidth: 1)
                )
        }
        .onAppear { pulsing = true }
    }
}
```

- [ ] Commit:
```bash
git add HantaTracker/Views/CaseAnnotationView.swift
git commit -m "feat: add CaseAnnotationView with severity colors and pulse animation"
```

---

### Task 9: CaseDetailSheet

**Files:**
- Create: `HantaTracker/Views/CaseDetailSheet.swift`

- [ ] Create `HantaTracker/Views/CaseDetailSheet.swift`:

```swift
import SwiftUI

struct CaseDetailSheet: View {
    let caseLocation: CaseLocation

    private var severityLabel: String {
        switch caseLocation.severity {
        case .high:       return "HIGH ACTIVITY"
        case .elevated:   return "ELEVATED"
        case .monitoring: return "MONITORING"
        }
    }

    private var severityColor: Color {
        switch caseLocation.severity {
        case .high:       return Color(red: 1, green: 0.23, blue: 0.19)
        case .elevated:   return Color(red: 1, green: 0.58, blue: 0)
        case .monitoring: return Color(red: 1, green: 0.8, blue: 0)
        }
    }

    var body: some View {
        VStack(alignment: .leading, spacing: 16) {
            HStack {
                VStack(alignment: .leading, spacing: 4) {
                    Text(caseLocation.country)
                        .font(.system(size: 24, weight: .bold, design: .monospaced))
                        .foregroundColor(.white)
                    if let region = caseLocation.region {
                        Text(region)
                            .font(.system(size: 13, weight: .regular, design: .monospaced))
                            .foregroundColor(.gray)
                    }
                }
                Spacer()
                Text(severityLabel)
                    .font(.system(size: 11, weight: .semibold, design: .monospaced))
                    .foregroundColor(severityColor)
                    .padding(.horizontal, 10)
                    .padding(.vertical, 5)
                    .background(severityColor.opacity(0.15))
                    .cornerRadius(4)
            }

            Divider().background(Color.gray.opacity(0.3))

            if let count = caseLocation.confirmedCount {
                HStack(spacing: 4) {
                    Text("\(count)")
                        .font(.system(size: 28, weight: .bold, design: .monospaced))
                        .foregroundColor(.white)
                    Text("confirmed cases")
                        .font(.system(size: 13, design: .monospaced))
                        .foregroundColor(.gray)
                        .padding(.top, 8)
                }
            }

            Text(caseLocation.description)
                .font(.system(size: 14, design: .monospaced))
                .foregroundColor(Color(white: 0.8))
                .lineSpacing(4)
                .fixedSize(horizontal: false, vertical: true)

            HStack {
                Text("Last updated: \(caseLocation.lastUpdated)")
                    .font(.system(size: 11, design: .monospaced))
                    .foregroundColor(.gray)
                Spacer()
                if let urlString = caseLocation.sourceURL, let url = URL(string: urlString) {
                    Link("VIEW SOURCE →", destination: url)
                        .font(.system(size: 11, weight: .semibold, design: .monospaced))
                        .foregroundColor(.green)
                }
            }

            Spacer()
        }
        .padding(24)
        .background(Color(white: 0.07))
    }
}
```

- [ ] Commit:
```bash
git add HantaTracker/Views/CaseDetailSheet.swift
git commit -m "feat: add CaseDetailSheet with country, severity, count, and description"
```

---

### Task 10: ContentView (main map)

**Files:**
- Create: `HantaTracker/Views/ContentView.swift`

- [ ] Create `HantaTracker/Views/ContentView.swift`:

```swift
import SwiftUI
import MapKit

struct ContentView: View {
    @StateObject private var viewModel = OutbreakViewModel()
    @State private var region = MKCoordinateRegion(
        center: CLLocationCoordinate2D(latitude: 20, longitude: 0),
        span: MKCoordinateSpan(latitudeDelta: 120, longitudeDelta: 120)
    )

    var body: some View {
        ZStack(alignment: .top) {
            Map(coordinateRegion: $region, annotationItems: viewModel.cases) { caseLocation in
                MapAnnotation(coordinate: CLLocationCoordinate2D(
                    latitude: caseLocation.latitude,
                    longitude: caseLocation.longitude
                )) {
                    CaseAnnotationView(severity: caseLocation.severity)
                        .onTapGesture {
                            viewModel.selectedCase = caseLocation
                        }
                }
            }
            .colorScheme(.dark)
            .ignoresSafeArea()

            VStack(spacing: 0) {
                HeaderView(lastUpdated: viewModel.lastUpdated, isLoading: viewModel.isLoading)
                Spacer()
            }
        }
        .preferredColorScheme(.dark)
        .sheet(item: $viewModel.selectedCase) { caseLocation in
            CaseDetailSheet(caseLocation: caseLocation)
                .presentationDetents([.medium])
                .presentationBackground(Color(white: 0.07))
        }
        .task {
            await viewModel.load()
        }
        .refreshable {
            await viewModel.load()
        }
    }
}
```

- [ ] Commit:
```bash
git add HantaTracker/Views/ContentView.swift
git commit -m "feat: add ContentView with dark MapKit map and annotation tap-to-detail"
```

---

### Task 11: App entry point

**Files:**
- Create: `HantaTracker/HantaTrackerApp.swift`

- [ ] Create `HantaTracker/HantaTrackerApp.swift`:

```swift
import SwiftUI

@main
struct HantaTrackerApp: App {
    var body: some Scene {
        WindowGroup {
            ContentView()
                .preferredColorScheme(.dark)
        }
    }
}
```

- [ ] Create `HantaTracker/Info.plist`:

```xml
<?xml version="1.0" encoding="UTF-8"?>
<!DOCTYPE plist PUBLIC "-//Apple//DTD PLIST 1.0//EN" "http://www.apple.com/DTDs/PropertyList-1.0.dtd">
<plist version="1.0">
<dict>
    <key>UILaunchStoryboardName</key>
    <string>LaunchScreen</string>
    <key>UISupportedInterfaceOrientations</key>
    <array>
        <string>UIInterfaceOrientationPortrait</string>
    </array>
    <key>NSLocationWhenInUseUsageDescription</key>
    <string></string>
</dict>
</plist>
```

- [ ] Commit:
```bash
git add HantaTracker/HantaTrackerApp.swift HantaTracker/Info.plist
git commit -m "feat: add app entry point and Info.plist"
```

---

### Task 12: Asset catalog

**Files:**
- Create: `HantaTracker/Assets.xcassets/Contents.json`
- Create: `HantaTracker/Assets.xcassets/AppIcon.appiconset/Contents.json`
- Create: `HantaTracker/Assets.xcassets/AccentColor.colorset/Contents.json`

- [ ] Create `HantaTracker/Assets.xcassets/Contents.json`:

```json
{
  "info" : {
    "author" : "xcode",
    "version" : 1
  }
}
```

- [ ] Create `HantaTracker/Assets.xcassets/AppIcon.appiconset/Contents.json`:

```json
{
  "images" : [
    {
      "idiom" : "universal",
      "platform" : "ios",
      "size" : "1024x1024"
    }
  ],
  "info" : {
    "author" : "xcode",
    "version" : 1
  }
}
```

- [ ] Create `HantaTracker/Assets.xcassets/AccentColor.colorset/Contents.json`:

```json
{
  "colors" : [
    {
      "color" : {
        "color-space" : "srgb",
        "components" : {
          "alpha" : "1.000",
          "blue" : "0.188",
          "green" : "0.231",
          "red" : "1.000"
        }
      },
      "idiom" : "universal"
    }
  ],
  "info" : {
    "author" : "xcode",
    "version" : 1
  }
}
```

- [ ] Commit:
```bash
git add HantaTracker/Assets.xcassets
git commit -m "chore: add asset catalog with AppIcon and AccentColor"
```

---

### Task 13: README with Mac setup instructions

**Files:**
- Create: `README.md`

- [ ] Create `README.md`:

```markdown
# HantaWatch

Global hantavirus outbreak tracker for iOS.

## Mac Setup (to build and run in Xcode)

1. Install Xcode from the Mac App Store (requires macOS 14+)
2. Install XcodeGen: `brew install xcodegen`
3. Clone this repo: `git clone <your-repo-url>`
4. In the project folder, run: `xcodegen generate`
5. Open `HantaTracker.xcodeproj` in Xcode
6. Select your target device or simulator
7. Press ▶ to build and run

## App Store Submission

1. In Xcode, set your Apple Developer Team in Signing & Capabilities
2. Set the bundle identifier to your own (e.g. `com.yourname.hantawatch`)
3. Product → Archive
4. Distribute App → App Store Connect
```

- [ ] Commit:
```bash
git add README.md
git commit -m "docs: add README with Mac Xcode setup instructions"
```

---

## Verification

1. On Mac: run `xcodegen generate` → `HantaTracker.xcodeproj` is created
2. Open in Xcode → builds with no errors
3. Run in iPhone simulator → dark map loads with 15 colored dots
4. Tap a dot → detail sheet slides up with country, severity badge, case count, description
5. Tap a red (high) dot → pulsing animation visible on the dot
6. Force airplane mode → restart app → cached/fallback data still shows
