//
//  BlockingNoElementsError.swift
//  xxf_ios
//
//  Created by xxf on 9/14.
//
import XXFFoundation

public class BlockingNoElementsError: AppError, @unchecked Sendable {
    public init() {
        super.init("Flow did not emit a value")
    }
}
