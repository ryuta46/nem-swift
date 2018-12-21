//
//  MultisigTransactionHelper.swift
//  NemSwift
//
//  Created by Taizo Kusuda on 2018/08/01.
//  Copyright © 2018年 OpenApostille. All rights reserved.
//
import Foundation

public class MultisigTransactionHelper {
    public static let multisigAggregateModificationFee: UInt64 = 500_000
    public static let multisigFee: UInt64 = 150_000
    public static let multisigSignatureFee: UInt64 = 150_000
    
    private init() { }
    
    public class MultisigTransaction: TransactionHelper.Transaction {
        public let innerTransaction: TransactionHelper.Transaction
        
        init(publicKey: [UInt8],
             network: TransactionHelper.Network,
             timeStamp: UInt32,
             duration: UInt32,
             innerTransaction: TransactionHelper.Transaction) {
            self.innerTransaction = innerTransaction
            
            super.init(type: .Multisig,
                    network: network,
                    publicKey: publicKey,
                    fee: MultisigTransactionHelper.multisigFee,
                    timeStamp: timeStamp,
                    duration: duration
                    )
        }
        
        public override func toByteArray() -> [UInt8] {
            let commonField = super.toByteArray()
            
            let innerTransactionBytes = innerTransaction.toByteArray()
            
            return commonField +
                ConvertUtil.toByteArrayWithLittleEndian(UInt32(innerTransactionBytes.count)) +
            innerTransactionBytes
        }
    }
    
    public class AggregateModificationTransaction: TransactionHelper.Transaction {
        public let modifications: [MultisigCosignatoryModification]
        public let minCosignatoriesRelativeChange: Int
        
        init(publicKey: [UInt8],
             network: TransactionHelper.Network,
             timeStamp: UInt32,
             duration: UInt32,
             modifications: [MultisigCosignatoryModification],
             minCosignatoriesRelativeChange: Int) {
            
            self.modifications = modifications
            self.minCosignatoriesRelativeChange = minCosignatoriesRelativeChange

            super.init(type: .MultisigAgregateModificationTransfer,
                    network: network,
                    publicKey: publicKey,
                    fee: MultisigTransactionHelper.multisigAggregateModificationFee,
                    timeStamp: timeStamp,
                    duration: duration
                    )
            
        }
        
        public override func toByteArray() -> [UInt8] {
            var bytes = super.toByteArray()
            bytes += ConvertUtil.toByteArrayWithLittleEndian(UInt32(modifications.count))
            
            var modificationsBytes: [UInt8] = []
            modifications.sorted(by: {left, right in left.cosignatoryAccount < right.cosignatoryAccount }).forEach { (modification) in
                let publicKey = ConvertUtil.toByteArray(modification.cosignatoryAccount)
                var thisModificationBytes: [UInt8] = []
                thisModificationBytes += ConvertUtil.toByteArrayWithLittleEndian(UInt32(modification.modificationType))
                thisModificationBytes += ConvertUtil.toByteArrayWithLittleEndian(UInt32(publicKey.count))
                thisModificationBytes += publicKey
                
                modificationsBytes += ConvertUtil.toByteArrayWithLittleEndian(UInt32(thisModificationBytes.count))
                modificationsBytes += thisModificationBytes
            }
            
            bytes += modificationsBytes
            
            if minCosignatoriesRelativeChange == 0 {
                bytes += ConvertUtil.toByteArrayWithLittleEndian(UInt32(0))
            } else {
                let relativeChangeBytes = ConvertUtil.toByteArrayWithLittleEndian(Int32(minCosignatoriesRelativeChange))
                bytes += ConvertUtil.toByteArrayWithLittleEndian(UInt32(relativeChangeBytes.count))
                bytes += relativeChangeBytes
            }
            return bytes
        }
    }
    
    public class SignatureTransaction: TransactionHelper.Transaction {
        public let otherHash: String
        public let otherAccount: String
        
        
        init(publicKey: [UInt8],
             network: TransactionHelper.Network,
             timeStamp: UInt32,
             duration: UInt32,
             otherHash: String,
             otherAccount: String) {
            self.otherHash = otherHash
            self.otherAccount = otherAccount
            
            super.init(type: .MultisigSignature,
                    network: network,
                    publicKey: publicKey,
                    fee: MultisigTransactionHelper.multisigSignatureFee,
                    timeStamp: timeStamp,
                    duration: duration
                    )

        }
    
        public override func toByteArray() -> [UInt8] {
            var bytes = super.toByteArray()
            var hashBytes = ConvertUtil.toByteArray(otherHash)
            hashBytes = ConvertUtil.toByteArrayWithLittleEndian(UInt32(hashBytes.count)) + hashBytes
            bytes += ConvertUtil.toByteArrayWithLittleEndian(UInt32(hashBytes.count)) + hashBytes
            bytes += ConvertUtil.toByteArrayWithLittleEndian(UInt32(otherAccount.count))
            bytes += otherAccount.bytes
            
            return bytes
        }
    }

    public static func generateMultisig(
            publicKey: [UInt8],
            network: TransactionHelper.Network,
            timeStamp: UInt32 = TimeUtil.currentTimeFromGenesisTime(date: Date()),
            duration: UInt32 = TimeUtil.oneDay,
            innerTransaction: TransactionHelper.Transaction
        ) -> MultisigTransaction {
        return MultisigTransaction(
                publicKey: publicKey,
                network: network,
                timeStamp: timeStamp,
                duration: duration,
                innerTransaction: innerTransaction)
    }

    public static func generateAggregateModification(
            publicKey: [UInt8],
            network: TransactionHelper.Network,
            timeStamp: UInt32 = TimeUtil.currentTimeFromGenesisTime(date: Date()),
            duration: UInt32 = TimeUtil.oneDay,
            modifications: [MultisigCosignatoryModification],
            minCosignatoriesRelativeChange: Int) -> AggregateModificationTransaction {
        return AggregateModificationTransaction(
                publicKey: publicKey,
                network: network,
                timeStamp: timeStamp,
                duration: duration,
                modifications: modifications,
                minCosignatoriesRelativeChange: minCosignatoriesRelativeChange)
    }
    
    public static func generateSignature(
            publicKey: [UInt8],
            network: TransactionHelper.Network,
            timeStamp: UInt32 = TimeUtil.currentTimeFromGenesisTime(date: Date()),
            duration: UInt32 = TimeUtil.oneDay,
            otherHash: String,
            otherAccount: String) -> SignatureTransaction {
        return SignatureTransaction(
                publicKey: publicKey,
                network: network,
                timeStamp: timeStamp,
                duration: duration,
                otherHash: otherHash,
                otherAccount: otherAccount)
    }

    public static func generateMultisigRequestAnnounce(
            publicKey: [UInt8],
            network: TransactionHelper.Network,
            timeStamp: UInt32 = TimeUtil.currentTimeFromGenesisTime(date: Date()),
            duration: UInt32 = TimeUtil.oneDay,
            innerTransaction: TransactionHelper.Transaction) -> [UInt8] {
        return generateMultisig(
                publicKey: publicKey,
                network: network,
                timeStamp: timeStamp,
                duration: duration,
                innerTransaction: innerTransaction).toByteArray()
    }

    public static func generateAggregateModificationRequestAnnounce(
            publicKey: [UInt8],
            network: TransactionHelper.Network,
            timeStamp: UInt32 = TimeUtil.currentTimeFromGenesisTime(date: Date()),
            duration: UInt32 = TimeUtil.oneDay,
            modifications: [MultisigCosignatoryModification],
            minCosignatoriesRelativeChange: Int) -> [UInt8] {
        return generateAggregateModification(
                publicKey: publicKey,
                network: network,
                timeStamp: timeStamp,
                duration: duration,
                modifications: modifications,
                minCosignatoriesRelativeChange: minCosignatoriesRelativeChange).toByteArray()
    }
    
    public static func generateSignatureRequestAnnounce(
            publicKey: [UInt8],
            network: TransactionHelper.Network,
            timeStamp: UInt32 = TimeUtil.currentTimeFromGenesisTime(date: Date()),
            duration: UInt32 = TimeUtil.oneDay,
            otherHash: String,
            otherAccount: String) -> [UInt8] {
        return generateSignature(
                publicKey: publicKey,
                network: network,
                timeStamp: timeStamp,
                duration: duration,
                otherHash: otherHash,
                otherAccount: otherAccount).toByteArray()
    }

}
