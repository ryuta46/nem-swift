//
//  MessageEncryption.swift
//  NemSwift
//
//  Created by Taizo Kusuda on 2018/08/13.
//  Copyright © 2018年 ryuta46. All rights reserved.
//

import Foundation
import CryptoSwift

public class MessageEncryption {
    static let KEY_LENGTH = 256 / 8
    static let BLOCK_SIZE = 16
    
    
    /**
     * Encrypts message bytes.
     * @param senderKeys The sender KeyPair.
     * @param receiverPublicKey The public key of the receiver.
     * @param message Message UTF-8 bytes
     * @return Encrypted message.
     * @throws EncryptionException If description of the given message has failed.
     */
    public static func encrypt(senderKeys: KeyPair, receiverPublicKey: [UInt8], message: [UInt8]) throws -> [UInt8] {
        let salt = createRandomBytesOf(KEY_LENGTH)
        let iv = createRandomBytesOf(BLOCK_SIZE)
        
        let sharedKey = calculateSharedKey(keys: senderKeys, peerPublicKey: receiverPublicKey, salt: salt)


        do {
            let aes = try AES(key: sharedKey, blockMode: CBC(iv: iv), padding: .pkcs7)
            
            let encryptedMessage = try aes.encrypt(message)
            
            return salt + iv + encryptedMessage
        }
    }
    
    /**
     * Decrypts message bytes.
     * @param receiverKeyPair The receiver KeyPair.
     * @param senderPublicKey
     * @return Decrypted message UTF-8 bytes.
     * @throws EncryptionException If description of the given message has failed.
     */
    public static func decrypt(receiverKeys: KeyPair, senderPublicKey: [UInt8], mergedEncryptedMessage: [UInt8]) throws -> [UInt8] {
        let salt = mergedEncryptedMessage[0..<KEY_LENGTH].map { $0 }
        let iv = mergedEncryptedMessage[KEY_LENGTH..<KEY_LENGTH + BLOCK_SIZE].map { $0 }
        let encryptedMessage = mergedEncryptedMessage.dropFirst(KEY_LENGTH + BLOCK_SIZE)
        
        let sharedKey = calculateSharedKey(keys: receiverKeys, peerPublicKey: senderPublicKey, salt: salt)

        do {
            let aes = try AES(key: sharedKey, blockMode: CBC(iv: iv), padding: .pkcs7)
            
            let message = try aes.decrypt(encryptedMessage)
            
            return message
        }
    }
    
    
    static func calculateSharedKey(keys: KeyPair, peerPublicKey: [UInt8], salt: [UInt8]) -> [UInt8] {
        let sharedKeyNative = UnsafeMutablePointer<UInt8>.allocate(capacity: KEY_LENGTH)
        
        create_shared_key(sharedKeyNative, ConvertUtil.toNativeArray(peerPublicKey), ConvertUtil.toNativeArray(keys.privateKey), ConvertUtil.toNativeArray(salt))

        return ConvertUtil.toArray(sharedKeyNative, KEY_LENGTH)
    }
    
    static func createRandomBytesOf(_ length: Int) -> [UInt8] {
        let native = UnsafeMutablePointer<UInt8>.allocate(capacity: length)
        create_random_bytes(native, length)
        return ConvertUtil.toArray(native, length)
    }
}
