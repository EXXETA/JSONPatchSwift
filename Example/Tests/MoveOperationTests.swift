//
//  MoveOperationTests.swift
//  JSONPatchSwift
//
//  Created by Maximilian Alexander on 6/4/17.
//  Copyright © 2017 CocoaPods. All rights reserved.
//


import XCTest
import JSONPatchSwift
import SwiftyJSON

// http://tools.ietf.org/html/rfc6902#section-4.4
// 4.  Operations
// 4.4.  move
class MoveOperationTests: XCTestCase {
    
    // http://tools.ietf.org/html/rfc6902#appendix-A.6
    func testIfMoveValueInObjectReturnsExpectedValue() {
        let json = JSON(data: "{ \"foo\": { \"bar\": \"baz\", \"waldo\": \"fred\" }, \"qux\":{ \"corge\": \"grault\" } }".data(using: String.Encoding.utf8)!)
        let jsonPatch = try! JsonPatch("{ \"op\": \"move\", \"path\": \"/qux/thud\", \"from\": \"/foo/waldo\" }")
        let resultingJson = try! JsonPatcher.applyPatch(jsonPatch: jsonPatch, toJson: json)
        let expectedJson = JSON(data: " { \"foo\": { \"bar\": \"baz\" }, \"qux\": { \"corge\": \"grault\",\"thud\": \"fred\" } }".data(using: String.Encoding.utf8)!)
        XCTAssertEqual(resultingJson, expectedJson)
    }
    
    // http://tools.ietf.org/html/rfc6902#appendix-A.7
    func testIfMoveIndizesInArrayReturnsExpectedValue() {
        let json = JSON(data: " { \"foo\" : [\"all\", \"grass\", \"cows\", \"eat\"]} ".data(using: String.Encoding.utf8)!)
        let jsonPatch = try! JsonPatch("{ \"op\": \"move\", \"path\": \"/foo/3\", \"from\": \"/foo/1\" }")
        let resultingJson = try! JsonPatcher.applyPatch(jsonPatch: jsonPatch, toJson: json)
        let expectedJson = JSON(data: "{ \"foo\" : [\"all\", \"cows\", \"eat\", \"grass\"]} ".data(using: String.Encoding.utf8)!)
        XCTAssertEqual(resultingJson, expectedJson)
    }
    
    func testIfObjectKeyMoveOperationReturnsExpectedValue() {
        let json = JSON(data: " { \"foo\" : { \"1\" : 2 }, \"bar\" : { }} ".data(using: String.Encoding.utf8)!)
        let jsonPatch = try! JsonPatch("{ \"op\": \"move\", \"path\": \"/bar/1\", \"from\": \"/foo/1\" }")
        let resultingJson = try! JsonPatcher.applyPatch(jsonPatch: jsonPatch, toJson: json)
        let expectedJson = JSON(data: "{ \"foo\" : {  }, \"bar\" : { \"1\" : 2 }}".data(using: String.Encoding.utf8)!)
        XCTAssertEqual(resultingJson, expectedJson)
    }
    
    func testIfObjectKeyMoveToRootReplacesDocument() {
        let json = JSON(data: " { \"foo\" : { \"1\" : 2 }, \"bar\" : { }} ".data(using: String.Encoding.utf8)!)
        let jsonPatch = try! JsonPatch("{ \"op\": \"move\", \"path\": \"\", \"from\": \"/foo\" }")
        let resultingJson = try! JsonPatcher.applyPatch(jsonPatch: jsonPatch, toJson: json)
        let expectedJson = JSON(data: "{ \"1\" : 2 }".data(using: String.Encoding.utf8)!)
        XCTAssertEqual(resultingJson, expectedJson)
    }
    
    func testIfMissingParameterReturnsError() {
        do {
            let result = try JsonPatch("{ \"op\": \"move\", \"path\": \"/bar\"}") // 'from' parameter missing
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
