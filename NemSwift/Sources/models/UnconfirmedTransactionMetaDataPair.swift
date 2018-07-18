//
//  UnconfirmedTransactionMetaDataPair.swift
//  NemSwift
//
//  Created by Kazuya Okada on 2017/11/22.
//  Copyright © 2017年 OpenApostille. All rights reserved.
//

import Foundation

public struct UnconfirmedTransactionMetaDataPairs: Decodable {
    public let data: [UnconfirmedTransactionMetaDataPair]
}

public struct UnconfirmedTransactionMetaDataPair: Decodable {
    public let meta: UnconfirmedTransactionMetaData
    public let transaction: Transaction
}
