//
//  AccountTest.swift
//  NemSwiftTests
//
//  Created by Taizo Kusuda on 2018/03/11.
//  Copyright © 2018年 ryuta46. All rights reserved.
//

import Foundation
import XCTest

class AccountTest : XCTestCase {


    func testRandom() {
        for network in [Address.Network.mainnet, Address.Network.testnet, Address.Network.mijin] {
            for _ in 0..<1 {
                let account = Account.generteAccount(network: network)
                print("\"\(account.address.value)\", \"\(account.keyPair.importKey())\"")

                XCTAssertEqual(account.address.network, network)
                switch(network) {
                case .mainnet: XCTAssertTrue(account.address.value.starts(with: "N"))
                case .testnet: XCTAssertTrue(account.address.value.starts(with: "T"))
                case .mijin: XCTAssertTrue(account.address.value.starts(with: "M"))
                }

                XCTAssertEqual(40, account.address.value.lengthOfBytes(using: .utf8))
                XCTAssertEqual(32, account.keyPair.privateKeySeed.count)
                XCTAssertEqual(32, account.keyPair.publicKey.count)
                XCTAssertEqual(64, account.keyPair.publicKeyHexString().lengthOfBytes(using: .utf8))
            }
        }
    }
}

struct AccountRepairTestFixture {
    let privateKey: String
    let network: Address.Network
    let address: String
}

class AccountRepairTest : ParameterizedTest {
    override class func createTestCases() -> [ParameterizedTest] {
        return self.testInvocations.map { AccountRepairTest(invocation: $0) }
    }

    override class var fixtures: [Any] {
        get {
            return [
                AccountRepairTestFixture(privateKey: "c2357d6ab2501e0cbd80da229ac0e6e85b4a794cbbf7f200e2b174e95b12d350", network: .mainnet, address: "ND2MI6G23ZOQ6UKFN3HQ4SZW5GB4GD2GY2LT64WT"),
                AccountRepairTestFixture(privateKey: "ebae0e74508093a0862df24f87a2ca381c0c6cb1ba3c9ed9b1efc70e824758f2", network: .testnet, address: "TBUIHWMJO5SY6CSZW2IZGAF3OFVKKX344O4BUM2L"),
                AccountRepairTestFixture(privateKey: "207ec261c7413ea0a6ea1f100ba9a8fa5939783fc3109e707186ae96d2e7f57a", network: .mijin, address: "MCM3PFQ4KXKDMOCBTYPORAIE4SRE65RLAKZXTUNL")
            ]
        }
    }

    func testRepairAddress() {
        let fixture = self.fixture as! AccountRepairTestFixture
        let account = Account.repairAccount(fixture.privateKey, network: fixture.network)
        XCTAssertEqual(fixture.address, account.address.value)
    }

}

