//
//  Importance.swift
//  NemSwift
//
//  Created by Kazuya Okada on 2017/11/22.
//  Copyright © 2017年 OpenApostille. All rights reserved.
//

import Foundation

public struct Importances: Decodable {
    public let data: [AccountImportance]
}

public struct AccountImportance: Decodable {
    public let address: String
    public let importance: Importance
}

public struct Importance: Decodable {
    public let isSet: Int
    public let score: Double?
    public let ev: Double?
    public let height: UInt?
}
