//
//  Mosaic.swift
//  NemSwift
//
//  Created by Kazuya Okada on 2017/11/21.
//  Copyright © 2017年 OpenApostille. All rights reserved.
//

import Foundation

public struct Mosaics: Decodable {
    public let data: [Mosaic]
}

public struct Mosaic: Decodable {
    public let mosaicId: MosaicId
    public let quantity: UInt
}
