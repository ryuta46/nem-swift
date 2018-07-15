//
//  KeyPair.swift
//  NemSwift
//
//  Created by Kazuya Okada on 2017/11/15.
//  Copyright © 2017年 OpenApostille. All rights reserved.
//

import Foundation

public struct KeyPair {
    
    private static let PUBLIC_KEY_SIZE = 32
    private static let PRIVATE_KEY_SIZE = 64
    private static let PRIVATE_KEY_SEED_SIZE = 32
    private let SIGNATURE_SIZE = 64
    
    public let publicKey: [UInt8]
    public let privateKey: [UInt8]
    public let privateKeySeed: [UInt8]
    
    public func publicKeyHexString() -> String {
        return ConvertUtil.toHexString(publicKey)
    }
    
    public func privateKeyHexString() -> String {
        return ConvertUtil.toHexString(privateKey)
    }
    
    public func importKey() -> String {
        let swapedSeed = ConvertUtil.swapByteArray(privateKeySeed)
        return ConvertUtil.toHexString(swapedSeed)
    }
    
    public func sign(message: [UInt8]) -> [UInt8] {
        let signature = UnsafeMutablePointer<UInt8>.allocate(capacity: SIGNATURE_SIZE)
        ed25519_sha3_sign(signature,
                          ConvertUtil.toNativeArray(message),
                          message.count,
                          ConvertUtil.toNativeArray(publicKey),
                          ConvertUtil.toNativeArray(privateKey)
        )
        
        return ConvertUtil.toArray(signature, SIGNATURE_SIZE)
    }
    
    public static func generateKeyPair() -> KeyPair {
        var privateKeySeed: [UInt8] = []
        let nativeSeed = UnsafeMutablePointer<UInt8>.allocate(capacity: PRIVATE_KEY_SEED_SIZE)
        ed25519_create_seed(nativeSeed)
        privateKeySeed = ConvertUtil.toArray(nativeSeed, PRIVATE_KEY_SEED_SIZE)
        
        let privateKey = UnsafeMutablePointer<UInt8>.allocate(capacity: PRIVATE_KEY_SIZE)
        let publicKey = UnsafeMutablePointer<UInt8>.allocate(capacity: PUBLIC_KEY_SIZE)
        
        ed25519_sha3_create_keypair(publicKey, privateKey, ConvertUtil.toNativeArray(privateKeySeed))
        
        let keyPair = KeyPair(publicKey: ConvertUtil.toArray(publicKey, PUBLIC_KEY_SIZE),
                              privateKey: ConvertUtil.toArray(privateKey, PRIVATE_KEY_SIZE),
                              privateKeySeed: privateKeySeed)
        return keyPair
    }
    
    public static func repairKeyPair(_ importKey: String) -> KeyPair {
        var privateKeySeed: [UInt8] = []
        let importKeyByteArray = ConvertUtil.toByteArray(importKey)
        let nativeSeed = ConvertUtil.swapByteArray(importKeyByteArray)
        privateKeySeed = ConvertUtil.toArray(nativeSeed, PRIVATE_KEY_SEED_SIZE)
        
        let privateKey = UnsafeMutablePointer<UInt8>.allocate(capacity: PRIVATE_KEY_SIZE)
        let publicKey = UnsafeMutablePointer<UInt8>.allocate(capacity: PUBLIC_KEY_SIZE)
        
        ed25519_sha3_create_keypair(publicKey, privateKey, ConvertUtil.toNativeArray(privateKeySeed))
        
        let keyPair = KeyPair(publicKey: ConvertUtil.toArray(publicKey, PUBLIC_KEY_SIZE),
                              privateKey: ConvertUtil.toArray(privateKey, PRIVATE_KEY_SIZE),
                              privateKeySeed: privateKeySeed)
        return keyPair
    }
}
