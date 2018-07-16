//
//  NemSwiftConfiguration.swift
//  NemSwift
//
//  Created by Taizo Kusuda on 2018/03/12.
//  Copyright © 2018年 ryuta46. All rights reserved.
//

import Foundation

public class NemSwiftConfiguration {
    public enum LogLevel: Int {
        case none    = 0
        case error   = 1
        case warning = 2
        case info    = 3
        case debug   = 4
        case verbose = 5

        internal func isValid(for level: LogLevel) -> Bool {
            return self.rawValue >= level.rawValue
        }
    }

    // Configurations for library user

    public static var logLevel = LogLevel.none
    public static var defaultBaseURL: URL = URL(string: "http://localhost:7890")!

}
