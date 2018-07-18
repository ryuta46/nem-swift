//
//  TransactionMetaData.swift
//  NemSwift
//
//  Created by Kazuya Okada on 2017/11/21.
//  Copyright © 2017年 OpenApostille. All rights reserved.
//

import Foundation

public struct TransactionMetaData: Decodable {
    public let height: Int
    public let id: Int
    public let hash: TransactionHash
}
