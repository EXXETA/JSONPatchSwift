//
//  OperationTests.swift
//  JSONPatchSwift
//
//  Created by Maximilian Alexander on 6/4/17.
//  Copyright © 2017 CocoaPods. All rights reserved.
//


import XCTest
import JSONPatchSwift
import SwiftyJSON

// http://tools.ietf.org/html/rfc6902#section-4.6
// 4.  Operations
// 4.6. test
class TestOperationTests: XCTestCase {
    
    func testIfBasicStringCheckReturnsExpectedResult() {
        let json = JSON(data: " { \"foo\" : { \"1\" : \"2\" }} ".data(using: String.Encoding.utf8)!)
        let jsonPatch = try! JsonPatch("{ \"op\": \"test\", \"path\": \"/foo/1\", \"value\": \"2\" }")
        let resultingJson = try! JsonPatcher.applyPatch(jsonPatch: jsonPatch, toJson: json)
        XCTAssertEqual(resultingJson, json)
    }
    
    func testIfInvalidBasicStringCheckReturnsExpectedResult() {
        let json = JSON(data: " { \"foo\" : { \"1\" : \"2\" }} ".data(using: String.Encoding.utf8)!)
        let jsonPatch = try! JsonPatch("{ \"op\": \"test\", \"path\": \"/foo/1\", \"value\": \"3\" }")
        do {
            let result = try JsonPatcher.applyPatch(jsonPatch: jsonPatch, toJson: json)
            XCTFail(result.rawString()!)
        } catch JsonPatcher.JsonPatcherApplyError.ValidationError(let message) {
            // Expected behaviour.
            XCTAssertNotNil(message)
        } catch {
            XCTFail("Unexpected error.")
        }
    }
    
    func testIfBasicIntCheckReturnsExpectedResult() {
        let json = JSON(data: " { \"foo\" : { \"1\" : 2 }} ".data(using: String.Encoding.utf8)!)
        let jsonPatch = try! JsonPatch("{ \"op\": \"test\", \"path\": \"/foo/1\", \"value\": 2 }")
        let resultingJson = try! JsonPatcher.applyPatch(jsonPatch: jsonPatch, toJson: json)
        XCTAssertEqual(resultingJson, json)
    }
    
    func testIfInvalidBasicIntCheckReturnsExpectedResult() {
        let json = JSON(data: " { \"foo\" : { \"1\" : 2 }} ".data(using: String.Encoding.utf8)!)
        let jsonPatch = try! JsonPatch("{ \"op\": \"test\", \"path\": \"/foo/1\", \"value\": 3 }")
        do {
            let result = try JsonPatcher.applyPatch(jsonPatch: jsonPatch, toJson: json)
            XCTFail(result.rawString()!)
        } catch JsonPatcher.JsonPatcherApplyError.ValidationError(let message) {
            // Expected behaviour.
            XCTAssertNotNil(message)
        } catch {
            XCTFail("Unexpected error.")
        }
    }
    
    func testIfBasicObjectCheckReturnsExpectedResult() {
        let json = JSON(data: " { \"foo\" : { \"1\" : 2 }} ".data(using: String.Encoding.utf8)!)
        let jsonPatch = try! JsonPatch("{ \"op\": \"test\", \"path\": \"/foo\", \"value\": { \"1\" : 2 } }")
        let resultingJson = try! JsonPatcher.applyPatch(jsonPatch: jsonPatch, toJson: json)
        XCTAssertEqual(resultingJson, json)
    }
    
    func testIfInvalidBasicObjectCheckReturnsExpectedResult() {
        let json = JSON(data: " { \"foo\" : { \"1\" : \"2\" }} ".data(using: String.Encoding.utf8)!)
        let jsonPatch = try! JsonPatch("{ \"op\": \"test\", \"path\": \"/foo\", \"value\": { \"1\" : 3 } }")
        do {
            let result = try JsonPatcher.applyPatch(jsonPatch: jsonPatch, toJson: json)
            XCTFail(result.rawString()!)
        } catch JsonPatcher.JsonPatcherApplyError.ValidationError(let message) {
            // Expected behaviour.
            XCTAssertNotNil(message)
        } catch {
            XCTFail("Unexpected error.")
        }
    }
    
    func testIfBasicArrayCheckReturnsExpectedResult() {
        let json = JSON(data: " { \"foo\" : [1, 2, 3, 4, 5]} ".data(using: String.Encoding.utf8)!)
        let jsonPatch = try! JsonPatch("{ \"op\": \"test\", \"path\": \"/foo\", \"value\": [1, 2, 3, 4, 5] }")
        let resultingJson = try! JsonPatcher.applyPatch(jsonPatch: jsonPatch, toJson: json)
        XCTAssertEqual(resultingJson, json)
    }
    
    func testIfInvalidBasicArrayCheckReturnsExpectedResult() {
        let json = JSON(data: " { \"foo\" : [1, 2, 3, 4, 5]} ".data(using: String.Encoding.utf8)!)
        let jsonPatch = try! JsonPatch("{ \"op\": \"test\", \"path\": \"/foo\", \"value\": [1, 2, 3, 4, 5, 6, 7, 42] }")
        do {
            let result = try JsonPatcher.applyPatch(jsonPatch: jsonPatch, toJson: json)
            XCTFail(result.rawString()!)
        } catch JsonPatcher.JsonPatcherApplyError.ValidationError(let message) {
            // Expected behaviour.
            XCTAssertNotNil(message)
        } catch {
            XCTFail("Unexpected error.")
        }
    }
}
