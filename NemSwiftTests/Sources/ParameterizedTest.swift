//
//  XCParameterizedTest.swift
//  NemSwiftTests
//
//  Created by Taizo Kusuda on 2018/03/09.
//  Copyright © 2018年 ryuta46. All rights reserved.
//

import Foundation
import XCTest
@testable import NemSwift

// Parameterized Test Template
class ParameterizedTest : XCTestCase {
    class func createTestCases() -> [ParameterizedTest] {
        fatalError("""
You must override createTestCases() in following way.

    override class func createTestCases() -> [ParameterizedTest] {
        return self.testInvocations.map { YourParameterizedTestSubClass(invocation: $0) }
    }
"""
        )
    }
    class var fixtures: [Any] {
        get {
            fatalError("""
You must override fixtures.
e.g.:
    override class var fixtures: [Any] {
        get {
            return [
                YourTestFixture(3, 9),
                YourTestFixture(4, 16),
            ]
        }
    }
"""
            )
        }
    }

    // Backing field of current fixture
    private var _fixture: Any? = nil

    // Current fixture. Fixture must not be nil.
    final private(set) var fixture : Any {
        get {
            return _fixture!
        }
        set {
            _fixture = newValue
        }
    }

    override class var defaultTestSuite: XCTestSuite {
        let testSuite = XCTestSuite(name: NSStringFromClass(self))
        guard self != ParameterizedTest.self else {
            return testSuite
        }
        for fixture in self.fixtures {
            let testCases = self.createTestCases()
            for testCase in testCases {
                testCase.fixture = fixture
                testSuite.addTest(testCase)
            }
        }
        return testSuite
    }

}

