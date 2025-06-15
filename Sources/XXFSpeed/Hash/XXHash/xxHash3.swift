//
//  xxHash3.swift
//
//
//  Created by xxf  28/08/2023.
//

import Foundation
import XXFXXHash

public final class xxHash3: xxHash3Common {
    private let state: OpaquePointer!

    public typealias Hash = UInt64

    public init(seed: UInt64? = nil, secret: Data? = nil) throws {
        state = XXH_INLINE_XXH3_createState()
        try reset(seed: seed, secret: secret)
    }

    public func reset(seed: UInt64? = nil, secretBuf: UnsafeRawBufferPointer? = nil) throws {
        let result = {
            if let sec = secretBuf, let seed = seed {
                return XXH_INLINE_XXH3_64bits_reset_withSecretandSeed(state, sec.baseAddress,
                                                                      sec.count, seed)
            } else if let sec = secretBuf {
                return XXH_INLINE_XXH3_64bits_reset_withSecret(state, sec.baseAddress,
                                                               sec.count)
            } else if let seed = seed {
                return XXH_INLINE_XXH3_64bits_reset_withSeed(state, seed)
            } else {
                return XXH_INLINE_XXH3_64bits_reset(state)
            }
        }()
        guard result == XXH_NAMESPACEXXH_OK else { throw xxHashError() }
    }

    public func update(_ buffer: UnsafeRawBufferPointer) throws {
        guard XXH_INLINE_XXH3_64bits_update(state, buffer.baseAddress,
                                            buffer.count) == XXH_NAMESPACEXXH_OK
        else { throw xxHashError() }
    }

    public func digest() -> UInt64 {
        XXH_INLINE_XXH3_64bits_digest(state)
    }

    @inlinable
    public static func canonical(hash: UInt64) -> [UInt8] {
        var canonical = XXH_NAMESPACEXXH64_canonical_t()
        XXH_INLINE_XXH64_canonicalFromHash(&canonical, hash)
        return [canonical.digest.0, canonical.digest.1, canonical.digest.2, canonical.digest.3,
                canonical.digest.4, canonical.digest.5, canonical.digest.6, canonical.digest.7]
    }

    @inlinable
    public static func hash(canonical hash: [UInt8]) throws -> UInt64 {
        guard hash.count == 8 else { throw xxHashError() }
        var canonical = XXH_NAMESPACEXXH64_canonical_t(
            digest: (hash[0], hash[1], hash[2], hash[3], hash[4], hash[5], hash[6], hash[7])
        )
        return XXH_INLINE_XXH64_hashFromCanonical(&canonical)
    }

    @inlinable
    public static func hash(_ buffer: UnsafeRawBufferPointer, seed: UInt64?,
                            secretBuf: UnsafeRawBufferPointer?) -> UInt64
    {
        if let seed = seed, let sec = secretBuf {
            return XXH_INLINE_XXH3_64bits_withSecretandSeed(buffer.baseAddress, buffer.count,
                                                            sec.baseAddress, sec.count,
                                                            seed)
        } else if let sec = secretBuf {
            return XXH_INLINE_XXH3_64bits_withSecret(buffer.baseAddress, buffer.count,
                                                     sec.baseAddress, sec.count)
        } else if let seed = seed {
            return XXH_INLINE_XXH3_64bits_withSeed(buffer.baseAddress, buffer.count, seed)
        } else {
            return XXH_INLINE_XXH3_64bits(buffer.baseAddress, buffer.count)
        }
    }

    deinit {
        XXH_INLINE_XXH3_freeState(state)
    }
}
