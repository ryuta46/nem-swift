//
//  TestSettings.swift
//  NemSwiftTests
//
//  Created by Taizo Kusuda on 2018/03/06.
//  Copyright © 2018年 ryuta46. All rights reserved.
//

import Foundation

class TestSettings {
    static let MAIN_HOST = URL(string: "http://www.ttechdev.com:7890")!
    static let TEST_HOST = URL(string: "http://www.ttechdev.com:7880")!

    static let TEST_WEB_SOCKET = "http://www.ttechdev.com:7768"

    // Test main account
    static let ADDRESS = "TDDYOPCS46Z5STBF3F5OI5PA2JE52JO6XVXICZIR"
    static let PRIVATE_KEY = ""
    static let PUBLIC_KEY = "7dde4bc3e7be43fc42c9579c0425da8528552e8d5f19a2533611b589e576f15f"

    // Multisig account
    static let MULTISIG_ADDRESS = "TA6CNQUQJZ4OIY3W7T5RCSJUYQMCCNR4HKGPUUE6"
    static let MULTISIG_PRIVATE_KEY = ""
    static let MULTISIG_PUBLIC_KEY = "ef60a3aec6fa82f60661958e79f36adaf01378d455367949f827597ea6bceea8"

    // Multisig signer account
    static let SIGNER_ADDRESS = "TCESVNPDCV67YDDBKJQ6OXF5HMZHENY3DO2E662L"
    static let SIGNER_PRIVATE_KEY = ""
    static let SIGNER_PUBLIC_KEY = "c6d0577111a52889e6cb414372a298bfe17fbd6e0d2eaa7437ab3ff7751fdbfa"

    static let RECEIVER = "TCRUHA3423WEYZN64CZ62IVK53VQ5JGIRJT5UMAE"
    static let RECEIVER_PUBLIC = "fa93fd24097eaa153b6d785f4400c54a779a24ae9f3697baa4bbbdb3bfffb23a"
}
