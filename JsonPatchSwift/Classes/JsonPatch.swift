//
//  JsonPatch.swift
//  Pods
//
//  Created by Maximilian Alexander on 6/4/17.
//
//

import SwiftyJSON

public func == (lhs: JsonPatch, rhs: JsonPatch) -> Bool {
    
    guard lhs.operations.count == rhs.operations.count else { return false }
    
    for i in 0..<lhs.operations.count {
        if !(lhs.operations[i] == rhs.operations[i]) {
            return false
        }
    }
    
    return true
}

/// Representation of a JSON Patch
public struct JsonPatch {
    
    public let operations: [Operation]
    
    /**
     Initializes a new `JsonPatch` based on a given SwiftyJSON representation.
     - Parameter _: A String representing one or many JSON Patch operations.
     e.g. (1) JSON({ "op": "add", "path": "/", "value": "foo" })
     or (> 1)
     JSON([ { "op": "add", "path": "/", "value": "foo" },
     { "op": "test", "path": "/", "value": "foo } ])
     - Throws: can throw any error from `JsonPatch.JsonPatchInitialisationError` to
     notify failed initialization.
     - Returns: a `JsonPatch` representation of the given SwiftJSON object
     */
    public init(_ patch: JSON) throws {
        // Check if there is an array of a dictionary as root element. Both are valid JSON patch documents.
        if patch.type == .dictionary {
            self.operations = [try JsonPatch.extractOperationFromJson(json: patch)]
            
        } else if patch.type == .array {
            guard 0 < patch.count else {
                throw JsonPatchInitialisationError.InvalidPatchFormat(message: Constants.JsonPatch.InitialisationErrorMessages.PatchWithEmptyError)
            }
            var operationArray = [Operation]()
            for i in 0..<patch.count {
                let operation = patch[i]
                operationArray.append(try JsonPatch.extractOperationFromJson(json: operation))
            }
            self.operations = operationArray
            
        } else {
            // All other types are not a valid JSON Patch Operation.
            throw JsonPatchInitialisationError.InvalidPatchFormat(message: Constants.JsonPatch.InitialisationErrorMessages.InvalidRootElement)
        }
    }
    
    /**
     Initializes a new `JsonPatch` based on a given String representation.
     - parameter _: A String representing one or many JSON Patch operations.
     e.g. (1) { "op": "add", "path": "/", "value": "foo" }
     or (> 1)
     [ { "op": "add", "path": "/", "value": "foo" },
     { "op": "test", "path": "/", "value": "foo } ]
     - throws: can throw any error from `JsonPatch.JsonPatchInitialisationError` to notify failed initialization.
     - returns: a `JsonPatch` representation of the given JSON Patch String.
     */
    public init(_ patch: String) throws {
        // Convert the String to NSData
        let data = patch.data(using: String.Encoding.utf8)!
        
        // Parse the JSON
        var jsonError: NSError?
        let json = JSON(data: data, options: .allowFragments, error: &jsonError)
        if let actualError = jsonError {
            throw JsonPatchInitialisationError.InvalidJsonFormat(message: actualError.description)
        }
        
        try self.init(json)
    }
    
    /// Possible errors thrown by the init function.
    public enum JsonPatchInitialisationError: Error {
        /** InvalidJsonFormat: The given String is not a valid JSON. */
        case InvalidJsonFormat(message: String?)
        /** InvalidPatchFormat: The given Patch is invalid (e.g. missing mandatory parameters). See error message for details. */
        case InvalidPatchFormat(message: String?)
    }
}


// MARK: - Private functions
extension JsonPatch {
    
    fileprivate static func extractOperationFromJson(json: JSON) throws -> Operation {
        
        // The elements 'op' and 'path' are mandatory.
        guard let operation = json[Constants.JsonPatch.Parameter.Op].string else {
            throw JsonPatchInitialisationError.InvalidPatchFormat(message: Constants.JsonPatch.InitialisationErrorMessages.OpElementNotFound)
        }
        guard let path = json[Constants.JsonPatch.Parameter.Path].string else {
            throw JsonPatchInitialisationError.InvalidPatchFormat(message: Constants.JsonPatch.InitialisationErrorMessages.PathElementNotFound)
        }
        guard let operationType = Operation.OperationType(rawValue: operation) else {
            throw JsonPatchInitialisationError.InvalidPatchFormat(message: Constants.JsonPatch.InitialisationErrorMessages.InvalidOperation)
        }
        
        // 'from' element mandatory for .Move, .Copy operations
        var from: JsonPointer?
        if operationType == .move || operationType == .copy {
            guard let fromValue = json[Constants.JsonPatch.Parameter.From].string else {
                throw JsonPatchInitialisationError.InvalidPatchFormat(message: Constants.JsonPatch.InitialisationErrorMessages.FromElementNotFound)
            }
            from = try JsonPointer(rawValue: fromValue)
        }
        
        // 'value' element mandatory for .Add, .Replace operations
        let value = json[Constants.JsonPatch.Parameter.Value]
        // counterintuitive null check: https://github.com/SwiftyJSON/SwiftyJSON/issues/205
        if (operationType == .add || operationType == .replace) && value.null != nil {
            throw JsonPatchInitialisationError.InvalidPatchFormat(message: Constants.JsonPatch.InitialisationErrorMessages.ValueElementNotFound)
        }
        
        let pointer = try JsonPointer(rawValue: path)
        return Operation(type: operationType, pointer: pointer, value: value, from: from)
    }
    
}
