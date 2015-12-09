//
//  JPSJsonPatch.swift
//  JsonPatchSwift
//
//  Created by Dominic Frei on 08/12/2015.
//  Copyright © 2015 Dominic Frei. All rights reserved.
//

import SwiftyJSON

enum JPSJsonPatchInitialisationError: ErrorType {
    case InvalidJsonFormat(message: String?)
    case InvalidPatchFormat(message: String?)
    case UnexpectedError
}

struct JPSJsonPatch {
    
    let operations: [JPSOperation]
    
    init(_ patch: String) throws {
        guard let data = patch.dataUsingEncoding(NSUTF8StringEncoding) else {
            throw JPSJsonPatchInitialisationError.InvalidJsonFormat(message: "Could not encode patch.")
        }
        
        do {
            let json = try NSJSONSerialization.JSONObjectWithData(data, options: NSJSONReadingOptions.MutableContainers)
            if let json = json as? [String: AnyObject] {
                guard let operation = json["op"] as? String else {
                    throw JPSJsonPatchInitialisationError.InvalidPatchFormat(message: "Could not find 'op' element.")
                }
                switch JPSOperationType(rawValue: operation)! {
                case .Add: self.operations = [JPSOperation(type: JPSOperationType.Add)]
                case .Remove: self.operations = [JPSOperation(type: JPSOperationType.Remove)]
                case .Replace: self.operations = [JPSOperation(type: JPSOperationType.Replace)]
                case .Move: self.operations = [JPSOperation(type: JPSOperationType.Move)]
                case .Copy: self.operations = [JPSOperation(type: JPSOperationType.Copy)]
                case .Test: self.operations = [JPSOperation(type: JPSOperationType.Test)]
                }
            } else if let json = json as? [AnyObject] {
                var operationArray = [JPSOperation]()
                for _ in 0..<json.count {
                    operationArray.append(JPSOperation(type: JPSOperationType.Add))
                }
                self.operations = operationArray
            } else {
                // All other types are not a valid JSON Patch Operation.
                throw JPSJsonPatchInitialisationError.InvalidPatchFormat(message: "Root element is not an array or dictionary.")
            }
        } catch {
            throw JPSJsonPatchInitialisationError.InvalidJsonFormat(message: "JSON transformation failed.")
        }
    }
    
}

enum JPSOperationType: String {
    case Add = "add"
    case Remove = "remove"
    case Replace = "replace"
    case Move = "move"
    case Copy = "copy"
    case Test = "test"
}

struct JPSOperation {
    
    let type: JPSOperationType
    
}
