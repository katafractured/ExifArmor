import Foundation

/// Defines which metadata categories to strip from a photo.
struct StripOptions {
    var removeLocation: Bool = true
    var removeDateTime: Bool = true
    var removeDeviceInfo: Bool = true
    var removeCameraSettings: Bool = true
    var removeAll: Bool = true

    /// Preset: remove everything (default).
    static let all = StripOptions(
        removeLocation: true,
        removeDateTime: true,
        removeDeviceInfo: true,
        removeCameraSettings: true,
        removeAll: true
    )

    /// Preset: remove only GPS/location data.
    static let locationOnly = StripOptions(
        removeLocation: true,
        removeDateTime: false,
        removeDeviceInfo: false,
        removeCameraSettings: false,
        removeAll: false
    )

    /// Preset: remove location + device info but keep camera settings.
    static let privacyFocused = StripOptions(
        removeLocation: true,
        removeDateTime: true,
        removeDeviceInfo: true,
        removeCameraSettings: false,
        removeAll: false
    )
}

/// Result of a strip operation on a single photo.
struct StripResult: Identifiable {
    let id = UUID()
    let originalMetadata: PhotoMetadata
    let cleanedImageData: Data
    let cleanedImage: UIImage
    let fieldsRemoved: Int
}

import UIKit
