//
//  Transaction.swift
//  NemSwift
//
//  Created by Kazuya Okada on 2017/11/21.
//  Copyright © 2017年 OpenApostille. All rights reserved.
//

import Foundation

public class Transaction: Decodable {
    public let timeStamp: UInt
    public let fee: UInt64
    public let type: UInt
    public let version: Int
    public let signer: String
    public let signature: String?

    // for Transfer
    public let amount: UInt64?
    public let recipient: String?
    public let mosaics: [Mosaic]?
    public let message: TransactionMessage?
    
    // for Multisig Aggregate Modification Transfer
    public let modifications: [MultisigCosignatoryModification]?
    public let minCosignatories: MinimumCosignatoriesModification?
    // for Multisig Signature
    public let otherHash: TransactionHash?
    public let otherAccount: String?

    // for Multisig
    public let otherTrans: Transaction?
    public let signatures: [Transaction]?

    
    public init(timeStamp: UInt, fee: UInt64, type: UInt, version: Int, signer: String, signature: String? = nil,
                amount: UInt64? = nil, recipient: String? = nil, mosaics: [Mosaic]? = nil, message: TransactionMessage? = nil,
                modifications: [MultisigCosignatoryModification]? = nil, minCosignatories: MinimumCosignatoriesModification? = nil,
                otherHash: TransactionHash? = nil, otherAccount: String? = nil,
                otherTrans: Transaction? = nil, signatures: [Transaction]? = nil
                ) {
        self.timeStamp = timeStamp
        self.fee = fee
        self.type = type
        self.version = version
        self.signer = signer
        self.signature = signature

        self.amount = amount
        self.recipient = recipient
        self.mosaics = mosaics
        self.message = message
        
        self.modifications = modifications
        self.minCosignatories = minCosignatories
        
        self.otherHash = otherHash
        self.otherAccount = otherAccount
        
        self.otherTrans = otherTrans
        self.signatures = signatures
    }
}
