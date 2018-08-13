//
//  MessageEncryptionTest.swift
//  NemSwiftTests
//
//  Created by Taizo Kusuda on 2018/08/13.
//  Copyright © 2018年 ryuta46. All rights reserved.
//

import Foundation
import XCTest
@testable import NemSwift

class MessageEncryptionTest: XCTestCase {
    func testSharedKey() {
        for _ in 0..<10 {
            let saltSize = 32
            let saltNative = UnsafeMutablePointer<UInt8>.allocate(capacity: saltSize)
            create_random_bytes(saltNative, saltSize)
            let salt = ConvertUtil.toArray(saltNative, saltSize)
            
            for _ in 0..<10 {
                let account = Account.generateAccount(network: .mainnet)
                let peer = Account.generateAccount(network: .mainnet)
                
                let sharedKey1 = MessageEncryption.calculateSharedKey(keys: account.keyPair, peerPublicKey: peer.keyPair.publicKey, salt: salt)
                let sharedKey2 = MessageEncryption.calculateSharedKey(keys: peer.keyPair, peerPublicKey: account.keyPair.publicKey, salt: salt)
                
                XCTAssertEqual(sharedKey1, sharedKey2)
            }
        }
    }
    
}



class MessageEncryptionValidatePairTest: ParameterizedTest {
    override class func createTestCases() -> [ParameterizedTest] {
        return self.testInvocations.map { MessageEncryptionValidatePairTest(invocation: $0) }
    }
    
    override class var fixtures: [Any] {
        get {
            return [
                "TEST MESSAGE",
                "",
                "マルチバイト文字列"
            ]
        }
    }
    
    func testValidatePair() {
        let message = self.fixture as! String
        let messageBytes = Array(message.bytes)
        for _ in 0..<100 {
            let account = Account.generateAccount(network: .mainnet)
            let peer = Account.generateAccount(network: .mainnet)
            
            let encrypted = try! MessageEncryption.encrypt(senderKeys: account.keyPair, receiverPublicKey: peer.keyPair.publicKey, message: messageBytes)
            let decrypted = try! MessageEncryption.decrypt(receiverKeys: peer.keyPair, senderPublicKey: account.keyPair.publicKey, mergedEncryptedMessage: encrypted)
            
            let decryptedMessage = String(bytes: decrypted, encoding: .utf8)
            if decryptedMessage != nil {
                XCTAssertEqual(message, decryptedMessage!)
            } else {
                XCTAssertNotNil(decryptedMessage)
            }
        }
    }
    
}


struct DecryptFixture {
    let message: String
    let expected: String
    
    init(_ message: String, _ expected: String) {
        self.message = message
        self.expected = expected
    }
    
}

class MessageEncryptionDecryptTest : ParameterizedTest {
    override class func createTestCases() -> [ParameterizedTest] {
        return self.testInvocations.map { MessageEncryptionDecryptTest(invocation: $0) }
    }
    
    override class var fixtures: [Any] {
        get {
            return [
                DecryptFixture("f05b30eb18f1243f90e170b376e3fd61a903d202aad70af6b8f1eb3afce0274372022d55953b3ae0524635680af686e6a2fe6934e47b000d2433fbf84e8a42b0d0f35bf387569eac17221a5af9721cdd","TEST ENCRYPT MESSAGE")
            ]
        }
    }
    
    func testDecrypt() {
        guard !TestSettings.PRIVATE_KEY.isEmpty else {
            return
        }
        let fixture = self.fixture as! DecryptFixture

        let account = Account.repairAccount(TestSettings.PRIVATE_KEY, network: .testnet)
        
        let decrypted = try! MessageEncryption.decrypt(receiverKeys: account.keyPair,
                                                  senderPublicKey: ConvertUtil.toByteArray(TestSettings.RECEIVER_PUBLIC),
                                                  mergedEncryptedMessage: ConvertUtil.toByteArray(fixture.message))
        
        XCTAssertEqual(fixture.expected, String(bytes: decrypted, encoding: .utf8))
    }
}




