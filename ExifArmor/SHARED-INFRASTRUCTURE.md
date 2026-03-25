# ExifArmor Infrastructure Notes

## Current Architecture

ExifArmor is currently an offline-first iOS app.

- Photo analysis and metadata stripping happen entirely on-device.
- Privacy stats are stored locally on-device.
- The share extension uses the app group `group.com.katafract.exifarmor`.
- Pro unlocks are handled with StoreKit 2 and local entitlement checks.
- The app does not depend on a backend service for core functionality.

## Network Use

ExifArmor should not make general-purpose web requests during normal use.

Allowed Apple-managed network activity:
- StoreKit product loading
- StoreKit purchase flow
- StoreKit restore/sync flow

Not used by the app runtime:
- custom analytics backend
- App Store Server Notifications webhook handling
- RevenueCat
- Google Play billing infrastructure
- admin dashboards

## App Store Connect

For the current release, App Store Connect only needs to be configured for:

- app record with bundle ID `com.katafract.exifarmor`
- non-consumable IAP `com.katafract.ExifArmor.Pro`
- TestFlight distribution
- privacy policy and support URLs

App Store Server Notifications are optional and are not required for ExifArmor to unlock Pro, restore purchases, or function offline.

## Local State

The app currently relies on:

- `UserDefaults.standard` for local app state
- App Group entitlements for share extension coordination
- StoreKit 2 transaction state for purchase verification

## If Backend Work Returns Later

If a server is reintroduced in the future, document it here only after:

1. the runtime dependency is implemented in app code
2. the privacy policy is updated
3. App Store metadata is updated to reflect the change

Until then, treat ExifArmor as a local-only app with StoreKit as its only external service dependency.
