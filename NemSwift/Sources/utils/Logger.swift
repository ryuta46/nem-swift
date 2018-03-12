//
//  Logger.swift
//  NemSwift
//
//  Created by Taizo Kusuda on 2018/03/13.
//  Copyright © 2018年 ryuta46. All rights reserved.
//

import Foundation

class Logger {
    private static func printIfValid(level: NemSwiftConfiguration.LogLevel, message: String) {
        if NemSwiftConfiguration.logLevel.isValid(for: level) {
            print(message)
        }
    }

    static func e(_ message: String) {
        printIfValid(level: .error, message: message)
    }
    static func w(_ message: String) {
        printIfValid(level: .warning, message: message)
    }
    static func i(_ message: String) {
        printIfValid(level: .info, message: message)
    }
    static func d(_ message: String) {
        printIfValid(level: .debug, message: message)
    }
}
