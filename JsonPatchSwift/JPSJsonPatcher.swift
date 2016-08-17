//===----------------------------------------------------------------------===//
//
// This source file is part of the JSONPatchSwift open source project.
//
// Copyright (c) 2015 EXXETA AG
// Licensed under Apache License v2.0
//
//
//===----------------------------------------------------------------------===//

import SwiftyJSON

/// RFC 6902 compliant JSONPatch implementation.
public struct JPSJsonPatcher {

    /**
        Applies a given `JPSJsonPatch` to a `JSON`.

        - Parameter jsonPatch: the jsonPatch to apply
        - Parameter json: the json to apply the patch to

        - Throws: can throw any error from `JPSJsonPatcher.JPSJsonPatcherApplyError` to
            notify about failed operations.

        - Returns: A new `JSON` containing the given `JSON` with the patch applied.
    */
    public static func applyPatch(jsonPatch: JPSJsonPatch, toJson json: JSON) throws -> JSON {
        var tempJson = json
        for operation in jsonPatch.operations {
            switch operation.type {
            case .Add: tempJson = try JPSJsonPatcher.add(operation, toJson: tempJson)
            case .Remove: tempJson = try JPSJsonPatcher.remove(operation, toJson: tempJson)
            case .Replace: tempJson = try JPSJsonPatcher.replace(operation, toJson: tempJson)
            case .Move: tempJson = try JPSJsonPatcher.move(operation, toJson: tempJson)
            case .Copy: tempJson = try JPSJsonPatcher.copy(operation, toJson: tempJson)
            case .Test: tempJson = try JPSJsonPatcher.test(operation, toJson: tempJson)
            }
        }
        return tempJson
    }

    /// Possible errors thrown by the applyPatch function.
    public enum JPSJsonPatcherApplyError: ErrorType {
        /** ValidationError: `test` operation did not succeed. At least one tested parameter does not match the expected result. */
        case ValidationError(message: String?)
        /** ArrayIndexOutOfBounds: tried to add an element to an array position > array size + 1. See: http://tools.ietf.org/html/rfc6902#section-4.1 */
        case ArrayIndexOutOfBounds
        /** InvalidDictionaryKey: tried to remove a dictionary key that doesn't exist in the JSON dictionary */
        case InvalidDictionaryKey
        /** InvalidJson: invalid `JSON` provided. */
        case InvalidJson
    }
}


// MARK: - Private functions

extension JPSJsonPatcher {
    private static func add(operation: JPSOperation, toJson json: JSON) throws -> JSON {
        
        guard 0 < operation.pointer.pointerValue.count else {
            return operation.value
        }
        
        return try JPSJsonPatcher.applyOperation(json, pointer: operation.pointer) {
            (traversedJson, pointer) -> JSON in
            var newJson = traversedJson
            if var jsonAsDictionary = traversedJson.dictionaryObject, let key = pointer.pointerValue.first as? String {
                jsonAsDictionary[key] = operation.value.object
                newJson.object = jsonAsDictionary
            } else if var jsonAsArray = traversedJson.arrayObject, let indexString = pointer.pointerValue.first as? String, let index = Int(indexString) {
                guard 0 <= index && index <= jsonAsArray.count else {
                    throw JPSJsonPatcherApplyError.ArrayIndexOutOfBounds
                }
                jsonAsArray.insert(operation.value.object, atIndex: index)
                newJson.object = jsonAsArray
            }
            return newJson
        }
    }

    private static func remove(operation: JPSOperation, toJson json: JSON) throws -> JSON {
        return try JPSJsonPatcher.applyOperation(json, pointer: operation.pointer) {
            (traversedJson: JSON, pointer: JPSJsonPointer) in
            var newJson = traversedJson
            if var dictionary = traversedJson.dictionaryObject, let key = pointer.pointerValue.first as? String {
                guard dictionary.removeValueForKey(key) != nil else {
                    throw JPSJsonPatcherApplyError.InvalidDictionaryKey
                }
                newJson.object = dictionary
            }
            if var arr = traversedJson.arrayObject, let indexString = pointer.pointerValue.first as? String, let index = Int(indexString) {
                guard 0 <= index && index < arr.count else {
                    throw JPSJsonPatcherApplyError.ArrayIndexOutOfBounds
                }
                arr.removeAtIndex(index)
                newJson.object = arr
            }
            return newJson
        }
    }

    private static func replace(operation: JPSOperation, toJson json: JSON) throws -> JSON {
        return try JPSJsonPatcher.applyOperation(json, pointer: operation.pointer) {
            (traversedJson: JSON, pointer: JPSJsonPointer) in
            var newJson = traversedJson
            if var dictionary = traversedJson.dictionaryObject, let key = pointer.pointerValue.first as? String {
                // Target location must exist to be valid
                guard dictionary.keys.contains(key) else {
                    throw JPSJsonPatcherApplyError.InvalidDictionaryKey
                }
                dictionary[key] = operation.value.object
                newJson.object = dictionary
            }
            if var arr = traversedJson.arrayObject, let indexString = pointer.pointerValue.first as? String, let index = Int(indexString) {
                guard 0 <= index && index < arr.count else {
                    throw JPSJsonPatcherApplyError.ArrayIndexOutOfBounds
                }
                arr[index] = operation.value.object
                newJson.object = arr
            }
            return newJson
        }
    }
    
    private static func move(operation: JPSOperation, toJson json: JSON) throws -> JSON {
        var resultJson = json
        
        try JPSJsonPatcher.applyOperation(json, pointer: operation.from!) {
            (traversedJson: JSON, pointer: JPSJsonPointer) in
            
            // From: http://tools.ietf.org/html/rfc6902#section-4.3
            //    This operation is functionally identical to a "remove" operation for
            //    a value, followed immediately by an "add" operation at the same
            //    location with the replacement value.
            
            // remove
            let removeOperation = JPSOperation(type: JPSOperation.JPSOperationType.Remove, pointer: operation.from!, value: resultJson, from: operation.from)
            resultJson = try JPSJsonPatcher.remove(removeOperation, toJson: resultJson)
            
            // add
            var jsonToAdd = traversedJson[pointer.pointerValue]
            if traversedJson.type == .Array, let indexString = pointer.pointerValue.first as? String, let index = Int(indexString) {
                jsonToAdd = traversedJson[index]
            }
            let addOperation = JPSOperation(type: JPSOperation.JPSOperationType.Add, pointer: operation.pointer, value: jsonToAdd, from: operation.from)
            resultJson = try JPSJsonPatcher.add(addOperation, toJson: resultJson)
            
            return traversedJson
        }
        
        return resultJson
    }
    
    private static func copy(operation: JPSOperation, toJson json: JSON) throws -> JSON {
        var resultJson = json
        
        try JPSJsonPatcher.applyOperation(json, pointer: operation.from!) {
            (traversedJson: JSON, pointer: JPSJsonPointer) in
            var jsonToAdd = traversedJson[pointer.pointerValue]
            if traversedJson.type == .Array, let indexString = pointer.pointerValue.first as? String, let index = Int(indexString) {
                guard 0 <= index && index < traversedJson.count else {
                    throw JPSJsonPatcherApplyError.ArrayIndexOutOfBounds
                }
                jsonToAdd = traversedJson[index]
            }
            let addOperation = JPSOperation(type: JPSOperation.JPSOperationType.Add, pointer: operation.pointer, value: jsonToAdd, from: operation.from)
            resultJson = try JPSJsonPatcher.add(addOperation, toJson: resultJson)
            return traversedJson
        }
        
        return resultJson
        
    }
    
    private static func test(operation: JPSOperation, toJson json: JSON) throws -> JSON {
        return try JPSJsonPatcher.applyOperation(json, pointer: operation.pointer) {
            (traversedJson: JSON, pointer: JPSJsonPointer) in
            let jsonToValidate = traversedJson[pointer.pointerValue]
            guard jsonToValidate == operation.value else {
                throw JPSJsonPatcherApplyError.ValidationError(message: JPSConstants.JsonPatch.ErrorMessages.ValidationError)
            }
            return traversedJson
        }
    }
    
    private static func applyOperation(json: JSON?, pointer: JPSJsonPointer, operation: ((JSON, JPSJsonPointer) throws -> JSON)) throws -> JSON {
        guard let newJson = json else {
            throw JPSJsonPatcherApplyError.InvalidJson
        }
        if pointer.pointerValue.count == 1 {
            return try operation(newJson, pointer)
        } else {
            if var arr = newJson.array, let indexString = pointer.pointerValue.first as? String, let index = Int(indexString) {
                arr[index] = try applyOperation(arr[index], pointer: JPSJsonPointer.traverse(pointer), operation: operation)
                return JSON(arr)
            }
            if var dictionary = newJson.dictionary, let key = pointer.pointerValue.first as? String {
                dictionary[key] = try applyOperation(dictionary[key], pointer: JPSJsonPointer.traverse(pointer), operation: operation)
                return JSON(dictionary)
            }
        }
        return newJson
    }
    
}
