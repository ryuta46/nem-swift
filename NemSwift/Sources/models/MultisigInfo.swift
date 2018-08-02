//
//  MultisigInfo.swift
//  NemSwift
//
//  Created by Taizo Kusuda on 2018/08/02.
//  Copyright © 2018年 OpenApostille. All rights reserved.
//

import Foundation


public struct MultisigInfo : Decodable {
    public let cosignatoriesCount: Int?
    public let minCosignatories: Int?
    
}
