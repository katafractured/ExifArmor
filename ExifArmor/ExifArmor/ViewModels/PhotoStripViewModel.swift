import Foundation
import Photos
import PhotosUI
import SwiftUI
import UIKit

/// Drives the core workflow: pick → analyze → preview → strip → save/share.
@Observable
final class PhotoStripViewModel {

    private enum Keys {
        static let defaultStripMode = "defaultStripMode"
    }

    // MARK: - State

    enum Phase {
        case idle
        case loading
        case preview
        case stripping
        case done
        case error(String)
    }

    var phase: Phase = .idle
    var selectedItems: [PhotosPickerItem] = []
    var analyzedPhotos: [PhotoMetadata] = []
    var stripResults: [StripResult] = []
    var stripOptions: StripOptions = .all
    var showStripOptions: Bool = false

    // Batch progress
    var processedCount: Int = 0
    var totalCount: Int = 0

    // MARK: - Load Selected Photos

    /// Load image data from PhotosPicker selections and extract metadata.
    func loadSelectedPhotos() async {
        guard !selectedItems.isEmpty else { return }

        await MainActor.run {
            phase = .loading
            analyzedPhotos = []
            stripResults = []
            processedCount = 0
            totalCount = selectedItems.count
        }

        var results: [PhotoMetadata] = []

        for item in selectedItems {
            do {
                guard let data = try await item.loadTransferable(type: Data.self),
                      let image = UIImage(data: data)
                else { continue }

                let metadata = MetadataService.extractMetadata(from: data, image: image)
                results.append(metadata)
            } catch {
                // Skip photos that fail to load
                continue
            }

            await MainActor.run {
                processedCount += 1
            }
        }

        await MainActor.run {
            analyzedPhotos = results
            phase = results.isEmpty ? .error("Could not load any photos") : .preview
        }
    }

    // MARK: - Strip Metadata

    func stripAll() async {
        await MainActor.run {
            phase = .stripping
            stripResults = []
            processedCount = 0
            totalCount = analyzedPhotos.count
        }

        var results: [StripResult] = []

        for metadata in analyzedPhotos {
            let fieldsToRemove = StripService.countFieldsToRemove(
                from: metadata, options: stripOptions
            )

            if let cleanedData = StripService.stripMetadata(
                from: metadata.imageData, options: stripOptions
            ),
               let cleanedImage = UIImage(data: cleanedData) {

                let result = StripResult(
                    originalMetadata: metadata,
                    cleanedImageData: cleanedData,
                    cleanedImage: cleanedImage,
                    fieldsRemoved: fieldsToRemove
                )
                results.append(result)
            }

            await MainActor.run {
                processedCount += 1
            }
        }

        await MainActor.run {
            stripResults = results
            phase = results.isEmpty ? .error("Failed to strip photos") : .done
        }
    }

    // MARK: - Save to Photo Library

    func saveAllToPhotoLibrary() async -> Bool {
        do {
            for result in stripResults {
                try await saveToPhotoLibrary(data: result.cleanedImageData)
            }
            return true
        } catch {
            await MainActor.run {
                phase = .error("Failed to save: \(error.localizedDescription)")
            }
            return false
        }
    }

    private func saveToPhotoLibrary(data: Data) async throws {
        return try await withCheckedThrowingContinuation { continuation in
            PHPhotoLibrary.shared().performChanges({
                let request = PHAssetCreationRequest.forAsset()
                request.addResource(with: .photo, data: data, options: nil)
            }) { success, error in
                if let error {
                    continuation.resume(throwing: error)
                } else if success {
                    continuation.resume()
                } else {
                    continuation.resume(throwing: NSError(
                        domain: "ExifArmor",
                        code: -1,
                        userInfo: [NSLocalizedDescriptionKey: "Failed to save cleaned photo"]
                    ))
                }
            }
        }
    }

    // MARK: - Share

    /// Returns temp file URLs for the cleaned images so that all share destinations
    /// (Instagram, Facebook, Messages, Mail, etc.) can accept them.
    func shareItems() -> [Any] {
        let tmpDir = FileManager.default.temporaryDirectory
        return stripResults.compactMap { result -> URL? in
            let filename = "ExifArmor_\(UUID().uuidString.prefix(8)).jpg"
            let url = tmpDir.appendingPathComponent(filename)
            // Write as JPEG so every app can read it
            let data = result.cleanedImageData
            do {
                try data.write(to: url, options: .atomic)
                return url
            } catch {
                return nil
            }
        }
    }

    // MARK: - Reset

    func reset() {
        phase = .idle
        selectedItems = []
        analyzedPhotos = []
        stripResults = []
        processedCount = 0
        totalCount = 0
        applySavedDefaultStripMode()
    }

    // MARK: - Stats for this batch

    var totalFieldsRemoved: Int {
        stripResults.reduce(0) { $0 + $1.fieldsRemoved }
    }

    var hadLocationData: Bool {
        analyzedPhotos.contains { $0.hasLocation }
    }

    func applySavedDefaultStripMode() {
        stripOptions = stripOptions(for: UserDefaults.standard.string(forKey: Keys.defaultStripMode) ?? "all")
    }

    private func stripOptions(for mode: String) -> StripOptions {
        switch mode {
        case "location":
            return .locationOnly
        case "privacy":
            return .privacyFocused
        default:
            return .all
        }
    }
}
