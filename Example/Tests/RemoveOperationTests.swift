//
//  RemoveOperationTests.swift
//  JSONPatchSwift
//
//  Created by Maximilian Alexander on 6/4/17.
//  Copyright © 2017 CocoaPods. All rights reserved.
//

import XCTest
import JSONPatchSwift
import SwiftyJSON

// http://tools.ietf.org/html/rfc6902#section-4.2
// 4.  Operations
// 4.2.  remove
class RemoveOperationTests: XCTestCase {
    
    // http://tools.ietf.org/html/rfc6902#appendix-A.3
    func testIfDeleteObjectMemberReturnsExpectedValue() {
        let json = JSON(data: " { \"baz\": \"qux\", \"foo\": \"bar\"} ".data(using: String.Encoding.utf8)!)
        let jsonPatch = try! JsonPatch("{ \"op\": \"remove\", \"path\": \"/baz\" }")
        let resultingJson = try! JsonPatcher.applyPatch(jsonPatch: jsonPatch, toJson: json)
        let expectedJson = JSON(data: " { \"foo\": \"bar\" } ".data(using: String.Encoding.utf8)!)
        XCTAssertEqual(resultingJson, expectedJson)
    }
    
    // http://tools.ietf.org/html/rfc6902#appendix-A.4
    func testIfDeleteArrayElementReturnsExpectedValue() {
        let json = JSON(data: " { \"foo\": [ \"bar\", \"qux\", \"baz\" ] } ".data(using: String.Encoding.utf8)!)
        let jsonPatch = try! JsonPatch("{ \"op\": \"remove\", \"path\": \"/foo/1\" }")
        let resultingJson = try! JsonPatcher.applyPatch(jsonPatch: jsonPatch, toJson: json)
        let expectedJson = JSON(data: " { \"foo\": [ \"bar\", \"baz\" ] } ".data(using: String.Encoding.utf8)!)
        XCTAssertEqual(resultingJson, expectedJson)
    }
    
    func testIfDeleteLastElementReturnsEmptyJson() {
        let json = JSON(data: " { \"foo\" : \"1\" } ".data(using: String.Encoding.utf8)!)
        let jsonPatch = try! JsonPatch("{ \"op\": \"remove\", \"path\": \"/foo\" }")
        let resultingJson = try! JsonPatcher.applyPatch(jsonPatch: jsonPatch, toJson: json)
        let expectedJson = JSON(data: "{ }".data(using: String.Encoding.utf8)!)
        XCTAssertEqual(resultingJson, expectedJson)
    }
    
    func testIfDeleteSubElementReturnsEmptyTopElement() {
        let json = JSON(data: " { \"foo\" : { \"bar\" : \"1\" } } ".data(using: String.Encoding.utf8)!)
        let jsonPatch = try! JsonPatch("{ \"op\": \"remove\", \"path\": \"/foo/bar\" }")
        let resultingJson = try! JsonPatcher.applyPatch(jsonPatch: jsonPatch, toJson: json)
        let expectedJson = JSON(data: "{ \"foo\" : { } }".data(using: String.Encoding.utf8)!)
        XCTAssertEqual(resultingJson, expectedJson)
    }
    
    func testIfDeleteLastArrayElementReturnsEmptyArray() {
        let json = JSON(data: " { \"foo\" : { \"bar\" : \"1\" } } ".data(using: String.Encoding.utf8)!)
        let jsonPatch = try! JsonPatch("{ \"op\": \"remove\", \"path\": \"/foo/bar\" }")
        let resultingJson = try! JsonPatcher.applyPatch(jsonPatch: jsonPatch, toJson: json)
        let expectedJson = JSON(data: "{ \"foo\" : { } }".data(using: String.Encoding.utf8)!)
        XCTAssertEqual(resultingJson, expectedJson)
    }
    
    func testIfDeleteFromArrayDeletesTheExpectedKey() {
        let json = JSON(data: " [ \"foo\", 42, \"bar\" ] ".data(using: String.Encoding.utf8)!)
        let jsonPatch = try! JsonPatch("{ \"op\": \"remove\", \"path\": \"/2\" }")
        let resultingJson = try! JsonPatcher.applyPatch(jsonPatch: jsonPatch, toJson: json)
        let expectedJson = JSON(data: " [ \"foo\", 42, ] ".data(using: String.Encoding.utf8)!)
        XCTAssertEqual(resultingJson, expectedJson)
    }
    
    func testIfDeleteFromMultiDimensionalArrayDeletesTheExpectedKey() {
        let json = JSON(data: " [ \"foo\", [ \"foo\", 3, \"42\" ], \"bar\" ] ".data(using: String.Encoding.utf8)!)
        let jsonPatch = try! JsonPatch("{ \"op\": \"remove\", \"path\": \"/1/2\" }")
        let resultingJson = try! JsonPatcher.applyPatch(jsonPatch: jsonPatch, toJson: json)
        let expectedJson = JSON(data: " [ \"foo\", [ \"foo\", 3 ], \"bar\" ] ".data(using: String.Encoding.utf8)!)
        XCTAssertEqual(resultingJson, expectedJson)
    }
}
