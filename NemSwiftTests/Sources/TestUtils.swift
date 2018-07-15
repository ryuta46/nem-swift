//
//  TestUtils.swift
//  NemSwiftTests
//
//  Created by Taizo Kusuda on 2018/03/11.
//  Copyright © 2018年 ryuta46. All rights reserved.
//

import Foundation
import XCTest
import NemSwift

class TestUtils {
    static func checkResult(result: NemAnnounceResult) {
        XCTAssertEqual(1, result.type)
        XCTAssertEqual(1, result.code)
        XCTAssertEqual("SUCCESS", result.message)
    }

    static func checkResultIsInsufficientBalance(result: NemAnnounceResult) {
        XCTAssertEqual(1, result.type)
        XCTAssertEqual(5, result.code)
        XCTAssertEqual("FAILURE_INSUFFICIENT_BALANCE", result.message)
    }
}
