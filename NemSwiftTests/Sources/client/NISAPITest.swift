//
//  NISAPITest.swift
//  NemSwiftTests
//
//  Created by Taizo Kusuda on 2018/03/06.
//  Copyright © 2018年 ryuta46. All rights reserved.
//

import Foundation
import XCTest
import APIKit
import Result
@testable import NemSwift

//extension Extension where Base: Session {
extension Session {
    static func sendSync<T: Request>(_ request: T) -> Result<T.Response, SessionTaskError> {
        var result: Result<T.Response, SessionTaskError>!
        let semaphor = DispatchSemaphore(value: 0)
        self.send(request, callbackQueue: .sessionQueue) { _result in
            result = _result
            semaphor.signal()
        }
        semaphor.wait()
        return result
    }
    static func sendSyncWithTest<T: Request>(_ request: T) -> T.Response? {
        let result = self.sendSync(request)
        switch result {
        case .success(let response):
            return response
        case .failure(let error):
            XCTFail("Communication Error \(error.localizedDescription)")
        }
        return nil
        //fatalError("Nerver execute")
    }

}
func printModel<T : Encodable>(model: T) {
    let encoder = JSONEncoder()
    encoder.outputFormatting = .prettyPrinted
    let data = try! encoder.encode(model)
    print(String(data: data, encoding: .utf8))
}

class NISAPITest: XCTestCase {
    
    override func setUp() {
        super.setUp()
        // Put setup code here. This method is called before the invocation of each test method in the class.
    }
    
    override func tearDown() {
        // Put teardown code here. This method is called after the invocation of each test method in the class.
        super.tearDown()
    }
    
    func testAccountGet() {
        guard let response = Session.sendSyncWithTest(NISAPI.AccountGet(address: TestSettings.ADDRESS)) else { return }
        print("\(response)")
        XCTAssertEqual(TestSettings.ADDRESS, response.account.address)
        XCTAssertEqual(TestSettings.PUBLIC_KEY, response.account.publicKey)
    }

    func testAccountGetFromPublicKey() {
        guard let response = Session.sendSyncWithTest(NISAPI.AccountGetFromPublicKey(publicKey: TestSettings.PUBLIC_KEY)) else { return }
        print("\(response)")
        XCTAssertEqual(TestSettings.ADDRESS, response.account.address)
        XCTAssertEqual(TestSettings.PUBLIC_KEY, response.account.publicKey)
    }

    func testAccountGetForwarded() {
        // API Document sample request.
        guard let response = Session.sendSyncWithTest(NISAPI.AccountGetForwarded(address: "NC2ZQKEFQIL3JZEOB2OZPWXWPOR6LKYHIROCR7PK")) else { return }
        print("\(response)")
        XCTAssertEqual("NALICE2A73DLYTP4365GNFCURAUP3XVBFO7YNYOW", response.account.address)
    }

    func testAccountGetForwardedMyself() {
        guard let response = Session.sendSyncWithTest(NISAPI.AccountGetForwarded(address: TestSettings.ADDRESS)) else { return }
        print("\(response)")
        XCTAssertEqual(TestSettings.ADDRESS, response.account.address)
    }

    func testAccountGetForwardedFromPublicKey() {
        guard let response = Session.sendSyncWithTest(NISAPI.AccountGetForwardedFromPublicKey(publicKey: "bdd8dd702acb3d88daf188be8d6d9c54b3a29a32561a068b25d2261b2b2b7f02")) else { return }
        print("\(response)")
        XCTAssertEqual("NALICE2A73DLYTP4365GNFCURAUP3XVBFO7YNYOW", response.account.address)
    }


    func testAccountGetForwardedFromPublicKeyMyself() {
        guard let response = Session.sendSyncWithTest(NISAPI.AccountGetForwardedFromPublicKey(publicKey: TestSettings.PUBLIC_KEY)) else { return }
        print("\(response)")
        XCTAssertEqual(TestSettings.ADDRESS, response.account.address)
    }

    func testAccountStatus() {
        guard let response = Session.sendSyncWithTest(NISAPI.AccountStatus(address: TestSettings.ADDRESS)) else { return }
        print("\(response)")

        XCTAssertEqual("LOCKED", response.status)
        XCTAssertEqual("INACTIVE", response.remoteStatus)
        XCTAssertFalse(response.cosignatoryOf.isEmpty)
        XCTAssertFalse(response.cosignatories.isEmpty)
    }


    func testAccountTransfersIncoming() {
        guard let response = Session.sendSyncWithTest(NISAPI.AccountTransfersIncoming(address: TestSettings.ADDRESS, hash: nil, id: nil )) else { return }
        print("\(response)")
        XCTAssertFalse(response.data.isEmpty)

        response.data.forEach { metaDataPair in
            if metaDataPair.transaction.type == TransactionHelper.TransactionType.Transfer.transactionTypeBytes() {
                XCTAssertEqual(TestSettings.ADDRESS, metaDataPair.transaction.recipient)
            }
        }
    }

    func testAccountTransfersOutgoing() {
        guard let response = Session.sendSyncWithTest(NISAPI.AccountTransfersOutgoin(address: TestSettings.ADDRESS, hash: nil, id: nil )) else { return }
        print("\(response)")
        XCTAssertFalse(response.data.isEmpty)

        response.data.forEach { metaDataPair in
            if metaDataPair.transaction.type == TransactionHelper.TransactionType.Transfer.transactionTypeBytes() {
                XCTAssertEqual(TestSettings.PUBLIC_KEY, metaDataPair.transaction.signer)
            }
        }
    }

    func testUccountTransfersAll() {
        guard let response = Session.sendSyncWithTest(NISAPI.AccountTransfersAll(address: TestSettings.ADDRESS, hash: nil, id: nil )) else { return }
        print("\(response)")
        XCTAssertFalse(response.data.isEmpty)

        response.data.forEach { metaDataPair in
            if metaDataPair.transaction.type == TransactionHelper.TransactionType.Transfer.transactionTypeBytes() {
                XCTAssertTrue(TestSettings.ADDRESS == metaDataPair.transaction.recipient || TestSettings.PUBLIC_KEY ==  metaDataPair.transaction.signer)
            }
        }
    }

    /*
    @Test
    fun accountUnconfirmedTransactions() {
    transferTransactionAnnounce(getTransferTransactionAnnounceFixture()[2])
    val result = client.accountUnconfirmedTransactions(Settings.ADDRESS)
    printModel(result)

    if (Settings.PRIVATE_KEY.isEmpty()) {
    assertTrue(result.isEmpty())
    } else {
    assertTrue(result.isNotEmpty())
    result.forEach {
    assertEquals(Settings.PUBLIC_KEY, it.transaction.signer)

    }
    }
    }
    */

    func testAccountHarvests() {
        guard let response = Session.sendSyncWithTest(NISAPI.AccountHarvests(address: TestSettings.ADDRESS, hash: "")) else { return }
        print("\(response)")
        XCTAssertTrue(response.data.isEmpty)
    }


    func testAccountImportances() {
        guard let response = Session.sendSyncWithTest(NISAPI.AccountImportances()) else { return }
        print("\(response)")

        XCTAssertFalse(response.data.isEmpty)
        response.data.forEach { account in
            XCTAssertFalse(account.address.isEmpty)
        }
    }


    func testAccountNamespacePage() {
        guard let response = Session.sendSyncWithTest(NISAPI.AccountNamespacePage(address: TestSettings.RECEIVER, parent: nil, id: nil, pageSize: nil)) else { return }
        print("\(response)")

        XCTAssertFalse(response.data.isEmpty)
        response.data.forEach { namespace in
            XCTAssertEqual(TestSettings.RECEIVER, namespace.owner)
        }
    }

    func testAccountNamespacePageInvalidParent() {
        guard let response = Session.sendSyncWithTest(NISAPI.AccountNamespacePage(address: TestSettings.RECEIVER, parent: "invalid", id: nil, pageSize: nil)) else { return }
        print("\(response)")

        XCTAssertTrue(response.data.isEmpty)
    }

    func testAccountMosaicOwned() {
        guard let response = Session.sendSyncWithTest(NISAPI.AccountMosaicOwned(address: TestSettings.ADDRESS)) else { return }
        print("\(response)")

        XCTAssertFalse(response.data.isEmpty)
    }

}
