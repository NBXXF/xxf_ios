//
//  xxHash64.swift
//
//
//  Created by xxf  28/08/2023.
//

import Foundation
import XXFXXHash

public struct xxHash64: xxHash2Common {
    private var state: XXH_NAMESPACEXXH64_state_t

    public typealias Hash = UInt64

    public init(seed: UInt64) throws {
        state = .init()
        try reset(seed: seed)
    }

    public mutating func reset(seed: UInt64) throws {
        guard XXH_INLINE_XXH64_reset(&state, seed) == XXH_NAMESPACEXXH_OK else {
            throw xxHashError()
        }
    }

    public mutating func update(_ buffer: UnsafeRawBufferPointer) throws {
        guard XXH_INLINE_XXH64_update(&state, buffer.baseAddress,
                                      buffer.count) == XXH_NAMESPACEXXH_OK
        else {
            throw xxHashError()
        }
    }

    public func digest() -> UInt64 {
        withUnsafePointer(to: state) { XXH_INLINE_XXH64_digest($0) }
    }

    public static func canonical(hash: UInt64) -> [UInt8] {
        var canonical = XXH_NAMESPACEXXH64_canonical_t()
        XXH_INLINE_XXH64_canonicalFromHash(&canonical, hash)
        return [canonical.digest.0, canonical.digest.1, canonical.digest.2, canonical.digest.3,
                canonical.digest.4, canonical.digest.5, canonical.digest.6, canonical.digest.7]
    }

    public static func hash(canonical hash: [UInt8]) throws -> UInt64 {
        guard hash.count == 8 else { throw xxHashError() }
        var canonical = XXH_NAMESPACEXXH64_canonical_t(
            digest: (hash[0], hash[1], hash[2], hash[3], hash[4], hash[5], hash[6], hash[7])
        )
        return XXH_INLINE_XXH64_hashFromCanonical(&canonical)
    }

    public static func hash(_ buffer: UnsafeRawBufferPointer, seed: UInt64) -> UInt64 {
        XXH_INLINE_XXH64(buffer.baseAddress, buffer.count, seed)
    }
}
