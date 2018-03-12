//
//  NISRequest.swift
//  NemSwift
//
//  Created by Kazuya Okada on 2017/11/20.
//  Copyright © 2017年 OpenApostille. All rights reserved.
//

import Foundation
import APIKit

protocol NISRequest: Request {
    
}

extension NISRequest where Response: Decodable {
    var dataParser: DataParser {
        return DecodableDataParser()
    }
    
    func response(from object: Any, urlResponse: HTTPURLResponse) throws -> Response {
        guard let data = object as? Data else {
            throw ResponseError.unexpectedObject(object)
        }
        return try JSONDecoder().decode(Response.self, from: data)
    }
}

struct NISError: Error, Codable {
    let timeStamp: UInt?
    let error: String?
    let message: String?
    let status: UInt?
    
    init(object: Any) {
        let decodar = JSONDecoder()
        let obj = try! decodar.decode(NISError.self, from: object as! Data)
        self.timeStamp = obj.timeStamp
        self.error = obj.error
        self.message = obj.message
        self.status = obj.status
    }
}

extension NISRequest {
    func intercept(object: Any, urlResponse: HTTPURLResponse) throws -> Any {
        print(urlResponse.statusCode)
        let res = String(data: object as! Data, encoding: .utf8)!
        print(res)
        
        guard 200..<300 ~= urlResponse.statusCode else {
            throw NISError(object: object)
        }
        
        return object
    }
}
