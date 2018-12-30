//
//  AccountHarvests.swift
//  NemSwift
//
//  Created by Kazuya Okada on 2017/11/22.
//  Copyright © 2017年 OpenApostille. All rights reserved.
//

import Foundation

public struct Harvests: Decodable {
    public let data: [Harvest]
}

public struct Harvest: Decodable {
    public let id: Int
    public let timeStamp: UInt
    public let difficulty: UInt64
    public let totalFee: UInt64
    public let height: UInt
}

public struct AccountHarvestBlockHash: Decodable{
    public let data: String
}
