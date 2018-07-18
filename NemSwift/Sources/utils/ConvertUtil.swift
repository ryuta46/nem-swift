//
//  ConvertUtil.swift
//  NemSwift
//
//  Created by Kazuya Okada on 2017/11/15.
//  Copyright © 2017年 OpenApostille. All rights reserved.
//

import Foundation

public class ConvertUtil {
    public static func toHexString(_ bytes : [UInt8]) -> String {
        var result = ""
        bytes.forEach { (element) in
            result = result + String(format:"%02x", element)
        }
        return result
    }
    
    public static func toByteArray(_ s: String) -> [UInt8] {
        let len = s.lengthOfBytes(using: .ascii)
        var data: [UInt8] = []
        for i in stride(from:0, to:len, by: 2) {
            let startIndex = s.index(s.startIndex, offsetBy: i)
            let endIndex = s.index(startIndex, offsetBy: 2)
            if let val = UInt8(s[startIndex..<endIndex], radix: 16) {
                data.append(val)
            }
        }
        return data
    }
    
    public static func toNativeArray(_ bytes: [UInt8]) -> UnsafeMutablePointer<UInt8> {
        let ret = UnsafeMutablePointer<UInt8>.allocate(capacity: bytes.count)
        
        for i in 0..<bytes.count {
            ret[i] = bytes[i]
        }
        return ret
    }
    public static func toArray(_ native: UnsafePointer<UInt8>,_ size: Int) -> [UInt8] {
        var ret = [UInt8](repeating: 0, count: size)
        
        for i in 0..<size {
            ret[i] = native[i]
        }
        return ret
    }
    
    
    public static func toByteArrayWithLittleEndian(_ value: UInt32) -> [UInt8] {
        var ret = [UInt8](repeating: 0, count: 4)
        
        for i in 0..<ret.count {
            ret[i] = UInt8(value >> (i * 8) & UInt32(0xFF))
        }
        return ret
    }
    
    public static func toByteArrayWithLittleEndian(_ value: UInt64) -> [UInt8] {
        var ret = [UInt8](repeating: 0, count: 8)
        
        for i in 0..<ret.count {
            ret[i] = UInt8(value >> (i * 8) & UInt64(0xFF))
        }
        return ret
    }
    
    public static func swapByteArray(_ bytes: [UInt8]) -> [UInt8] {
        var ret = [UInt8](repeating:0 ,count: bytes.count)
        
        for i in 0..<bytes.count {
            ret[ret.count - 1 - i] = bytes[i]
        }
        
        return ret
    }
}
