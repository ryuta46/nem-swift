//
//  AccountInfo.swift
//  NemSwift
//
//  Created by Kazuya Okada on 2017/11/20.
//  Copyright © 2017年 OpenApostille. All rights reserved.
//

import Foundation

public struct AccountInfo: Decodable {
    public let address: String
    public let balance: Int
    public let vestedBalance: Int
    public let importance: Double
    public let publicKey: String?
    public let label: String?
    public let harvestedBlocks: Int
    public let multisigInfo: MultisigInfo?
}
