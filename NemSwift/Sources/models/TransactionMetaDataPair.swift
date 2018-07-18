//
//  TransactionMetaDataPair.swift
//  NemSwift
//
//  Created by Kazuya Okada on 2017/11/22.
//  Copyright © 2017年 OpenApostille. All rights reserved.
//

import Foundation

public struct TransactionMetaDataPairs: Decodable {
    public let data: [TransactionMetaDataPair]
}

public struct TransactionMetaDataPair: Decodable {
    public let meta: TransactionMetaData
    public let transaction: Transaction
}
