//
//  MosaicId.swift
//  NemSwift
//
//  Created by Kazuya Okada on 2017/11/21.
//  Copyright © 2017年 OpenApostille. All rights reserved.
//

import Foundation

public struct MosaicId: Decodable {
    public let namespaceId: String
    public let name: String
}
