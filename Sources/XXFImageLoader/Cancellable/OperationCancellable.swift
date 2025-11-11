//
//  OperationCancellable.swift
//  xxf_ios
//
//  Created by xxf on 8/20.
//

import Foundation

public final class OperationCancellable: Cancellable {
    public let operation: Operation
    public init(_ operation: Operation) { self.operation = operation }
    public func cancel() { operation.cancel() }
}
