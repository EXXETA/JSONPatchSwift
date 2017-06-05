//
//  Operaton.swift
//  Pods
//
//  Created by Maximilian Alexander on 6/4/17.
//
//


import SwiftyJSON

public func == (lhs: Operation, rhs: Operation) -> Bool {
    return lhs.type == rhs.type
}

/// RFC 6902 compliant JavaScript Object Notation (JSON) Patch operation implementation, see https://tools.ietf.org/html/rfc6902#page-4.
public struct Operation {
    
    /// Operation types as stated in https://tools.ietf.org/html/rfc6902#page-4.
    public enum OperationType: String {
        /** Add: The `add` operation. */
        case add = "add"
        /** Remove: The `remove` operation. */
        case remove = "remove"
        /** Replace: The `replace` operation. */
        case replace = "replace"
        /** Move: The `move` operation. */
        case move = "move"
        /** Copy: The `copy` operation. */
        case copy = "copy"
        /** Test: The `test` operation. */
        case test = "test"
    }
    
    public let type: OperationType
    public let pointer: JsonPointer
    public let value: JSON
    public let from: JsonPointer?
}
