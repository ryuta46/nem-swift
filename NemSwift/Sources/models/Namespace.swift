//
//  Namespace.swift
//  NemSwift
//
//  Created by Kazuya Okada on 2017/11/22.
//  Copyright © 2017年 OpenApostille. All rights reserved.
//

import Foundation

public struct Namespaces: Decodable {
    public let data: [Namespace]
}

public struct Namespace: Decodable {
    public let fqn: String
    public let owner: String
    public let height: UInt
}
