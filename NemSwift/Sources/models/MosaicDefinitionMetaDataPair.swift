//
//  MosaicDefinitionMetaDataPair.swift
//  NemSwift
//
//  Created by Kazuya Okada on 2017/12/01.
//  Copyright © 2017年 OpenApostille. All rights reserved.
//

import Foundation

public struct MosaicDefinitionMetaDataPairs: Decodable {
    public let data: [MosaicDefinitionMetaDataPair]
}

public struct MosaicDefinitionMetaDataPair: Decodable {
    public let meta: MosaicMetaData
    public let mosaic: MosaicDefinition
}
