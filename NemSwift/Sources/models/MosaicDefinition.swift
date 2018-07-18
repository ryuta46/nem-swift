//
//  MosaicDefinition.swift
//  NemSwift
//
//  Created by Kazuya Okada on 2017/12/01.
//  Copyright © 2017年 OpenApostille. All rights reserved.
//

import Foundation

public struct MosaicDefinition: Decodable {
    public let creator: String
    public let id: MosaicId
    public let description: String
    public let properties: [MosaicProperty]
    public let levy: MosaicLevy?


    public var divisibility: Int? {
        return findIntPropertyValue("divisibility")
    }

    public var initialSupply: UInt64? {
        return findUInt64PropertyValue("initialSupply")
    }

    public var supplyMutable: Bool? {
        return findBoolPropertyValue("supplyMutable")
    }

    public var transferable: Bool? {
        return findBoolPropertyValue("transferable")
    }

    private func findProperty(_ name: String) ->  MosaicProperty? {
        return properties.filter { $0.name == name }.first
    }
    private func findIntPropertyValue(_ name: String) -> Int? {
        guard let value = findProperty(name)?.value else {
            return nil
        }
        return Int(value)
    }

    private func findUInt64PropertyValue(_ name: String) -> UInt64? {
        guard let value = findProperty(name)?.value else {
            return nil
        }
        return UInt64(value)
    }

    private func findBoolPropertyValue(_ name: String) -> Bool? {
        guard let value = findProperty(name)?.value else {
            return nil
        }
        return Bool(value)
    }


    private enum CodingKeys: String, CodingKey {
        case creator
        case id
        case description
        case properties
        case levy
    }

    public init(from decoder: Decoder) throws {
        let values = try decoder.container(keyedBy: CodingKeys.self)
        // required parameters
        creator = try values.decode(String.self, forKey: .creator)
        id = try values.decode(MosaicId.self, forKey: .id)
        description = try values.decode(String.self, forKey: .description)
        properties = try values.decode([MosaicProperty].self, forKey: .properties)

        // optional parameters. levy can be empty dictionary.
        levy = try? values.decode(MosaicLevy.self, forKey: .levy)
    }
}
