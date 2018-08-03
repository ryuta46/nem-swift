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
import APIKit

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

    static func checkResultIsMultisigNotACosigner(result: NemAnnounceResult) {
        XCTAssertEqual(1, result.type)
        XCTAssertEqual(71, result.code)
        XCTAssertEqual("FAILURE_MULTISIG_NOT_A_COSIGNER", result.message)
    }

    static func waitUntilIncomingIsNotEmpty(address: String) -> Bool {
        for _ in 0..<10 {
            Thread.sleep(forTimeInterval: 60)
            guard let response = Session.sendSyncWithTest(NISAPI.AccountTransfersIncoming(address: address, hash: nil, id: nil )) else { return false}
            print("\(response)")
            if !response.data.isEmpty {
                return true
            }
        }
        
        return false
    }
    
    static func waitUntilConfirmedOutgoing(address: String, hash: String) -> Bool {
        for _ in 0..<10 {
            Thread.sleep(forTimeInterval: 60)
            guard let response = Session.sendSyncWithTest(NISAPI.AccountTransfersOutgoing(address: address, hash: nil, id: nil )) else { return false}
            print("\(response)")
            for transaction in response.data {
                if transaction.meta.hash.data == hash {
                    return true
                }
            }
        }
        return false
    }
}
