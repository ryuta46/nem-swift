//
//  MultisigCosignatoryModification.swift
//  NemSwift
//
//  Created by Taizo Kusuda on 2018/08/01.
//  Copyright © 2018年 OpenApostille. All rights reserved.
//

import Foundation

public enum ModificationType: Int {
    case add = 1
    case delete = 2
}

public struct MultisigCosignatoryModification : Decodable {
    public let modificationType: Int // 1: Add, 2: Delete
    public let cosignatoryAccount: String // Public key of cosignatory account.
    
    public init(modificationType: Int, cosignatoryAccount: String) {
        self.modificationType = modificationType
        self.cosignatoryAccount = cosignatoryAccount
    }
    
    public init(modificationType: ModificationType, cosignatoryAccount: String) {
        self.init(modificationType: modificationType.rawValue, cosignatoryAccount: cosignatoryAccount)
    }
}
