//
//  AccountMetaData.swift
//  NemSwift
//
//  Created by Kazuya Okada on 2017/11/21.
//  Copyright © 2017年 OpenApostille. All rights reserved.
//

import Foundation

public struct AccountMetaData: Decodable {
    public let status: String
    public let remoteStatus: String
    public let cosignatoryOf: [AccountInfo]
    public let cosignatories: [AccountInfo]
}
