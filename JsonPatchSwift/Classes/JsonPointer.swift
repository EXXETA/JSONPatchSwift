//
//  JsonPointer.swift
//  Pods
//
//  Created by Maximilian Alexander on 6/4/17.
//
//

import SwiftyJSON

/// Possible errors thrown by the applyPatch function.
public enum JsonPointerError: Error {
    /** ValueDoesNotContainDelimiter: JSON pointer values are delimited by a delimiter character, see https://tools.ietf.org/html/rfc6901#page-2. */
    case ValueDoesNotContainDelimiter
    /** NonEmptyPointerDoesNotStartWithDelimiter: A JSON pointer must start with a delimiter character, see https://tools.ietf.org/html/rfc6901#page-2. */
    case NonEmptyPointerDoesNotStartWithDelimiter
    /** ContainsEmptyReferenceToken: Every reference token in a JSON pointer must not be empty, see https://tools.ietf.org/html/rfc6901#page-2. */
    case ContainsEmptyReferenceToken
}

/// RFC 6901 compliant JavaScript Object Notation (JSON) Pointer implementation.
public struct JsonPointer {
    
    public let rawValue: String
    public let pointerValue: [JSONSubscriptType]
    
}

extension JsonPointer {
    
    /**
     Initializes a new `JPSJsonPointer` based on a given String representation.
     
     - Parameter rawValue: A String representing a valid JSON pointer, see https://tools.ietf.org/html/rfc6901.
     
     - Throws: can throw any error from `JPSJsonPointer.JPSJsonPointerError` to notify failed initialization.
     
     - Returns: a `JPSJsonPointer` representation of the given JSON pointer string.
     */
    public init(rawValue: String) throws {
        
        guard rawValue.isEmpty || rawValue.contains(Constants.JsonPointer.Delimiter) else {
            throw JsonPointerError.ValueDoesNotContainDelimiter
        }
        guard rawValue.isEmpty || rawValue.hasPrefix(Constants.JsonPointer.Delimiter) else {
            throw JsonPointerError.NonEmptyPointerDoesNotStartWithDelimiter
        }
        
        let pointerValueWithoutFirstElement = Array(rawValue.components(separatedBy: Constants.JsonPointer.Delimiter).dropFirst())
        
        guard rawValue.isEmpty || !pointerValueWithoutFirstElement.contains(Constants.JsonPointer.EmptyString) else {
            throw JsonPointerError.ContainsEmptyReferenceToken
        }
        
        let pointerValueAfterDecodingDelimiter = pointerValueWithoutFirstElement.map { $0.replacingOccurrences(of: Constants.JsonPointer.EscapedDelimiter, with: Constants.JsonPointer.Delimiter) }
        let pointerValue: [JSONSubscriptType] = pointerValueAfterDecodingDelimiter.map { $0.replacingOccurrences(of: Constants.JsonPointer.EscapedEscapeCharacter, with: Constants.JsonPointer.EscapeCharacter)}
        
        self.init(rawValue: rawValue, pointerValue: pointerValue)
    }
    
}

extension JsonPointer {
    public static func traverse(pointer: JsonPointer) -> JsonPointer {
        let pointerValueWithoutFirstElement = Array(pointer.rawValue.components(separatedBy: Constants.JsonPointer.Delimiter).dropFirst().dropFirst()).joined(separator: Constants.JsonPointer.Delimiter)
        // swiftlint:disable force_try
        return try! JsonPointer(rawValue: Constants.JsonPointer.Delimiter + pointerValueWithoutFirstElement)
        // swiftlint:enable force_try
    }
}
