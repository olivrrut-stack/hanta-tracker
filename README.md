# HantaWatch

Global hantavirus outbreak tracker for iOS. Dark dashboard with a live map, color-coded case dots, and tap-for-details on any outbreak location.

## Mac Setup (build in Xcode)

1. Install Xcode from the Mac App Store (requires macOS 14+)
2. Install XcodeGen: `brew install xcodegen`
3. Clone this repo: `git clone <your-repo-url>`
4. In the project folder, run: `xcodegen generate`
5. Open `HantaTracker.xcodeproj` in Xcode
6. Select your target device or simulator
7. Press ▶ to build and run

## App Store Submission

1. In Xcode → Signing & Capabilities → set your Apple Developer Team
2. Change the bundle identifier to your own (e.g. `com.yourname.hantawatch`)
3. Add a 1024x1024 app icon image to `Assets.xcassets/AppIcon.appiconset/`
4. Product → Archive
5. Distribute App → App Store Connect

## Map Legend

| Color | Meaning |
|-------|---------|
| Red (pulsing) | High activity — recent confirmed cases |
| Orange | Elevated — active monitoring |
| Yellow | Monitoring — sporadic/historical |

## Data

v1 uses bundled case data (`fallback_cases.json`) sourced from WHO, CDC, PAHO, and ECDC reports.
