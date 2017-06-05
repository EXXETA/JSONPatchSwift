//
//  ReplaceOperationTests.swift
//  JSONPatchSwift
//
//  Created by Maximilian Alexander on 6/4/17.
//  Copyright © 2017 CocoaPods. All rights reserved.
//

import XCTest
import JSONPatchSwift
import SwiftyJSON

// http://tools.ietf.org/html/rfc6902#section-4.3
// 4.  Operations
// 4.3. replace
class ReplaceOperationTests: XCTestCase {
    
    // http://tools.ietf.org/html/rfc6902#appendix-A.5
    func testIfReplaceValueInObjectReturnsExpectedValue() {
        let json = JSON(data: "{\"baz\": \"qux\",\"foo\": \"bar\"}".data(using: String.Encoding.utf8)!)
        let jsonPatch = try! JsonPatch("{ \"op\": \"replace\", \"path\": \"/baz\", \"value\": \"boo\" }")
        let resultingJson = try! JsonPatcher.applyPatch(jsonPatch: jsonPatch, toJson: json)
        let expectedJson = JSON(data: "  { \"baz\": \"boo\",\"foo\": \"bar\" } ".data(using: String.Encoding.utf8)!)
        XCTAssertEqual(resultingJson, expectedJson)
    }
    
    func testIfReplaceValueInArrayArrayReturnsExpectedValue() {
        let json = JSON(data: " { \"foo\" : [1, 2, 3, 4], \"bar\" : []} ".data(using: String.Encoding.utf8)!)
        let jsonPatch = try! JsonPatch("{ \"op\": \"replace\", \"path\": \"/foo/1\", \"value\": 42 }")
        let resultingJson = try! JsonPatcher.applyPatch(jsonPatch: jsonPatch, toJson: json)
        let expectedJson = JSON(data: " { \"foo\" : [1, 42, 3, 4], \"bar\" : []}".data(using: String.Encoding.utf8)!)
        XCTAssertEqual(resultingJson, expectedJson)
    }
    
    func testIfMissingValueRaisesError() {
        do {
            let result = try JsonPatch("{ \"op\": \"replace\", \"path\": \"/foo/1\" }") // value missing
            XCTFail(result.operations.last!.value.rawString()!)
        } catch JsonPatch.JsonPatchInitialisationError.InvalidPatchFormat(let message) {
            // Expected behaviour.
            XCTAssertNotNil(message)
        } catch {
            XCTFail("Unexpected error.")
        }
        
    }
}
