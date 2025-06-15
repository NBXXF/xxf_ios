//
//  xxHash32.swift
//
//
//  Created by xxf  28/08/2023.
//

import Foundation
import XXFXXHash

public struct xxHash32: xxHash2Common {
    private var state: XXH_NAMESPACEXXH32_state_t

    public typealias Hash = UInt32

    public init(seed: UInt32) throws {
        state = .init()
        try reset(seed: seed)
    }

    public mutating func reset(seed: UInt32) throws {
        guard XXH_INLINE_XXH32_reset(&state, seed) == XXH_NAMESPACEXXH_OK else {
            throw xxHashError()
        }
    }

    public mutating func update(_ buffer: UnsafeRawBufferPointer) throws {
        guard XXH_INLINE_XXH32_update(&state, buffer.baseAddress,
                                      buffer.count) == XXH_NAMESPACEXXH_OK
        else {
            throw xxHashError()
        }
    }

    public func digest() -> UInt32 {
        withUnsafePointer(to: state) { XXH_INLINE_XXH32_digest($0) }
    }

    public static func canonical(hash: UInt32) -> [UInt8] {
        var canonical = XXH_NAMESPACEXXH32_canonical_t()
        XXH_INLINE_XXH32_canonicalFromHash(&canonical, hash)
        return [canonical.digest.0, canonical.digest.1, canonical.digest.2, canonical.digest.3]
    }

    public static func hash(canonical hash: [UInt8]) throws -> UInt32 {
        guard hash.count == 4 else { throw xxHashError() }
        var canonical = XXH_NAMESPACEXXH32_canonical_t(digest: (hash[0], hash[1], hash[2], hash[3]))
        return XXH_INLINE_XXH32_hashFromCanonical(&canonical)
    }

    @inlinable
    public static func hash(_ buffer: UnsafeRawBufferPointer, seed: UInt32) -> UInt32 {
        XXH_INLINE_XXH32(buffer.baseAddress, buffer.count, seed)
    }
}
