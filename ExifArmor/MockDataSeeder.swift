#if DEBUG
import Foundation
import UIKit

/// Mock data seeder for screenshot mode (--screenshots launch argument).
/// Provides sample photos with EXIF metadata for marketplace story UI testing.
struct MockDataSeeder {

    /// Returns pre-seeded marketplace photos with realistic EXIF metadata when in screenshot mode.
    static func seedMarketplacePhotos() -> [PhotoMetadata] {
        guard CommandLine.arguments.contains("--screenshots"),
              CommandLine.arguments.contains("--seed-data"),
              let seedType = seedDataType(),
              seedType == "marketplace"
        else { return [] }

        return buildMarketplacePhotos()
    }

    /// Returns pre-seeded marketplace photos with stripped metadata for the cleaned result flow.
    static func seedMarketplaceStripped() -> ([PhotoMetadata], [StripResult]) {
        guard CommandLine.arguments.contains("--screenshots"),
              CommandLine.arguments.contains("--seed-data"),
              let seedType = seedDataType(),
              seedType == "marketplace-stripped"
        else { return ([], []) }

        let originals = buildMarketplacePhotos()
        let stripResults = originals.map { original in
            // Mock a cleaned version with 0 metadata fields
            let cleanedImage = original.image
            let cleanedImageURL = FileManager.default.temporaryDirectory.appendingPathComponent(UUID().uuidString + ".jpg")
            if let cleanedData = cleanedImage.jpegData(compressionQuality: 0.9) {
                try? cleanedData.write(to: cleanedImageURL)
            }
            return StripResult(
                originalMetadata: original,
                cleanedImageURL: cleanedImageURL,
                cleanedImage: cleanedImage,
                fieldsRemoved: original.exposedFieldCount
            )
        }
        return (originals, stripResults)
    }

    // MARK: - Private

    private static func seedDataType() -> String? {
        guard let idx = CommandLine.arguments.firstIndex(of: "--seed-data"),
              idx + 1 < CommandLine.arguments.count
        else { return nil }
        return CommandLine.arguments[idx + 1]
    }

    private static func buildMarketplacePhotos() -> [PhotoMetadata] {
        [
            buildWatchListingPhoto(),
            buildBikeListingPhoto(),
            buildCameraListingPhoto(),
            buildSofaListingPhoto()
        ]
    }

    // MARK: - Individual Mock Photos

    private static func buildWatchListingPhoto() -> PhotoMetadata {
        let image = UIImage(named: "mock_watch_listing") ?? createPlaceholderImage(color: .systemGray2, label: "Watch")
        let imageData = image.jpegData(compressionQuality: 0.9) ?? Data()

        var metadata = PhotoMetadata(image: image, imageData: imageData)
        metadata.sourceUTI = "public.jpeg"
        // Park Slope, Brooklyn — residential brownstone block
        metadata.latitude = 40.6782
        metadata.longitude = -73.9796
        metadata.altitude = 24.0
        metadata.deviceMake = "Apple"
        metadata.deviceModel = "iPhone 16 Pro"
        metadata.software = "iOS 18.4.1"
        metadata.lensModel = "iPhone 16 Pro back triple camera 6.86mm f/1.78"
        metadata.dateTimeOriginal = "2026-04-28T06:47:00"
        metadata.focalLength = 6.86
        metadata.aperture = 1.78
        metadata.exposureTime = 1.0 / 1000.0
        metadata.iso = 50
        metadata.flash = false
        metadata.pixelWidth = 4032
        metadata.pixelHeight = 3024
        metadata.colorSpace = "sRGB"

        return metadata
    }

    private static func buildBikeListingPhoto() -> PhotoMetadata {
        let image = UIImage(named: "mock_bike_listing") ?? createPlaceholderImage(color: .systemBlue, label: "Bike")
        let imageData = image.jpegData(compressionQuality: 0.9) ?? Data()

        var metadata = PhotoMetadata(image: image, imageData: imageData)
        metadata.sourceUTI = "public.jpeg"
        // Lincoln Park, Chicago — residential neighborhood, not downtown
        metadata.latitude = 41.9215
        metadata.longitude = -87.6350
        metadata.altitude = 180.0
        metadata.deviceMake = "Apple"
        metadata.deviceModel = "iPhone 14 Pro"
        metadata.software = "iOS 17.5"
        metadata.lensModel = "iPhone 14 Pro back triple camera 6.86mm f/1.78"
        metadata.dateTimeOriginal = "2026-04-26T07:38:00"
        metadata.focalLength = 6.86
        metadata.aperture = 1.78
        metadata.exposureTime = 1.0 / 500.0
        metadata.iso = 100
        metadata.flash = false
        metadata.pixelWidth = 3840
        metadata.pixelHeight = 2880
        metadata.colorSpace = "sRGB"

        return metadata
    }

    private static func buildCameraListingPhoto() -> PhotoMetadata {
        let image = UIImage(named: "mock_camera_listing") ?? createPlaceholderImage(color: .systemRed, label: "Camera")
        let imageData = image.jpegData(compressionQuality: 0.9) ?? Data()

        var metadata = PhotoMetadata(image: image, imageData: imageData)
        metadata.sourceUTI = "public.jpeg"
        // Fremont, Seattle — residential neighborhood
        metadata.latitude = 47.6512
        metadata.longitude = -122.3494
        metadata.altitude = 52.0
        metadata.deviceMake = "Apple"
        metadata.deviceModel = "iPhone 13"
        metadata.software = "iOS 17.0"
        metadata.lensModel = "iPhone 13 back dual camera 6mm f/1.6"
        metadata.dateTimeOriginal = "2026-04-22T08:52:00"
        metadata.focalLength = 6.0
        metadata.aperture = 1.6
        metadata.exposureTime = 1.0 / 250.0
        metadata.iso = 160
        metadata.flash = false
        metadata.pixelWidth = 3072
        metadata.pixelHeight = 2304
        metadata.colorSpace = "sRGB"

        return metadata
    }

    private static func buildSofaListingPhoto() -> PhotoMetadata {
        let image = UIImage(named: "mock_sofa_listing") ?? createPlaceholderImage(color: .systemOrange, label: "Sofa")
        let imageData = image.jpegData(compressionQuality: 0.9) ?? Data()

        var metadata = PhotoMetadata(image: image, imageData: imageData)
        metadata.sourceUTI = "public.jpeg"
        // Silver Lake, Los Angeles — residential neighborhood
        metadata.latitude = 34.0871
        metadata.longitude = -118.2704
        metadata.altitude = 118.0
        metadata.deviceMake = "Apple"
        metadata.deviceModel = "iPhone 15"
        metadata.software = "iOS 18.0"
        metadata.lensModel = "iPhone 15 back dual camera 6.1mm f/1.6"
        metadata.dateTimeOriginal = "2026-04-20T09:15:00"
        metadata.focalLength = 6.1
        metadata.aperture = 1.6
        metadata.exposureTime = 1.0 / 120.0
        metadata.iso = 200
        metadata.flash = false
        metadata.pixelWidth = 3024
        metadata.pixelHeight = 4032
        metadata.colorSpace = "sRGB"

        return metadata
    }

    /// Create a simple solid-color placeholder image with centered text label.
    /// Used when asset catalog images are not available.
    private static func createPlaceholderImage(color: UIColor, label: String) -> UIImage {
        let size = CGSize(width: 1024, height: 768)
        let renderer = UIGraphicsImageRenderer(size: size)

        return renderer.image { ctx in
            color.setFill()
            ctx.fill(CGRect(origin: .zero, size: size))

            let paragraphStyle = NSMutableParagraphStyle()
            paragraphStyle.alignment = .center

            let attrs: [NSAttributedString.Key: Any] = [
                .font: UIFont.systemFont(ofSize: 48, weight: .bold),
                .foregroundColor: UIColor.white,
                .paragraphStyle: paragraphStyle
            ]

            let text = NSAttributedString(string: "📷 \(label)", attributes: attrs)
            let textSize = text.size()
            let rect = CGRect(
                x: (size.width - textSize.width) / 2,
                y: (size.height - textSize.height) / 2,
                width: textSize.width,
                height: textSize.height
            )
            text.draw(in: rect)
        }
    }
}
#endif
