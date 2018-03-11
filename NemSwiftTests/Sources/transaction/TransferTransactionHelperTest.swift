//
//  TransferTransactionHelperTest.swift
//  NemSwiftTests
//
//  Created by Taizo Kusuda on 2018/03/11.
//  Copyright © 2018年 ryuta46. All rights reserved.
//

import Foundation
import XCTest
@testable import NemSwift

func extractTransactionFee(_ transactionBytes: [UInt8] ) -> UInt64 {
    var fee: UInt64 = 0
    for i in 0..<4 {
        fee += UInt64(transactionBytes[48 + i]) << (i*8)
    }

    return fee
}

struct XemTransferFeeTestFixture {
    let microNem: UInt64
    let expected: UInt64

    init(_ microNem: UInt64, _ expected: UInt64) {
        self.microNem = microNem
        self.expected = expected
    }
}


class XemTransferFeeTest : ParameterizedTest {
    override class func createTestCases() -> [ParameterizedTest] {
        return self.testInvocations.map { XemTransferFeeTest(invocation: $0) }
    }

    override class var fixtures: [Any] {
        get {
            return [
                XemTransferFeeTestFixture(0, 50_000),
                XemTransferFeeTestFixture(10_000_000_000, 50_000),
                XemTransferFeeTestFixture(19_999_999_999, 50_000),
                XemTransferFeeTestFixture(20_000_000_000, 100_000),
                XemTransferFeeTestFixture(249_999_999_999, 1_200_000),
                XemTransferFeeTestFixture(250_000_000_000, 1_250_000),
                XemTransferFeeTestFixture(250_000_000_001, 1_250_000),
                XemTransferFeeTestFixture(1_000_000_000_000, 1_250_000)
            ]
        }
    }

    func testXemTransferFee() {
        let fixture = self.fixture as! XemTransferFeeTestFixture

        let account = Account.generteAccount(network: .testnet)

        let transactionBytes = TransferTransactionHelper.generateTransferRequestAnnounce(
            publicKey: account.keyPair.publicKey,
            network: .testnet,
            recipientAddress: TestSettings.RECEIVER,
            amount: fixture.microNem,
            messageType: .Plain,
            message: "")

        XCTAssertEqual(fixture.expected, extractTransactionFee(transactionBytes))
    }

}


struct MessageTransferFeeTestFixture {
    let message: String
    let expected: UInt64

    init(_ message: String, _ expected: UInt64) {
        self.message = message
        self.expected = expected
    }
}

class MessageTransferFeeTest : ParameterizedTest {
    override class func createTestCases() -> [ParameterizedTest] {
        return self.testInvocations.map { MessageTransferFeeTest(invocation: $0) }
    }

    override class var fixtures: [Any] {
        get {
            return [
                MessageTransferFeeTestFixture("", 0),
                MessageTransferFeeTestFixture("1234567890123456789012345678901", 50_000),
                MessageTransferFeeTestFixture("12345678901234567890123456789012", 100_000),
                MessageTransferFeeTestFixture("123456789012345678901234567890123456789012345678901234567890123",100_000)
            ]
        }
    }

    func testMessageTransferFee() {
        let fixture = self.fixture as! MessageTransferFeeTestFixture

        let account = Account.generteAccount(network: .testnet)

        let transactionBytes = TransferTransactionHelper.generateTransferRequestAnnounce(
            publicKey: account.keyPair.publicKey,
            network: .testnet,
            recipientAddress: TestSettings.RECEIVER,
            amount: 0,
            messageType: .Plain,
            message: fixture.message)

        // 50_000 is transfer fee of 0 xem.
        XCTAssertEqual(fixture.expected + 50_000, extractTransactionFee(transactionBytes))
    }
}



struct MosaicTransferFeeTestFixture {
    let mosaics: [TransferMosaic]
    let expected: UInt64

    init(_ mosaics: [TransferMosaic], _ expected: UInt64) {
        self.mosaics = mosaics
        self.expected = expected
    }
}

class MosaicTransferFeeTest : ParameterizedTest {
    override class func createTestCases() -> [ParameterizedTest] {
        return self.testInvocations.map { MosaicTransferFeeTest(invocation: $0) }
    }

    override class var fixtures: [Any] {
        get {
            return [
                MosaicTransferFeeTestFixture([TransferMosaic(namespace: "ttech", mosaic: "ryuta", quantity: 1)], 50_000),
                MosaicTransferFeeTestFixture([TransferMosaic(namespace: "ttech", mosaic: "ryuta", quantity: 1)], 50_000),
                MosaicTransferFeeTestFixture([TransferMosaic(namespace: "ttech", mosaic: "ryuta", quantity: 23)], 100_000),
                MosaicTransferFeeTestFixture([TransferMosaic(namespace: "ttech", mosaic: "ryuta", quantity: 24)], 150_000),
                MosaicTransferFeeTestFixture([TransferMosaic(namespace: "ttech", mosaic: "ryuta", quantity: 25)], 200_000),
                MosaicTransferFeeTestFixture([TransferMosaic(namespace: "ttech", mosaic: "ryuta", quantity: 28)], 350_000),
                MosaicTransferFeeTestFixture([TransferMosaic(namespace: "ttech", mosaic: "ryuta", quantity: 29)], 350_000)
            ]
        }
    }

    func testMosaicTransferFee() {
        let fixture = self.fixture as! MosaicTransferFeeTestFixture

        let account = Account.generteAccount(network: .testnet)

        let transactionBytes = TransferTransactionHelper.generateMosaicTransferRequestAnnounce(
            publicKey: account.keyPair.publicKey,
            network: .testnet,
            recipientAddress: TestSettings.RECEIVER,
            mosaics: fixture.mosaics,
            messageType: .Plain,
            message: "")

        XCTAssertEqual(fixture.expected, extractTransactionFee(transactionBytes))
    }
}




