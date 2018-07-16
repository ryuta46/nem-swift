//
//  NISError.swift
//  NemSwift
//
//  Created by Kazuya Okada on 2017/11/28.
//  Copyright © 2017年 OpenApostille. All rights reserved.
//

import Foundation

public struct NISErrorResponse: Decodable {
    public let timeStamp: UInt
    public let error: String
    public let message: String
    public let status: UInt
}
