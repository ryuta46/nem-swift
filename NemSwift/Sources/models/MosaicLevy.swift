//
//  MosaicLevy.swift
//  NemSwift
//
//  Created by Kazuya Okada on 2017/12/01.
//  Copyright © 2017年 OpenApostille. All rights reserved.
//

import Foundation

public struct MosaicLevy: Decodable {
    public let type: UInt
    public let recipient: String
    public let mosaicId: MosaicId
    public let fee: UInt64
}
