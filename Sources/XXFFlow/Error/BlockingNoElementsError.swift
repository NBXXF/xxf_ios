//
//  BlockingNoElementsError.swift
//  xxf_ios
//
//  Created by trl on 9/14.
//
import XXFFoundation

public class BlockingNoElementsError: AppError, @unchecked Sendable {
    public init() {
        super.init("Flow did not emit a value")
    }
}
