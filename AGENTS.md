# ExifArmor — Agent Instructions

## Project Purpose

iOS photo and video metadata privacy app. Strips EXIF/metadata from photos and videos before sharing. Free tier allows 5 strips per day; Pro tier (IAP) is unlimited. Open source core + paid App Store version.

## Tech Stack

- Swift / SwiftUI
- Photos framework (PhotosKit) — read/write photo library
- AVFoundation — video metadata stripping
- StoreKit 2 — Pro tier in-app purchase
- Share Extension — strip metadata directly from share sheet
- Unit tests + UI tests

## Targets

| Target | Purpose |
|---|---|
| ExifArmor | Main app |
| ExifArmorShareExtension | Share sheet integration |
| ExifArmorTests | Unit tests |
| ExifArmorUITests | UI tests |

## Key Files

```
ExifArmor/              # Main app Swift source
ExifArmorShareExtension/ # Share extension
ExifArmor.entitlements  # App entitlements
StoreKitConfig/         # StoreKit configuration for testing IAP
ExifArmor.xcodeproj
```

## How to Build

```bash
xcodebuild -scheme ExifArmor -destination 'platform=iOS Simulator,name=iPhone 16' build
```

## How to Run Tests

```bash
xcodebuild test -scheme ExifArmor -destination 'platform=iOS Simulator,name=iPhone 16'
```

## In-App Purchase

- **Free tier**: 5 metadata strips per day
- **Pro tier**: unlimited strips (StoreKit 2 IAP)
- `StoreKitConfig/` contains the StoreKit configuration file for local testing
- Pro entitlement validated via StoreKit 2 Transaction API — do not use receipt validation

## Architectural Patterns

- EXIF stripping: write new file without metadata rather than attempting to edit in place
- Rate limiting (free tier): stored in UserDefaults, reset daily
- Share Extension has separate entitlements and limited memory — keep metadata processing lightweight

## Constraints

- Do not send photos to any remote server — all processing is on-device
- Do not break the free tier limit enforcement (5/day) without a product decision
- StoreKit 2 only — do not use legacy receipt validation
- Share Extension memory limit: keep under 60MB working set
- `ExifArmor.entitlements` must include correct App Group for Share Extension ↔ app communication
