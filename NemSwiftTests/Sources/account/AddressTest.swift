//
//  AddressTest.swift
//  NemSwiftTests
//
//  Created by Taizo Kusuda on 2018/03/11.
//  Copyright © 2018年 ryuta46. All rights reserved.
//

import Foundation
import XCTest
import NemSwift

struct AddressTestFixture {
    let publicKey: String
    let network: Address.Network
    let address: String
}

class AddressTest : ParameterizedTest {
    override class func createTestCases() -> [ParameterizedTest] {
        return self.testInvocations.map { AddressTest(invocation: $0) }
    }

    override class var fixtures: [Any] {
        get {
            return [
                AddressTestFixture(publicKey: "3f9f8c791f4b55c84278c10c7596f959a43a71dc35888d16e3d26a33456b6df2", network: .mainnet, address: "NCNFK2ULFDYWIDSS4VKGK2PQHUJWP5V7M2RLKWDN"),
                AddressTestFixture(publicKey: "13394e3a7bba1b41be79e51476c2be76fd42c28ad6bfcb8efb85325f4ad77de6", network: .mainnet, address: "NCUK4VQHA4OSEXD5K2TKBEE2722PCXAEQ3SPTDBJ"),
                AddressTestFixture(publicKey: TestSettings.PUBLIC_KEY, network: .testnet, address: TestSettings.ADDRESS)
            ]
        }
    }

    func testAddress() {
        let fixture = self.fixture as! AddressTestFixture
        let address = Address(publicKey: ConvertUtil.toByteArray(fixture.publicKey), network: fixture.network)
        XCTAssertEqual(fixture.address, address.value)
    }
}
