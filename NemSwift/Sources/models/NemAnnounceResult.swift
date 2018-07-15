//
//  NemAnnounceResult.swift
//  NemSwift
//
//  Created by Kazuya Okada on 2017/11/28.
//  Copyright © 2017年 OpenApostille. All rights reserved.
//

import Foundation

public struct NemAnnounceResult: Decodable {
    public let type: UInt
    public let code: UInt
    public let message: String
    public let transactionHash: TransactionHash
    public let innerTransactionHash: TransactionHash?
}


