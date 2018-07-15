//
//  Address.swift
//  NemSwift
//
//  Created by Kazuya Okada on 2017/11/15.
//  Copyright © 2017年 OpenApostille. All rights reserved.
//

import Foundation
import CryptoSwift
import Base32

public struct Address {
    
    public enum Network: UInt8 {
        case mijin = 0x60
        case mainnet = 0x68
        case testnet = 0x98
    }
    
    public let value:String
    public let network:Network
    
    public init(publicKey: [UInt8], network: Network) {
        self.network = network
        let pubKeyByteArray = publicKey
        let pubKeySha3 = Data(bytes: pubKeyByteArray).sha3(.keccak256)
        let pubKeyRipemd = RIPEMD.hexStringDigest(pubKeySha3.toHexString(), bitlength: 160) as String
        let pubKeyRipemdByteArrary = ConvertUtil.toByteArray(pubKeyRipemd)
        var networkByteArray = Array<UInt8>()
        networkByteArray.append(network.rawValue)
        let networkPrefixByteArray = networkByteArray + pubKeyRipemdByteArrary
        let networkPrefixSha3 = Data(bytes: networkPrefixByteArray).sha3(.keccak256).toHexString()
        let checksum = String(networkPrefixSha3.prefix(8))
        let addressByteStr = ConvertUtil.toHexString(networkPrefixByteArray) + checksum
        let addressByte = ConvertUtil.toByteArray(addressByteStr)
        self.value = base32Encode(addressByte)
    }
}
