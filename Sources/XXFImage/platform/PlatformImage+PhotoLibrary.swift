//
//  PlatformImage+PhotoLibrary.swift
//  xxf_ios
//
//  Created by xxf on 5/8.
//

#if os(macOS)
    import AppKit
#else
    import Photos
    import UIKit
#endif

// MARK: - Export

public extension PlatformImage {
    #if os(iOS)
        enum PhotoLibrarySaveError: LocalizedError, Sendable {
            case unsupportedPlatform
            case permissionDenied
            case permissionRestricted
            case invalidImageData
            case saveFailed(underlying: Error?)

            public var errorDescription: String? {
                switch self {
                case .unsupportedPlatform:
                    return "Saving to photo library is not supported on this platform."
                case .permissionDenied:
                    return "Photo library permission is denied."
                case .permissionRestricted:
                    return "Photo library permission is restricted."
                case .invalidImageData:
                    return "Unable to encode image data for saving."
                case .saveFailed(let underlying):
                    return underlying?.localizedDescription ?? "Failed to save image to photo library."
                }
            }
        }

        typealias PhotoLibrarySaveCompletion = (Result<String, PhotoLibrarySaveError>) -> Void

        /// Returns current photo library authorization status for a given access level.
        /// - Parameter accessLevel: Photo library access level. Defaults to `.addOnly`.
        /// - Returns: Current authorization status.
        static func photoLibraryAuthorizationStatus(accessLevel: PHAccessLevel = .addOnly) -> PHAuthorizationStatus {
            PHPhotoLibrary.authorizationStatus(for: accessLevel)
        }

        /// Requests photo library authorization.
        /// - Parameters:
        ///   - accessLevel: Photo library access level. Defaults to `.addOnly`.
        ///   - callbackQueue: Queue used to invoke completion. Defaults to `.main`.
        ///   - completion: Called on `callbackQueue` with authorization status.
        static func requestPhotoLibraryAuthorization(
            accessLevel: PHAccessLevel = .addOnly,
            callbackQueue: DispatchQueue = .main,
            completion: @escaping (PHAuthorizationStatus) -> Void
        ) {
            PHPhotoLibrary.requestAuthorization(for: accessLevel) { status in
                Self.dispatch(to: callbackQueue) {
                    completion(status)
                }
            }
        }

        /// Ensures the app has permission to add assets to photo library.
        /// - Parameters:
        ///   - accessLevel: Photo library access level. Defaults to `.addOnly`.
        ///   - callbackQueue: Queue used to invoke completion. Defaults to `.main`.
        ///   - completion: Called on `callbackQueue` with permission result.
        static func ensurePhotoLibraryAddPermission(
            accessLevel: PHAccessLevel = .addOnly,
            callbackQueue: DispatchQueue = .main,
            completion: @escaping (Result<Void, PhotoLibrarySaveError>) -> Void
        ) {
            let status = photoLibraryAuthorizationStatus(accessLevel: accessLevel)
            switch status {
            case .authorized, .limited:
                dispatch(to: callbackQueue) {
                    completion(.success(()))
                }
            case .denied:
                dispatch(to: callbackQueue) {
                    completion(.failure(.permissionDenied))
                }
            case .restricted:
                dispatch(to: callbackQueue) {
                    completion(.failure(.permissionRestricted))
                }
            case .notDetermined:
                requestPhotoLibraryAuthorization(accessLevel: accessLevel, callbackQueue: callbackQueue) { requestedStatus in
                    switch requestedStatus {
                    case .authorized, .limited:
                        completion(.success(()))
                    case .restricted:
                        completion(.failure(.permissionRestricted))
                    case .denied, .notDetermined:
                        completion(.failure(.permissionDenied))
                    @unknown default:
                        completion(.failure(.permissionDenied))
                    }
                }
            @unknown default:
                dispatch(to: callbackQueue) {
                    completion(.failure(.permissionDenied))
                }
            }
        }

        /// Saves image to photo library.
        /// - Parameters:
        ///   - accessLevel: Photo library access level. Defaults to `.addOnly`.
        ///   - callbackQueue: Queue used to invoke completion. Defaults to `.main`.
        ///   - completion: Called on `callbackQueue` with saved asset local identifier on success.
        func saveToPhotoLibrary(
            accessLevel: PHAccessLevel = .addOnly,
            callbackQueue: DispatchQueue = .main,
            completion: @escaping PhotoLibrarySaveCompletion
        ) {
            let status = Self.photoLibraryAuthorizationStatus(accessLevel: accessLevel)
            switch status {
            case .notDetermined:
                Self.requestPhotoLibraryAuthorization(accessLevel: accessLevel, callbackQueue: callbackQueue) { requestedStatus in
                    self.handleAuthorizedSave(status: requestedStatus, callbackQueue: callbackQueue, completion: completion)
                }
            default:
                handleAuthorizedSave(status: status, callbackQueue: callbackQueue, completion: completion)
            }
        }

        private func handleAuthorizedSave(
            status: PHAuthorizationStatus,
            callbackQueue: DispatchQueue,
            completion: @escaping PhotoLibrarySaveCompletion
        ) {
            switch status {
            case .authorized, .limited:
                guard let imageData = pngData() ?? jpegData(compressionQuality: 1.0) else {
                    Self.dispatch(to: callbackQueue) {
                        completion(.failure(.invalidImageData))
                    }
                    return
                }

                let identifierHolder = LocalIdentifierHolder()
                PHPhotoLibrary.shared().performChanges {
                    let request = PHAssetCreationRequest.forAsset()
                    let options = PHAssetResourceCreationOptions()
                    options.shouldMoveFile = false
                    request.addResource(with: .photo, data: imageData, options: options)
                    identifierHolder.value = request.placeholderForCreatedAsset?.localIdentifier
                } completionHandler: { isSuccess, error in
                    Self.dispatch(to: callbackQueue) {
                        if let error {
                            completion(.failure(.saveFailed(underlying: error)))
                            return
                        }
                        if isSuccess, let localIdentifier = identifierHolder.value {
                            completion(.success(localIdentifier))
                        } else {
                            completion(.failure(.saveFailed(underlying: nil)))
                        }
                    }
                }
            case .denied:
                Self.dispatch(to: callbackQueue) {
                    completion(.failure(.permissionDenied))
                }
            case .restricted:
                Self.dispatch(to: callbackQueue) {
                    completion(.failure(.permissionRestricted))
                }
            case .notDetermined:
                Self.dispatch(to: callbackQueue) {
                    completion(.failure(.permissionDenied))
                }
            @unknown default:
                Self.dispatch(to: callbackQueue) {
                    completion(.failure(.permissionDenied))
                }
            }
        }

        private static func dispatch(to queue: DispatchQueue, _ block: @escaping () -> Void) {
            if queue == .main {
                if Thread.isMainThread {
                    block()
                } else {
                    DispatchQueue.main.async(execute: block)
                }
            } else {
                queue.async(execute: block)
            }
        }
    #else
        enum PhotoLibrarySaveError: LocalizedError, Sendable {
            case unsupportedPlatform

            public var errorDescription: String? {
                "Saving to photo library is not supported on this platform."
            }
        }
    #endif
}

#if os(iOS)

    /// 跨 `PHPhotoLibrary.performChanges` 两段闭包传递新创建资产 `localIdentifier` 的中转容器。
    ///
    /// Photos 框架保证 `completionHandler` 在 `changeBlock` 执行完成之后才会被调用,
    /// 因此跨闭包读写 `value` 不存在真实的数据竞争;使用 `@unchecked Sendable` 绕过
    /// Swift 6 对捕获变量的 Sendable 检查。
    private final class LocalIdentifierHolder: @unchecked Sendable {
        /// 新创建资产的 `localIdentifier`;`performChanges` 的 changeBlock 成功时写入,
        /// completionHandler 在成功路径读取。未成功或未写入时保持为 nil。
        var value: String?
    }

#endif
