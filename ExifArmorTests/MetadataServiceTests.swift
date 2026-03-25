import XCTest
import ImageIO
import CoreLocation
@testable import ExifArmor

/// Tests for MetadataService — EXIF extraction from image data.
final class MetadataServiceTests: XCTestCase {

    // MARK: - Helpers

    /// Create a minimal JPEG with embedded EXIF metadata for testing.
    private func makeTestImageData(
        gps: (lat: Double, lon: Double)? = nil,
        make: String? = nil,
        model: String? = nil,
        dateTime: String? = nil,
        software: String? = nil
    ) -> Data {
        // Create a 1x1 red pixel image
        let size = CGSize(width: 100, height: 100)
        let renderer = UIGraphicsImageRenderer(size: size)
        let image = renderer.image { ctx in
            UIColor.red.setFill()
            ctx.fill(CGRect(origin: .zero, size: size))
        }

        guard let baseData = image.jpegData(compressionQuality: 0.9),
              let source = CGImageSourceCreateWithData(baseData as CFData, nil),
              let uti = CGImageSourceGetType(source)
        else {
            return Data()
        }

        // Build metadata dictionaries
        var properties: [String: Any] = [:]

        if let gps {
            properties[kCGImagePropertyGPSDictionary as String] = [
                kCGImagePropertyGPSLatitude as String: abs(gps.lat),
                kCGImagePropertyGPSLatitudeRef as String: gps.lat >= 0 ? "N" : "S",
                kCGImagePropertyGPSLongitude as String: abs(gps.lon),
                kCGImagePropertyGPSLongitudeRef as String: gps.lon >= 0 ? "E" : "W",
                kCGImagePropertyGPSAltitude as String: 42.0,
            ]
        }

        var tiff: [String: Any] = [:]
        if let make { tiff[kCGImagePropertyTIFFMake as String] = make }
        if let model { tiff[kCGImagePropertyTIFFModel as String] = model }
        if let software { tiff[kCGImagePropertyTIFFSoftware as String] = software }
        if !tiff.isEmpty {
            properties[kCGImagePropertyTIFFDictionary as String] = tiff
        }

        var exif: [String: Any] = [:]
        if let dateTime { exif[kCGImagePropertyExifDateTimeOriginal as String] = dateTime }
        exif[kCGImagePropertyExifFocalLength as String] = 4.25
        exif[kCGImagePropertyExifFNumber as String] = 1.78
        exif[kCGImagePropertyExifExposureTime as String] = 0.008 // 1/125
        exif[kCGImagePropertyExifISOSpeedRatings as String] = [100.0]
        exif[kCGImagePropertyExifLensModel as String] = "iPhone 15 Pro back camera 6.765mm f/1.78"
        properties[kCGImagePropertyExifDictionary as String] = exif

        // Write image with metadata
        let destData = NSMutableData()
        guard let dest = CGImageDestinationCreateWithData(destData as CFMutableData, uti, 1, nil) else {
            return Data()
        }
        CGImageDestinationAddImageFromSource(dest, source, 0, properties as CFDictionary)
        CGImageDestinationFinalize(dest)

        return destData as Data
    }

    // MARK: - Extraction Tests

    func testExtractGPSCoordinates() {
        let data = makeTestImageData(gps: (lat: 37.7749, lon: -122.4194))
        let image = UIImage(data: data)!
        let meta = MetadataService.extractMetadata(from: data, image: image)

        XCTAssertTrue(meta.hasLocation)
        XCTAssertEqual(meta.latitude!, 37.7749, accuracy: 0.001)
        XCTAssertEqual(meta.longitude!, -122.4194, accuracy: 0.001)
        XCTAssertNotNil(meta.coordinate)
        XCTAssertNotNil(meta.altitude)
    }

    func testExtractSouthernHemisphereGPS() {
        let data = makeTestImageData(gps: (lat: -33.8688, lon: 151.2093))
        let image = UIImage(data: data)!
        let meta = MetadataService.extractMetadata(from: data, image: image)

        XCTAssertTrue(meta.hasLocation)
        XCTAssertEqual(meta.latitude!, -33.8688, accuracy: 0.001)
        XCTAssertEqual(meta.longitude!, 151.2093, accuracy: 0.001)
    }

    func testExtractDeviceInfo() {
        let data = makeTestImageData(make: "Apple", model: "iPhone 15 Pro", software: "17.4.1")
        let image = UIImage(data: data)!
        let meta = MetadataService.extractMetadata(from: data, image: image)

        XCTAssertTrue(meta.hasDeviceInfo)
        XCTAssertEqual(meta.deviceMake, "Apple")
        XCTAssertEqual(meta.deviceModel, "iPhone 15 Pro")
        XCTAssertEqual(meta.software, "17.4.1")
    }

    func testExtractDateTime() {
        let data = makeTestImageData(dateTime: "2024:03:15 14:23:07")
        let image = UIImage(data: data)!
        let meta = MetadataService.extractMetadata(from: data, image: image)

        XCTAssertTrue(meta.hasDateTime)
        XCTAssertEqual(meta.dateTimeOriginal, "2024:03:15 14:23:07")
    }

    func testExtractCameraSettings() {
        let data = makeTestImageData()
        let image = UIImage(data: data)!
        let meta = MetadataService.extractMetadata(from: data, image: image)

        XCTAssertNotNil(meta.focalLength)
        XCTAssertEqual(meta.focalLength!, 4.25, accuracy: 0.01)
        XCTAssertNotNil(meta.aperture)
        XCTAssertEqual(meta.aperture!, 1.78, accuracy: 0.01)
        XCTAssertNotNil(meta.exposureTime)
        XCTAssertNotNil(meta.iso)
        XCTAssertEqual(meta.iso!, 100, accuracy: 0.1)
        XCTAssertNotNil(meta.lensModel)
    }

    func testFormattedExposureTime() {
        let data = makeTestImageData()
        let image = UIImage(data: data)!
        let meta = MetadataService.extractMetadata(from: data, image: image)

        XCTAssertNotNil(meta.formattedExposureTime)
        XCTAssertTrue(meta.formattedExposureTime!.starts(with: "1/"))
    }

    func testPrivacyScore() {
        // Full metadata = high score
        let fullData = makeTestImageData(
            gps: (lat: 37.7749, lon: -122.4194),
            make: "Apple", model: "iPhone 15 Pro",
            dateTime: "2024:03:15 14:23:07",
            software: "17.4.1"
        )
        let fullMeta = MetadataService.extractMetadata(
            from: fullData, image: UIImage(data: fullData)!
        )
        XCTAssertGreaterThanOrEqual(fullMeta.privacyScore, 7)

        // No metadata = low score
        let renderer = UIGraphicsImageRenderer(size: CGSize(width: 10, height: 10))
        let blankImage = renderer.image { ctx in
            UIColor.blue.setFill()
            ctx.fill(CGRect(x: 0, y: 0, width: 10, height: 10))
        }
        let blankData = blankImage.pngData()!
        let blankMeta = MetadataService.extractMetadata(
            from: blankData, image: blankImage
        )
        XCTAssertLessThanOrEqual(blankMeta.privacyScore, 2)
    }

    func testExposedFieldCount() {
        let data = makeTestImageData(
            gps: (lat: 37.0, lon: -122.0),
            make: "Apple", model: "iPhone 15",
            dateTime: "2024:01:01 00:00:00",
            software: "17.0"
        )
        let image = UIImage(data: data)!
        let meta = MetadataService.extractMetadata(from: data, image: image)

        // GPS(1) + altitude(1) + make(1) + model(1) + software(1) + dateTime(1)
        // + focal(1) + aperture(1) + exposure(1) + iso(1) + lens(1) = 11+
        XCTAssertGreaterThanOrEqual(meta.exposedFieldCount, 8)
    }

    func testNoLocationWhenNoGPS() {
        let data = makeTestImageData(make: "Apple")
        let image = UIImage(data: data)!
        let meta = MetadataService.extractMetadata(from: data, image: image)

        XCTAssertFalse(meta.hasLocation)
        XCTAssertNil(meta.latitude)
        XCTAssertNil(meta.longitude)
        XCTAssertNil(meta.coordinate)
    }
}
