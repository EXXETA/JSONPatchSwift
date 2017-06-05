//
//  JsonPatcher.swift
//  Pods
//
//  Created by Maximilian Alexander on 6/4/17.
//
//

import SwiftyJSON

/// RFC 6902 compliant JSONPatch implementation.
public struct JsonPatcher {
    
    /**
     Applies a given `JsonPatch` to a `JSON`.
     
     - Parameter jsonPatch: the jsonPatch to apply
     - Parameter json: the json to apply the patch to
     
     - Throws: can throw any error from `JsonPatcher.JsonPatcherApplyError` to
     notify about failed operations.
     
     - Returns: A new `JSON` containing the given `JSON` with the patch applied.
     */
    public static func applyPatch(jsonPatch: JsonPatch, toJson json: JSON) throws -> JSON {
        var tempJson = json
        for operation in jsonPatch.operations {
            switch operation.type {
            case .add: tempJson = try JsonPatcher.add(operation: operation, toJson: tempJson)
            case .remove: tempJson = try JsonPatcher.remove(operation: operation, toJson: tempJson)
            case .replace: tempJson = try JsonPatcher.replace(operation: operation, toJson: tempJson)
            case .move: tempJson = try JsonPatcher.move(operation: operation, toJson: tempJson)
            case .copy: tempJson = try JsonPatcher.copy(operation: operation, toJson: tempJson)
            case .test: tempJson = try JsonPatcher.test(operation: operation, toJson: tempJson)
            }
        }
        return tempJson
    }
    
    /// Possible errors thrown by the applyPatch function.
    public enum JsonPatcherApplyError: Error {
        /** ValidationError: `test` operation did not succeed. At least one tested parameter does not match the expected result. */
        case ValidationError(message: String?)
        /** ArrayIndexOutOfBounds: tried to add an element to an array position > array size + 1. See: http://tools.ietf.org/html/rfc6902#section-4.1 */
        case ArrayIndexOutOfBounds
        /** InvalidJson: invalid `JSON` provided. */
        case InvalidJson
    }
}


// MARK: - Private functions

extension JsonPatcher {
    fileprivate static func add(operation: Operation, toJson json: JSON) throws -> JSON {
        
        guard 0 < operation.pointer.pointerValue.count else {
            return operation.value
        }
        
        return try JsonPatcher.applyOperation(json: json, pointer: operation.pointer) {
            (traversedJson, pointer) -> JSON in
            var newJson = traversedJson
            if var jsonAsDictionary = traversedJson.dictionaryObject, let key = pointer.pointerValue.first as? String {
                jsonAsDictionary[key] = operation.value.object
                newJson.object = jsonAsDictionary
            } else if var jsonAsArray = traversedJson.arrayObject, let indexString = pointer.pointerValue.first as? String, let index = Int(indexString) {
                guard index <= jsonAsArray.count else {
                    throw JsonPatcherApplyError.ArrayIndexOutOfBounds
                }
                jsonAsArray.insert(operation.value.object, at: index)
                newJson.object = jsonAsArray
            }
            return newJson
        }
    }
    
    fileprivate static func remove(operation: Operation, toJson json: JSON) throws -> JSON {
        return try JsonPatcher.applyOperation(json: json, pointer: operation.pointer) {
            (traversedJson: JSON, pointer: JsonPointer) in
            var newJson = traversedJson
            if var dictionary = traversedJson.dictionaryObject, let key = pointer.pointerValue.first as? String {
                dictionary.removeValue(forKey: key)
                newJson.object = dictionary
            }
            if var arr = traversedJson.arrayObject, let indexString = pointer.pointerValue.first as? String, let index = Int(indexString) {
                arr.remove(at: index)
                newJson.object = arr
            }
            return newJson
        }
    }
    
    fileprivate static func replace(operation: Operation, toJson json: JSON) throws -> JSON {
        return try JsonPatcher.applyOperation(json: json, pointer: operation.pointer) {
            (traversedJson: JSON, pointer: JsonPointer) in
            var newJson = traversedJson
            if var dictionary = traversedJson.dictionaryObject, let key = pointer.pointerValue.first as? String {
                dictionary[key] = operation.value.object
                newJson.object = dictionary
            }
            if var arr = traversedJson.arrayObject, let indexString = pointer.pointerValue.first as? String, let index = Int(indexString) {
                arr[index] = operation.value.object
                newJson.object = arr
            }
            return newJson
        }
    }
    
    fileprivate static func move(operation: Operation, toJson json: JSON) throws -> JSON {
        var resultJson = json
        
        try JsonPatcher.applyOperation(json: json, pointer: operation.from!) {
            (traversedJson: JSON, pointer: JsonPointer) in
            
            // From: http://tools.ietf.org/html/rfc6902#section-4.3
            //    This operation is functionally identical to a "remove" operation for
            //    a value, followed immediately by an "add" operation at the same
            //    location with the replacement value.
            
            // remove
            let removeOperation = Operation(type: Operation.OperationType.remove, pointer: operation.from!, value: resultJson, from: operation.from)
            resultJson = try JsonPatcher.remove(operation: removeOperation, toJson: resultJson)
            
            // add
            var jsonToAdd = traversedJson[pointer.pointerValue]
            if traversedJson.type == .array, let indexString = pointer.pointerValue.first as? String, let index = Int(indexString) {
                jsonToAdd = traversedJson[index]
            }
            let addOperation = Operation(type: Operation.OperationType.add, pointer: operation.pointer, value: jsonToAdd, from: operation.from)
            resultJson = try JsonPatcher.add(operation: addOperation, toJson: resultJson)
            
            return traversedJson
        }
        
        return resultJson
    }
    
    fileprivate static func copy(operation: Operation, toJson json: JSON) throws -> JSON {
        var resultJson = json
        
        try JsonPatcher.applyOperation(json: json, pointer: operation.from!) {
            (traversedJson: JSON, pointer: JsonPointer) in
            var jsonToAdd = traversedJson[pointer.pointerValue]
            if traversedJson.type == .array, let indexString = pointer.pointerValue.first as? String, let index = Int(indexString) {
                jsonToAdd = traversedJson[index]
            }
            let addOperation = Operation(type: Operation.OperationType.add, pointer: operation.pointer, value: jsonToAdd, from: operation.from)
            resultJson = try JsonPatcher.add(operation: addOperation, toJson: resultJson)
            return traversedJson
        }
        
        return resultJson
        
    }
    
    fileprivate static func test(operation: Operation, toJson json: JSON) throws -> JSON {
        return try JsonPatcher.applyOperation(json: json, pointer: operation.pointer) {
            (traversedJson: JSON, pointer: JsonPointer) in
            let jsonToValidate = traversedJson[pointer.pointerValue]
            guard jsonToValidate == operation.value else {
                throw JsonPatcherApplyError.ValidationError(message: Constants.JsonPatch.ErrorMessages.ValidationError)
            }
            return traversedJson
        }
    }
    
    @discardableResult
    fileprivate static func applyOperation(json: JSON?, pointer: JsonPointer, operation: ((JSON, JsonPointer) throws -> JSON)) throws -> JSON {
        guard let newJson = json else {
            throw JsonPatcherApplyError.InvalidJson
        }
        if pointer.pointerValue.count == 1 {
            return try operation(newJson, pointer)
        } else {
            if var arr = newJson.array, let indexString = pointer.pointerValue.first as? String, let index = Int(indexString) {
                arr[index] = try applyOperation(json: arr[index], pointer: JsonPointer.traverse(pointer: pointer), operation: operation)
                return JSON(arr)
            }
            if var dictionary = newJson.dictionary, let key = pointer.pointerValue.first as? String {
                dictionary[key] = try applyOperation(json: dictionary[key], pointer: JsonPointer.traverse(pointer: pointer), operation: operation)
                return JSON(dictionary)
            }
        }
        return newJson
    }
    
}
