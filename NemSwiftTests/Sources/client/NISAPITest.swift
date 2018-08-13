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
import NemSwift

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
            XCTFail("Communication Error \(error)")
        }
        return nil
        //fatalError("Nerver execute")
    }

}

class NISAPITest: XCTestCase {
    
    override func setUp() {
        super.setUp()
        NemSwiftConfiguration.defaultBaseURL = TestSettings.TEST_HOST
        NemSwiftConfiguration.logLevel = .debug
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
        guard let response = Session.sendSyncWithTest(NISAPI.AccountGetForwarded(
            baseURL: TestSettings.MAIN_HOST,
            address: "NC2ZQKEFQIL3JZEOB2OZPWXWPOR6LKYHIROCR7PK")) else { return }
        print("\(response)")
        XCTAssertEqual("NALICE2A73DLYTP4365GNFCURAUP3XVBFO7YNYOW", response.account.address)
    }

    func testAccountGetForwardedMyself() {
        guard let response = Session.sendSyncWithTest(NISAPI.AccountGetForwarded(address: TestSettings.ADDRESS)) else { return }
        print("\(response)")
        XCTAssertEqual(TestSettings.ADDRESS, response.account.address)
    }

    func testAccountGetForwardedFromPublicKey() {
        guard let response = Session.sendSyncWithTest(NISAPI.AccountGetForwardedFromPublicKey(
            baseURL: TestSettings.MAIN_HOST,
            publicKey: "bdd8dd702acb3d88daf188be8d6d9c54b3a29a32561a068b25d2261b2b2b7f02")) else { return }
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
            else if metaDataPair.transaction.type == TransactionHelper.TransactionType.Multisig.transactionTypeBytes() {
                XCTAssertEqual(TestSettings.ADDRESS, metaDataPair.transaction.otherTrans?.recipient)
            }
        }
    }
    func testAccountTransfersIncomingId() {
        var id: Int? = nil

        var response = Session.sendSyncWithTest(NISAPI.AccountTransfersIncoming(address: TestSettings.ADDRESS, id: id ))!
        var hashes: [String] = []
        while(!response.data.isEmpty) {
            print("\(response)")

            response.data.forEach { metaDataPair in
                let hash = metaDataPair.meta.hash.data!
                // All hash is differ
                XCTAssertFalse(hashes.contains(hash))
                hashes.append(hash)
            }

            id = response.data.last!.meta.id
            response = Session.sendSyncWithTest(NISAPI.AccountTransfersIncoming(address: TestSettings.ADDRESS, id: id ))!
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
    func testAccountTransfersOutgoingId() {
        var id: Int? = nil

        var response = Session.sendSyncWithTest(NISAPI.AccountTransfersOutgoing(address: TestSettings.ADDRESS, id: id ))!
        var hashes: [String] = []
        while(!response.data.isEmpty) {
            print("\(response)")

            response.data.forEach { metaDataPair in
                let hash = metaDataPair.meta.hash.data!
                // All hash is differ
                XCTAssertFalse(hashes.contains(hash))
                hashes.append(hash)
            }

            id = response.data.last!.meta.id
            response = Session.sendSyncWithTest(NISAPI.AccountTransfersOutgoing(address: TestSettings.ADDRESS, id: id ))!
        }
    }


    func testAccountTransfersAll() {
        guard let response = Session.sendSyncWithTest(NISAPI.AccountTransfersAll(address: TestSettings.ADDRESS, hash: nil, id: nil )) else { return }
        print("\(response)")
        XCTAssertFalse(response.data.isEmpty)

        response.data.forEach { metaDataPair in
            if metaDataPair.transaction.type == TransactionHelper.TransactionType.Transfer.transactionTypeBytes() {
                XCTAssertTrue(TestSettings.ADDRESS == metaDataPair.transaction.recipient || TestSettings.PUBLIC_KEY ==  metaDataPair.transaction.signer)
            }
        }
    }

    func testAccountTransfersAllId() {
        var id: Int? = nil

        var response = Session.sendSyncWithTest(NISAPI.AccountTransfersAll(address: TestSettings.ADDRESS, id: id ))!
        var hashes: [String] = []
        while(!response.data.isEmpty) {
            print("\(response)")

            response.data.forEach { metaDataPair in
                let hash = metaDataPair.meta.hash.data!
                // All hash is differ
                XCTAssertFalse(hashes.contains(hash))
                hashes.append(hash)
            }

            id = response.data.last!.meta.id
            response = Session.sendSyncWithTest(NISAPI.AccountTransfersAll(address: TestSettings.ADDRESS, id: id ))!
        }
    }

    /*
     // This test is not execute because multisig transactions when the recipient and sender is same counts twice.
    func testAccountTransfersAllHashId() {
        var allHashes: [String] = []
        var id: Int? = nil
        var response = Session.sendSyncWithTest(NISAPI.AccountTransfersAll(address: TestSettings.ADDRESS, id: id ))!
        while(!response.data.isEmpty) {
            response.data.forEach { metaDataPair in  allHashes.append(metaDataPair.meta.hash.data!) }
            id = response.data.last!.meta.id
            response = Session.sendSyncWithTest(NISAPI.AccountTransfersAll(address: TestSettings.ADDRESS, id: id ))!
        }

        id = nil
        response = Session.sendSyncWithTest(NISAPI.AccountTransfersIncoming(address: TestSettings.ADDRESS, id: id ))!
        while(!response.data.isEmpty) {
            response.data.forEach { metaDataPair in
                let hash = metaDataPair.meta.hash.data!
                XCTAssertTrue(allHashes.contains(hash), "No hash \(hash)")
                allHashes.remove(at: allHashes.index(of: hash)!)
            }
            id = response.data.last!.meta.id
            response = Session.sendSyncWithTest(NISAPI.AccountTransfersIncoming(address: TestSettings.ADDRESS, id: id ))!
        }

        id = nil
        response = Session.sendSyncWithTest(NISAPI.AccountTransfersOutgoing(address: TestSettings.ADDRESS, id: id ))!
        while(!response.data.isEmpty) {
            response.data.forEach { metaDataPair in
                let hash = metaDataPair.meta.hash.data!
                XCTAssertTrue(allHashes.contains(hash), "No hash \(hash)")
                allHashes.remove(at: allHashes.index(of: hash)!)
            }
            id = response.data.last!.meta.id
            response = Session.sendSyncWithTest(NISAPI.AccountTransfersOutgoing(address: TestSettings.ADDRESS, id: id ))!
        }
        XCTAssertTrue(allHashes.isEmpty)
    }
    */


    func testAccountUnconfirmedTransactions() {
        var address = TestSettings.ADDRESS
        if TestSettings.PRIVATE_KEY.isEmpty {
            address = Account.generateAccount(network: .testnet).address.value
        } else {
            testTransferTransaction(fixture: TransferTransactionTestFixture(0))
        }


        guard let response = Session.sendSyncWithTest(NISAPI.AccountUnconfirmedTransactions(address: address)) else { return }
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
        guard let response = Session.sendSyncWithTest(NISAPI.NamespaceMosaicDefintionPage(namespace: "ttech")) else { return }
        print("\(response)")

        XCTAssertFalse(response.data.isEmpty)

        response.data.forEach { metaDataPair in
            XCTAssertEqual(TestSettings.RECEIVER_PUBLIC, metaDataPair.mosaic.creator)

            if metaDataPair.mosaic.id.name == "ryuta" {
                XCTAssertEqual("Test mosaic for NEM API", metaDataPair.mosaic.description)
                XCTAssertEqual(0, metaDataPair.mosaic.divisibility)
                XCTAssertEqual(1_000_000, metaDataPair.mosaic.initialSupply)
                XCTAssertEqual(true, metaDataPair.mosaic.supplyMutable)
                XCTAssertEqual(true, metaDataPair.mosaic.transferable)
                XCTAssertNil(metaDataPair.mosaic.levy)
            }
        }
    }


}


class TransferTransactionTestFixture {
    let xem: UInt64
    let message: String
    let messageType: TransferTransactionHelper.MessageType
    let mosaics: [TransferMosaic]

    init(_ xem: UInt64, _ message: String = "", _ messageType: TransferTransactionHelper.MessageType = .plain, _ mosaics: [TransferMosaic] = []) {
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
        XCTAssertEqual(TestSettings.ADDRESS, account.address.value)
    } else {
        account = Account.generateAccount(network: .testnet)
    }

    let messageBytes: [UInt8]
    if fixture.messageType == .plain {
        messageBytes = Array(fixture.message.utf8)
    } else {
        messageBytes = try! MessageEncryption.encrypt(senderKeys: account.keyPair,
                                                      receiverPublicKey: ConvertUtil.toByteArray(TestSettings.RECEIVER_PUBLIC),
                                                      message: Array(fixture.message.utf8))
    }
    
    let announce: [UInt8]

    if fixture.mosaics.isEmpty {
        announce = TransferTransactionHelper.generateTransferRequestAnnounce(
            publicKey: account.keyPair.publicKey,
            network: .testnet,
            recipientAddress: TestSettings.RECEIVER,
            amount: fixture.xem,
            messageType: fixture.messageType,
            message: messageBytes)
    } else {
        announce = TransferTransactionHelper.generateMosaicTransferRequestAnnounce(
            publicKey: account.keyPair.publicKey,
            network: .testnet,
            recipientAddress: TestSettings.RECEIVER,
            mosaics: fixture.mosaics,
            messageType: fixture.messageType,
            message: messageBytes)
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
    override func setUp() {
        super.setUp()
        NemSwiftConfiguration.defaultBaseURL = TestSettings.TEST_HOST
        NemSwiftConfiguration.logLevel = .debug
        // Put setup code here. This method is called before the invocation of each test method in the class.
    }
    
    override class func createTestCases() -> [ParameterizedTest] {
        return self.testInvocations.map { TransferTransactionTest(invocation: $0) }
    }

    override class var fixtures: [Any] {
        get {
            return [
                TransferTransactionTestFixture(1),
                TransferTransactionTestFixture(0, "Message test", .plain),
                TransferTransactionTestFixture(0, "TEST ENCRYPT MESSAGE", .secure),
                TransferTransactionTestFixture(0, "", .plain,
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


class MultisigTransactionTest: XCTestCase {
    override func setUp() {
        super.setUp()
        NemSwiftConfiguration.defaultBaseURL = TestSettings.TEST_HOST
        NemSwiftConfiguration.logLevel = .debug
        // Put setup code here. This method is called before the invocation of each test method in the class.
    }
    

    func testMultisigAggregateModificationTransactionMyself() {
        let multisig = Account.generateAccount(network: .testnet)
    
        print(multisig.address)
        print(multisig.keyPair.importKey())

        if TestSettings.PRIVATE_KEY.isEmpty {
            let ownerAccount = Account.generateAccount(network: .testnet)
            let multisigRequest = MultisigTransactionHelper.generateAggregateModificationRequestAnnounce(
                publicKey: multisig.keyPair.publicKey,
                network: .testnet,
                modifications: [MultisigCosignatoryModification(modificationType: 1, cosignatoryAccount: ownerAccount.keyPair.publicKeyHexString())],
                minCosignatoriesRelativeChange: 1)


            let requestAnnounce = RequestAnnounce.generateRequestAnnounce(requestAnnounce: multisigRequest, keyPair: multisig.keyPair)
            guard let response = Session.sendSyncWithTest(NISAPI.TransactionAnnounce(requestAnnounce: requestAnnounce)) else { return }
            print("\(response)")

            TestUtils.checkResultIsInsufficientBalance(result: response)
            return
        }
        let account = Account.repairAccount(TestSettings.PRIVATE_KEY, network: .testnet)
    
        let transfer = TransferTransactionHelper.generateTransferRequestAnnounce(publicKey: account.keyPair.publicKey, network: .testnet, recipientAddress: multisig.address.value, amount: MultisigTransactionHelper.multisigAggregateModificationFee)

        // first, transfer xem to create transaction
        let requestAnnounce = RequestAnnounce.generateRequestAnnounce(requestAnnounce: transfer, keyPair: account.keyPair)
        guard let response = Session.sendSyncWithTest(NISAPI.TransactionAnnounce(requestAnnounce: requestAnnounce)) else { return }
        print("\(response)")
        
        TestUtils.checkResult(result: response)

        // wait for transaction confirmed
        XCTAssertTrue(TestUtils.waitUntilIncomingIsNotEmpty(address: multisig.address.value))

        // second, create multisig transaction
        let modificationRequest = MultisigTransactionHelper.generateAggregateModificationRequestAnnounce(
            publicKey: multisig.keyPair.publicKey,
            network: .testnet,
            modifications: [MultisigCosignatoryModification(modificationType: 1, cosignatoryAccount: account.keyPair.publicKeyHexString())],
            minCosignatoriesRelativeChange: 1)

        let modificationRequestAnnounce = RequestAnnounce.generateRequestAnnounce(requestAnnounce: modificationRequest, keyPair: multisig.keyPair)
        guard let modificationResponse = Session.sendSyncWithTest(NISAPI.TransactionAnnounce(requestAnnounce: modificationRequestAnnounce)) else { return }
        print("\(modificationResponse)")

        TestUtils.checkResult(result: modificationResponse)
        
        // wait for transaction confirmed
        XCTAssertTrue(TestUtils.waitUntilIncomingIsNotEmpty(address: multisig.address.value))

        guard let multisigAccountInfo = Session.sendSyncWithTest(NISAPI.AccountGet(address: multisig.address.value)) else { return }
        
        print(multisigAccountInfo)
        XCTAssertEqual(account.address.value, multisigAccountInfo.meta.cosignatories.first?.address)
    }

    func testMultisigAggregateModificationTransaction() {
        let account: Account
        if !TestSettings.PRIVATE_KEY.isEmpty {
            account = Account.repairAccount(TestSettings.PRIVATE_KEY, network: .testnet)
        } else {
            account = Account.generateAccount(network: .testnet)
            print("Generated temporary account.")
            print(account.address)
            print(account.keyPair.importKey())
        }
        let signer: Account
        if !TestSettings.SIGNER_PRIVATE_KEY.isEmpty {
            signer = Account.repairAccount(TestSettings.SIGNER_PRIVATE_KEY, network: .testnet)
        } else {
            signer = Account.generateAccount(network: .testnet)
            print("Generated temporary signer.")
            print(signer.address)
            print(signer.keyPair.importKey())
        }

        if true {
            // Create inner transaction of which deletes signer and decrements minimum cosignatory.
            let modificationTransaction = MultisigTransactionHelper.generateAggregateModification(
                publicKey: ConvertUtil.toByteArray(TestSettings.MULTISIG_PUBLIC_KEY),
                network: .testnet,
                modifications: [MultisigCosignatoryModification(modificationType: ModificationType.delete.rawValue, cosignatoryAccount: signer.keyPair.publicKeyHexString())],
                minCosignatoriesRelativeChange: -1)

            // Create multisig transaction
            let multisigRequest = MultisigTransactionHelper.generateMultisigRequestAnnounce(
                publicKey: account.keyPair.publicKey,
                network: .testnet,
                innerTransaction: modificationTransaction)
            
            guard let multisigResult = Session.sendSyncWithTest(NISAPI.TransactionAnnounce(requestAnnounce: multisigRequest, keyPair: account.keyPair)) else { return }

            print(multisigResult)
            
            if TestSettings.PRIVATE_KEY.isEmpty || TestSettings.SIGNER_PRIVATE_KEY.isEmpty {
                TestUtils.checkResultIsMultisigNotACosigner(result: multisigResult)
                return
            } else {
                TestUtils.checkResult(result: multisigResult)
            }
            
            // Sign the transaction
            guard let unconfirmedTransactions = Session.sendSyncWithTest(NISAPI.AccountUnconfirmedTransactions(address: signer.address.value)) else { return }
            print(unconfirmedTransactions)
            
            guard let hash = unconfirmedTransactions.data.first?.meta.data else {
                XCTAssertTrue(false, "Failed to load hash of unconfirmed transactions")
                return
            }
            
            let signatureRequest = MultisigTransactionHelper.generateSignatureRequestAnnounce(
                publicKey: signer.keyPair.publicKey,
                network: .testnet,
                otherHash: hash,
                otherAccount: TestSettings.MULTISIG_ADDRESS)
            
            guard let signatureResult = Session.sendSyncWithTest(NISAPI.TransactionAnnounce(requestAnnounce: signatureRequest, keyPair: signer.keyPair)) else { return }

            print(signatureResult)
            TestUtils.checkResult(result: signatureResult)
            
            print("... Waiting for transaction confirmed of aggregate modification ...")
            
            // wait for transaction confirmed
            XCTAssertTrue(TestUtils.waitUntilConfirmedOutgoing(address: account.address.value, hash: multisigResult.transactionHash.data!))
            
            guard let multisigAccountInfo = Session.sendSyncWithTest(NISAPI.AccountGet(address: TestSettings.MULTISIG_ADDRESS)) else { return }
            
            print(multisigAccountInfo)
            XCTAssertEqual(1, multisigAccountInfo.account.multisigInfo?.cosignatoriesCount)
            XCTAssertNotNil(multisigAccountInfo.meta.cosignatories.first(where: { $0.address == account.address.value}))
            XCTAssertNil(multisigAccountInfo.meta.cosignatories.first(where: { $0.address == signer.address.value}))
        }

        if true {
            // Create inner transaction of which adds signer and increments minimum cosignatory.
            let modificationTransaction = MultisigTransactionHelper.generateAggregateModification(
                publicKey: ConvertUtil.toByteArray(TestSettings.MULTISIG_PUBLIC_KEY),
                network: .testnet,
                modifications: [MultisigCosignatoryModification(modificationType: ModificationType.add.rawValue, cosignatoryAccount: signer.keyPair.publicKeyHexString())],
                minCosignatoriesRelativeChange: 1)

            
            // Create multisig transaction
            let multisigRequest = MultisigTransactionHelper.generateMultisigRequestAnnounce(
                publicKey: account.keyPair.publicKey,
                network: .testnet,
                innerTransaction: modificationTransaction)
            
            guard let multisigResult = Session.sendSyncWithTest(NISAPI.TransactionAnnounce(requestAnnounce: multisigRequest, keyPair: account.keyPair)) else { return }
            
            print(multisigResult)
            TestUtils.checkResult(result: multisigResult)

            print("... Waiting for transaction confirmed of aggregate modification ...")
            
            // wait for transaction confirmed
            XCTAssertTrue(TestUtils.waitUntilConfirmedOutgoing(address: account.address.value, hash: multisigResult.transactionHash.data!))

            guard let multisigAccountInfo = Session.sendSyncWithTest(NISAPI.AccountGet(address: TestSettings.MULTISIG_ADDRESS)) else { return }
            
            print(multisigAccountInfo)
            XCTAssertEqual(2, multisigAccountInfo.account.multisigInfo?.cosignatoriesCount)
            XCTAssertNotNil(multisigAccountInfo.meta.cosignatories.first(where: { $0.address == account.address.value}))
            XCTAssertNotNil(multisigAccountInfo.meta.cosignatories.first(where: { $0.address == signer.address.value}))
        }
    }
    
    func testMultisigSignatureTransaction() {
        let account: Account
        if !TestSettings.PRIVATE_KEY.isEmpty {
            account = Account.repairAccount(TestSettings.PRIVATE_KEY, network: .testnet)
        } else {
            account = Account.generateAccount(network: .testnet)
            print("Generated temporary account.")
            print(account.address)
            print(account.keyPair.importKey())
        }
        let signer: Account
        if !TestSettings.SIGNER_PRIVATE_KEY.isEmpty {
            signer = Account.repairAccount(TestSettings.SIGNER_PRIVATE_KEY, network: .testnet)
        } else {
            signer = Account.generateAccount(network: .testnet)
            print("Generated temporary signer.")
            print(signer.address)
            print(signer.keyPair.importKey())
        }

        // Create inner transaction of which transfers XEM
        let transferTransaction = TransferTransactionHelper.generateTransfer(
            publicKey: ConvertUtil.toByteArray(TestSettings.MULTISIG_PUBLIC_KEY),
            network: .testnet,
            recipientAddress: TestSettings.ADDRESS,
            amount: 10
        )
        
    
        // Create multisig transaction
        let multisigRequest = MultisigTransactionHelper.generateMultisigRequestAnnounce(
            publicKey: account.keyPair.publicKey,
            network: .testnet,
            innerTransaction: transferTransaction)
        
        guard let multisigResult = Session.sendSyncWithTest(NISAPI.TransactionAnnounce(requestAnnounce: multisigRequest, keyPair: account.keyPair)) else { return }

        print(multisigResult)
    
        if TestSettings.SIGNER_PRIVATE_KEY.isEmpty {
            TestUtils.checkResultIsMultisigNotACosigner(result: multisigResult)
            return
        }
    
        if TestSettings.PRIVATE_KEY.isEmpty {
            TestUtils.checkResultIsInsufficientBalance(result: multisigResult)
            return
        } else {
            TestUtils.checkResult(result: multisigResult)
        }
        
        
        // Sign the transaction
        guard let unconfirmedTransactions = Session.sendSyncWithTest(NISAPI.AccountUnconfirmedTransactions(address: signer.address.value)) else { return }
        print(unconfirmedTransactions)
        
        
        guard let hash = unconfirmedTransactions.data.first?.meta.data else {
            XCTAssertTrue(false, "Failed to load hash of unconfirmed transactions")
            return
        }
    
        let signatureRequest = MultisigTransactionHelper.generateSignatureRequestAnnounce(
            publicKey: signer.keyPair.publicKey,
            network: .testnet,
            otherHash: hash,
            otherAccount: TestSettings.MULTISIG_ADDRESS)
        
        guard let signatureResult = Session.sendSyncWithTest(NISAPI.TransactionAnnounce(requestAnnounce: signatureRequest, keyPair: signer.keyPair)) else { return }
        
        print(signatureResult)
        TestUtils.checkResult(result: signatureResult)
    }

}


struct ReadMessageFixture {
    let transactionHash: String
    let expected: String
    
    init(_ transactionHash: String, _ expected: String) {
        self.transactionHash = transactionHash
        self.expected = expected
    }
}
        
class ReadMessageTest : ParameterizedTest {
    override func setUp() {
        super.setUp()
        NemSwiftConfiguration.defaultBaseURL = TestSettings.TEST_HOST
        NemSwiftConfiguration.logLevel = .debug
        // Put setup code here. This method is called before the invocation of each test method in the class.
    }
    
    override class func createTestCases() -> [ParameterizedTest] {
        return self.testInvocations.map { ReadMessageTest(invocation: $0) }
    }
    
    override class var fixtures: [Any] {
        get {
            return [
                ReadMessageFixture("9eda9271565628765caf51e9c89fadb41ed7413ed94c62e4d75870f1197d3872", "TEST PLAIN TEXT MESSAGE"),
                ReadMessageFixture("e19c81ec1ab9d2c96edd5418933054e2edfedd483d530324acab533153e09db3", "TEST ENCRYPTED MESSAGE")
            ]
        }
    }
    
    func testReadMessage() {
        let fixture = self.fixture as! ReadMessageFixture
        
        var id: Int? = nil
        var transaction: TransactionMetaDataPair? = nil
        repeat {
            let transactions = Session.sendSyncWithTest(NISAPI.AccountTransfersIncoming(address: TestSettings.ADDRESS, id: id))
            transactions?.data.forEach {
                if ($0.meta.hash.data == fixture.transactionHash) {
                    transaction = $0
                    return
                }
            }
            if transaction != nil {
                break
            }
            guard let lastId = transactions?.data.last?.meta.id else {
                break
            }
            id = lastId
        } while(transaction != nil)
        
        XCTAssertNotNil(transaction)
        
        let messageObject = transaction!.transaction.message
        XCTAssertNotNil(messageObject)
        
        let messageBytes = ConvertUtil.toByteArray(messageObject!.payload!)
        
        let message: String
        if (messageObject!.type! == TransferTransactionHelper.MessageType.plain.rawValue) {
            message = String(bytes: messageBytes, encoding: .utf8)!
        } else {
            guard !TestSettings.PRIVATE_KEY.isEmpty else {
                return
            }
            let account = Account.repairAccount(TestSettings.PRIVATE_KEY, network: .testnet)
            let decryptedBytes = try! MessageEncryption.decrypt(receiverKeys: account.keyPair,
                                                           senderPublicKey: ConvertUtil.toByteArray(TestSettings.RECEIVER_PUBLIC),
                                                           mergedEncryptedMessage: messageBytes)
            message = String(bytes: decryptedBytes, encoding: .utf8)!
        }
        
        XCTAssertEqual(fixture.expected, message)
    }
    
    
    
}



