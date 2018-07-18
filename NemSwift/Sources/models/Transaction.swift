//
//  Transaction.swift
//  NemSwift
//
//  Created by Kazuya Okada on 2017/11/21.
//  Copyright © 2017年 OpenApostille. All rights reserved.
//

import Foundation

public struct Transaction: Decodable {
    public let timeStamp: UInt
    public let amount: UInt?
    public let signature: String
    public let fee: UInt
    public let recipient: String?
    public let type: UInt
    public let version: Int
    public let signer: String
    public let mosaics: [Mosaic]?
    public let message: TransactionMessage?
}
