//
//  TitleSanitizerTests.swift
//  BranchToDoTests
//
//  Created by Collin Browse on 12/20/25.
//

import XCTest
@testable import BranchToDo

final class TitleSanitizerTests: XCTestCase {
    
    func testSanitize_WithNormalText_ReturnsUnchanged() throws {
        let input = "This is normal text"
        let result = TitleSanitizer.sanitize(input)
        XCTAssertEqual(result, input, "Normal text should be unchanged")
    }
    
    func testSanitize_WithWhitespace_TrimsWhitespace() throws {
        let input = "   Hello World   "
        let result = TitleSanitizer.sanitize(input)
        XCTAssertEqual(result, "Hello World", "Whitespace should be trimmed")
    }
    
    func testSanitize_WithTextOverLimit_TruncatesToLimit() throws {
        let input = String(repeating: "a", count: 2500)
        let result = TitleSanitizer.sanitize(input)
        XCTAssertEqual(result.count, 2000, "Text over limit should be truncated to 2000 characters")
    }
    
    func testSanitize_WithSafeLinks_PreservesLinks() throws {
        let input = "Visit https://example.com for more info"
        let result = TitleSanitizer.sanitize(input)
        XCTAssertTrue(result.contains("https://example.com"), "HTTPS links should be preserved")
    }
    
    func testSanitize_WithUnsafeLinks_RemovesLinks() throws {
        // Note: NSDataDetector may not detect javascript: URLs, so we test with file: which it does detect
        let input = "Open file:///path/to/file.txt here"
        let result = TitleSanitizer.sanitize(input)
        XCTAssertFalse(result.contains("file://"), "File links should be removed")
        XCTAssertTrue(result.contains("Open"), "Text before link should be preserved")
        XCTAssertTrue(result.contains("here"), "Text after link should be preserved")
    }
}

