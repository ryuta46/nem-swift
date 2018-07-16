//
//  NISRequest.swift
//  NemSwift
//
//  Created by Kazuya Okada on 2017/11/20.
//  Copyright © 2017年 OpenApostille. All rights reserved.
//

import Foundation
import APIKit

public protocol NISRequest: Request {
    
}

extension NISRequest where Response: Decodable {
    public func response(from object: Any, urlResponse: HTTPURLResponse) throws -> Response {
        guard let data = object as? Data else {
            throw ResponseError.unexpectedObject(object)
        }
        return try JSONDecoder().decode(Response.self, from: data)
    }
}

public struct NISError: Error, Codable {
    public let timeStamp: UInt?
    public let error: String?
    public let message: String?
    public let status: UInt?
    
    public init(object: Any) {
        let decodar = JSONDecoder()
        let obj = try! decodar.decode(NISError.self, from: object as! Data)
        self.timeStamp = obj.timeStamp
        self.error = obj.error
        self.message = obj.message
        self.status = obj.status
    }
}

extension NISRequest {
    public func intercept(urlRequest: URLRequest) throws -> URLRequest {
        Logger.i("Request: \(urlRequest.description)")
        return urlRequest
    }

    public func intercept(object: Any, urlResponse: HTTPURLResponse) throws -> Any {
        Logger.i("Response code: \(urlResponse.statusCode)")
        let res = String(data: object as! Data, encoding: .utf8)!
        Logger.i("Response body: \(res)")
        
        guard 200..<300 ~= urlResponse.statusCode else {
            throw NISError(object: object)
        }
        
        return object
    }
}
