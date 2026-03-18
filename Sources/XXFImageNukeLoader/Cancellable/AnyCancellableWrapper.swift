#if os(iOS)
//
//  AnyCancellableWrapper.swift
//  xxf_ios
//
//  Created by xx on 8/19.
//
import Nuke
import XXFFoundation
import XXFImageLoader

final class AnyCancellableWrapper: XXFImageLoader.Cancellable, Nuke.Cancellable, @unchecked Sendable {
    private let _cancel: () -> Void
    init(_ cancellable: Nuke.Cancellable) {
        _cancel = cancellable.cancel
    }

    init(_ cancellable: XXFImageLoader.Cancellable) {
        _cancel = cancellable.cancel
    }

    func cancel() {
        _cancel()
    }
}
#endif
