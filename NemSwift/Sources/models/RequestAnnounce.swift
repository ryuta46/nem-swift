//
//  RequestAnnounce.swift
//  NemSwift
//
//  Created by Kazuya Okada on 2017/11/22.
//  Copyright © 2017年 OpenApostille. All rights reserved.
//

import Foundation

public struct RequestAnnounce: Codable {
    public let data: String
    public let signature: String
    
    public func toJsonString() -> String {
        let data = try! JSONEncoder().encode(self)
        let jsonStr = String(data: data, encoding: .utf8)

        return jsonStr!
    }
    
    public static func generateRequestAnnounce(requestAnnounce: [UInt8], keyPair:KeyPair) -> RequestAnnounce {
        let signatureBytes = keyPair.sign(message: requestAnnounce)
        let data = ConvertUtil.toHexString(requestAnnounce)
        let signature = ConvertUtil.toHexString(signatureBytes)
        return RequestAnnounce(data: data, signature: signature)
    }
}
