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
    print(String(data: data, encoding: .utf8)!)
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
        XCTAssertTrue(response.cosignatories.isEmpty)
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
        guard let response = Session.sendSyncWithTest(NISAPI.AccountTransfersOutgoing(address: TestSettings.ADDRESS, hash: nil, id: nil )) else { return }
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

    func testAccountUnconfirmedTransactions() {
        testTransferTransaction(fixture: TransferTransactionTestFixture(0))

        guard let response = Session.sendSyncWithTest(NISAPI.AccountUnconfirmedTransactions(address: TestSettings.ADDRESS)) else { return }
        print("\(response)")

        if TestSettings.PRIVATE_KEY.isEmpty {
            XCTAssertTrue(response.data.isEmpty)
        } else {
            XCTAssertFalse(response.data.isEmpty)
            response.data.forEach { metaDataPair in
                XCTAssertEqual(TestSettings.PUBLIC_KEY, metaDataPair.transaction.signer)
            }
        }
    }

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

    func testNamespaceMosaicDefinitionPage() {
        guard let response = Session.sendSyncWithTest(NISAPI.NamespaceMosaicDefintionPage(namespace: "ttech", id: nil, pagesize: nil )) else { return }
        print("\(response)")

        XCTAssertFalse(response.data.isEmpty)

        response.data.forEach { metaDataPair in
            XCTAssertEqual(TestSettings.RECEIVER_PUBLIC, metaDataPair.mosaic.creator)
        }
    }


}


class TransferTransactionTestFixture {
    let xem: UInt64
    let message: String
    let messageType: TransferTransactionHelper.MessageType
    let mosaics: [TransferMosaic]

    init(_ xem: UInt64, _ message: String = "", _ messageType: TransferTransactionHelper.MessageType = TransferTransactionHelper.MessageType.Plain, _ mosaics: [TransferMosaic] = []) {
        self.xem = xem
        self.message = message
        self.messageType = messageType
        self.mosaics = mosaics
    }
}

func testTransferTransaction(fixture: TransferTransactionTestFixture) {
    let account: Account
    if !TestSettings.PRIVATE_KEY.isEmpty {
        account = Account.repairAccount(TestSettings.PRIVATE_KEY, network: .testnet)
    } else {
        account = Account.generteAccount(network: .testnet)
    }

    XCTAssertEqual(TestSettings.ADDRESS, account.address.value)

    let announce: [UInt8]

    if fixture.mosaics.isEmpty {
        announce = TransferTransactionHelper.generateTransferRequestAnnounce(
            publicKey: account.keyPair.publicKey,
            network: .testnet,
            recipientAddress: TestSettings.RECEIVER,
            amount: fixture.xem,
            messageType: fixture.messageType,
            message: fixture.message)
    } else {
        announce = TransferTransactionHelper.generateMosaicTransferRequestAnnounce(
            publicKey: account.keyPair.publicKey,
            network: .testnet,
            recipientAddress: TestSettings.RECEIVER,
            mosaics: fixture.mosaics,
            messageType: fixture.messageType,
            message: fixture.message)
    }

    let requestAnnounce = RequestAnnounce.generateRequestAnnounce(requestAnnounce: announce, keyPair: account.keyPair)

    guard let response = Session.sendSyncWithTest(NISAPI.TransactionAnnounce(data: requestAnnounce.data, signature: requestAnnounce.signature)) else { return }
    print("\(response)")

    if !TestSettings.PRIVATE_KEY.isEmpty {
        TestUtils.checkResult(result: response)
    } else {
        TestUtils.checkResultIsInsufficientBalance(result: response)
    }
}





class TransferTransactionTest : ParameterizedTest {
    override class func createTestCases() -> [ParameterizedTest] {
        return self.testInvocations.map { TransferTransactionTest(invocation: $0) }
    }

    override class var fixtures: [Any] {
        get {
            return [
                TransferTransactionTestFixture(1),
                TransferTransactionTestFixture(0, "Message test", TransferTransactionHelper.MessageType.Plain),
                TransferTransactionTestFixture(0, "", TransferTransactionHelper.MessageType.Plain,
                                               [TransferMosaic(namespace: "nem", mosaic: "xem", quantity: 1, supply: 8_999_999_999, divisibility: 6)]),

            ]
        }
    }

    // Don't run test method. Run test class instead.
    func testTransfer() {
        let fixture = self.fixture as! TransferTransactionTestFixture
        testTransferTransaction(fixture: fixture)
    }
}


