//
//  TransferTransactionHelper.swift
//  NemSwift
//
//  Created by Kazuya Okada on 2017/11/22.
//  Copyright © 2017年 OpenApostille. All rights reserved.
//

import Foundation

struct TransferMosaic {
    let namespace: String
    let mosaic: String
    let quantity: UInt64
}

class TransferTransactionHelper: TransactionHelper {
    
    enum MessageType: UInt32 {
        case Plain = 1
        case Secure = 2
    }
    
    let recipientAddress: String
    let amount: UInt64
    let messageType: MessageType
    let message: String
    let mosaics: [TransferMosaic]?
    
    init(publicKey: [UInt8], network: Network, recipientAddress: String, amount: UInt64, messageType: MessageType, message: String, mosaics: [TransferMosaic]?) {
        self.recipientAddress = recipientAddress
        self.amount = amount
        self.messageType = messageType
        self.message = message
        self.mosaics = mosaics
        
        super.init(type: .Transfer, publicKey: publicKey, network: network)
    }
    
    static func generateTransferRequestAnnounce(publicKey: [UInt8], network: Network, recipientAddress: String, amount: UInt64, messageType: MessageType, message: String) -> [UInt8] {
        let announce = TransferTransactionHelper(publicKey: publicKey, network: network,
                                                 recipientAddress: recipientAddress, amount: amount,
                                                 messageType: messageType, message: message, mosaics: nil)
        return announce.generateRequestAnnounce()
    }
    
    static func generateMosaicTransferRequestAnnounce(publicKey: [UInt8], network: Network, recipientAddress: String, mosaics: [TransferMosaic], messageType: MessageType, message: String) -> [UInt8] {
        
        let amount = (UInt64)(1_000_000)
        
        let announce = TransferTransactionHelper(publicKey: publicKey, network: network, recipientAddress: recipientAddress, amount: amount, messageType: messageType, message: message, mosaics: mosaics)
        
        return announce.generateRequestAnnounce()
    }
    
    public func generateRequestAnnounce() -> [UInt8] {
        let commonField = generateCommonTransactionField(transactionFee: transferFee())
        
        return commonField +
            ConvertUtil.toByteArrayWithLittleEndian(UInt32(recipientAddress.count)) +
            Array(recipientAddress.utf8) as [UInt8] +
            ConvertUtil.toByteArrayWithLittleEndian(amount) +
            messageBytes() +
            mosaicBytes()
    }
    
    private func messagePayloadBytes() -> [UInt8] {
        // TODO: 暗号化は後で対応する
        return Array(message.utf8)
    }
    
    private func messageLength() -> UInt32 {
        return UInt32(4) + UInt32(4) + (UInt32)(messagePayloadBytes().count)
    }
    
    private func transferFee() -> UInt64 {
        return xemTransferFee() + messageTransferFee()
    }
    
    private func xemTransferFee() -> UInt64 {
        return UInt64(max(50_000, min(((amount / 10_000_000_000) * 50_000), (UInt64)(TransactionHelper.maximumXemTransferFee))))
    }
    
    private func messageTransferFee() -> UInt64 {
        let count = messagePayloadBytes().count
        return (UInt64)(count > 0 ? 50_000 * UInt(1 + message.lengthOfBytes(using: .utf8) / 32) : 0)
    }
    
    private func messageBytes() -> [UInt8] {
        if (message.isEmpty) {
            return ConvertUtil.toByteArrayWithLittleEndian(UInt32(0))
        } else {
            return ConvertUtil.toByteArrayWithLittleEndian(messageLength()) +
                ConvertUtil.toByteArrayWithLittleEndian(messageType.rawValue) +
                ConvertUtil.toByteArrayWithLittleEndian((UInt32)(messagePayloadBytes().count)) +
                messagePayloadBytes()
        }
    }
    
    private func mosaicBytes() -> [UInt8] {
        guard let mosaics = mosaics else {
            return ConvertUtil.toByteArrayWithLittleEndian(UInt32(0))
        }
        
        var mosaicsBytes: [UInt8]?
        let mosaicNumBytes = ConvertUtil.toByteArrayWithLittleEndian(UInt32(mosaics.count))
        
        for mosaic in mosaics {
            let mosaicNameSpaceIdBytes = Array(mosaic.namespace.utf8) as [UInt8]
            let mosaicNameBytes = Array(mosaic.mosaic.utf8) as [UInt8]
            let mosaicIdStructLength = 4 + mosaicNameSpaceIdBytes.count + 4 + mosaicNameBytes.count
            let mosaicStructLength = 4 + mosaicIdStructLength + 8
        
            let tmp = ConvertUtil.toByteArrayWithLittleEndian((UInt32)(mosaicStructLength)) +
            ConvertUtil.toByteArrayWithLittleEndian((UInt32)(mosaicIdStructLength)) +
            ConvertUtil.toByteArrayWithLittleEndian((UInt32)(mosaicNameSpaceIdBytes.count)) +
            mosaicNameSpaceIdBytes +
            ConvertUtil.toByteArrayWithLittleEndian((UInt32)(mosaicNameBytes.count)) +
            mosaicNameBytes +
            ConvertUtil.toByteArrayWithLittleEndian(mosaic.quantity)
            
            if (mosaicsBytes == nil) {
                mosaicsBytes = tmp
            } else {
                mosaicsBytes = mosaicsBytes! + tmp
            }
        }
        
        return mosaicNumBytes + mosaicsBytes!
    }
}
