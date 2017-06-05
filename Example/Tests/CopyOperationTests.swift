//
//  CopyOperation.swift
//  JSONPatchSwift
//
//  Created by Maximilian Alexander on 6/4/17.
//  Copyright © 2017 CocoaPods. All rights reserved.
//

import XCTest
import JSONPatchSwift
import SwiftyJSON

// http://tools.ietf.org/html/rfc6902#section-4.5
// 4.  Operations
// 4.5. copy
class CopyOperationTests: XCTestCase {
    
    func testIfCopyReplaceValueInObjectReturnsExpectedValue() {
        let json = JSON(data: " { \"foo\" : { \"1\" : 2 }, \"bar\" : { }} ".data(using: String.Encoding.utf8)!)
        let jsonPatch = try! JsonPatch("{ \"op\": \"copy\", \"path\": \"/bar\", \"from\": \"/foo\" }")
        let resultingJson = try! JsonPatcher.applyPatch(jsonPatch: jsonPatch, toJson: json)
        let expectedJson = JSON(data: " { \"foo\" : { \"1\" : 2 }, \"bar\" : { \"1\" : 2 }} ".data(using: String.Encoding.utf8)!)
        XCTAssertEqual(resultingJson, expectedJson)
        
    }
    
    func testIfCopyArrayReturnsExpectedValue() {
        let json = JSON(data: " { \"foo\" : [1, 2, 3, 4], \"bar\" : []} ".data(using: String.Encoding.utf8)!)
        let jsonPatch = try! JsonPatch("{ \"op\": \"copy\", \"path\": \"/bar\", \"from\": \"/foo\" }")
        let resultingJson = try! JsonPatcher.applyPatch(jsonPatch: jsonPatch, toJson: json)
        let expectedJson = JSON(data: " { \"foo\" : [1, 2, 3, 4], \"bar\" : [1, 2, 3, 4]}".data(using: String.Encoding.utf8)!)
        XCTAssertEqual(resultingJson, expectedJson)
    }
    
    func testIfCopyArrayOfObjectsReturnsExpectedValue() {
        let json = JSON(data: " { \"foo\" : [{\"foo\": \"bar\"}], \"bar\" : {} } ".data(using: String.Encoding.utf8)!)
        let jsonPatch = try! JsonPatch("{ \"op\": \"copy\", \"path\": \"/bar\", \"from\": \"/foo/0\" }")
        let resultingJson = try! JsonPatcher.applyPatch(jsonPatch: jsonPatch, toJson: json)
        let expectedJson = JSON(data: " { \"foo\" : [{\"foo\": \"bar\"}], \"bar\" : {\"foo\": \"bar\"}}".data(using: String.Encoding.utf8)!)
        XCTAssertEqual(resultingJson, expectedJson)
    }
    
    func testIfMissingParameterReturnsError() {
        do {
            let result = try JsonPatch("{ \"op\": \"copy\", \"path\": \"/bar\"}") // from parameter missing
            XCTFail(result.operations.last!.value.rawString()!)
        } catch JsonPatch.JsonPatchInitialisationError.InvalidPatchFormat(let message) {
            // Expected behaviour.
            XCTAssertNotNil(message)
            XCTAssertEqual(message, Constants.JsonPatch.InitialisationErrorMessages.FromElementNotFound)
        } catch {
            XCTFail("Unexpected error.")
        }
    }
    
}
