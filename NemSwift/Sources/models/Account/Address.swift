//
//  Address.swift
//  NemSwift
//
//  Created by Kazuya Okada on 2017/11/15.
//  Copyright © 2017年 OpenApostille. All rights reserved.
//

import Foundation
import CryptoSwift

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
        self.value = base32StringFrom(data: addressByte)
    }
}


func base32StringFrom(data: [UInt8]) -> String {
    let encodingTable: [UInt8] = "ABCDEFGHIJKLMNOPQRSTUVWXYZ234567".bytes
    let paddingTable = [0,6,4,3,1]

    //                     Table 3: The Base 32 Alphabet
    //
    // Value Encoding  Value Encoding  Value Encoding  Value Encoding
    //     0 A             9 J            18 S            27 3
    //     1 B            10 K            19 T            28 4
    //     2 C            11 L            20 U            29 5
    //     3 D            12 M            21 V            30 6
    //     4 E            13 N            22 W            31 7
    //     5 F            14 O            23 X
    //     6 G            15 P            24 Y         (pad) =
    //     7 H            16 Q            25 Z
    //     8 I            17 R            26 2

    let dataLength = data.count
    var encodedBlocks = dataLength / 5
    //if (encodedBlocks + 1) >= (UInt.max / 8) { return nil }// NSUInteger overflow check
    let padding = paddingTable[dataLength % 5]
    if padding > 0 {
        encodedBlocks += 1
    }

    let encodedLength = encodedBlocks * 8

    var encodingBytes = [UInt8](repeating: 0, count: encodedLength)

    var rawBytesToProcess = dataLength
    var rawBaseIndex = 0
    var encodingBaseIndex = 0

    while( rawBytesToProcess >= 5 ) {
        let rawByte1 = data[rawBaseIndex]
        let rawByte2 = data[rawBaseIndex+1]
        let rawByte3 = data[rawBaseIndex+2]
        let rawByte4 = data[rawBaseIndex+3]
        let rawByte5 = data[rawBaseIndex+4]

        encodingBytes[encodingBaseIndex] = encodingTable[Int((rawByte1 >> 3) & 0x1F)]
        encodingBytes[encodingBaseIndex+1] = encodingTable[Int(((rawByte1 << 2) & 0x1C) | ((rawByte2 >> 6) & 0x03)) ]
        encodingBytes[encodingBaseIndex+2] = encodingTable[Int((rawByte2 >> 1) & 0x1F)]
        encodingBytes[encodingBaseIndex+3] = encodingTable[Int(((rawByte2 << 4) & 0x10) | ((rawByte3 >> 4) & 0x0F))]
        encodingBytes[encodingBaseIndex+4] = encodingTable[Int(((rawByte3 << 1) & 0x1E) | ((rawByte4 >> 7) & 0x01))]
        encodingBytes[encodingBaseIndex+5] = encodingTable[Int((rawByte4 >> 2) & 0x1F)]
        encodingBytes[encodingBaseIndex+6] = encodingTable[Int(((rawByte4 << 3) & 0x18) | ((rawByte5 >> 5) & 0x07))]
        encodingBytes[encodingBaseIndex+7] = encodingTable[Int(rawByte5 & 0x1F)]

        rawBaseIndex += 5
        encodingBaseIndex += 8
        rawBytesToProcess -= 5
    }

    let rest = dataLength-rawBaseIndex
    if rest < 5 && rest > 0 {
        let rawByte4 = rest >= 4 ? data[rawBaseIndex+3] : 0
        let rawByte3 = rest >= 3 ? data[rawBaseIndex+2] : 0
        let rawByte2 = rest >= 2 ? data[rawBaseIndex+1] : 0
        let rawByte1 = data[rawBaseIndex]

        encodingBytes[encodingBaseIndex] = encodingTable[Int((rawByte1 >> 3) & 0x1F)]
        encodingBytes[encodingBaseIndex+1] = encodingTable[Int(((rawByte1 << 2) & 0x1C) | ((rawByte2 >> 6) & 0x03)) ]
        encodingBytes[encodingBaseIndex+2] = encodingTable[Int((rawByte2 >> 1) & 0x1F)]
        encodingBytes[encodingBaseIndex+3] = encodingTable[Int(((rawByte2 << 4) & 0x10) | ((rawByte3 >> 4) & 0x0F))]
        encodingBytes[encodingBaseIndex+4] = encodingTable[Int(((rawByte3 << 1) & 0x1E) | ((rawByte4 >> 7) & 0x01))]
        encodingBytes[encodingBaseIndex+5] = encodingTable[Int((rawByte4 >> 2) & 0x1F)]
        encodingBytes[encodingBaseIndex+6] = encodingTable[Int((rawByte4 << 3) & 0x18)]
    }
    // compute location from where to begin inserting padding, it may overwrite some bytes from the partial block encoding
    // if their value was 0 (cases 1-3).
    encodingBaseIndex = encodedLength - padding
    for i in 0..<padding {
        encodingBytes[encodingBaseIndex + i] = Array("=".utf8)[0]
    }

    return String(bytes: encodingBytes, encoding: .utf8)!
}
