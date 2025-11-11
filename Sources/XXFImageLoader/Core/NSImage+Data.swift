//
//  NSImage+Data.swift
//  xxf_ios
//  图片转data
//  Created by xxf on 8/19.
//

import AppKit
import XXFImage

public extension NSImage {
    private func _imageScale() -> Double {
        let scale = NSScreen.main?.backingScaleFactor ?? 2.0
        return scale
    }

    func toPNGData() -> Data? {
        let data = try? representation.png(scale: _imageScale())
        return data
    }

    func toJPEGData(compression _: CGFloat = 0.65) -> Data? {
        let data = try? representation.jpeg(scale: _imageScale(), compression: 0.65, excludeGPSData: true)
        return data
    }

    func toPDFData(size: CGSize) -> Data? {
        let data = try? representation.pdf(size: size)
        return data
    }
}
