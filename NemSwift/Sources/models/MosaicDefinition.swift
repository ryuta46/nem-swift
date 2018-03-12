//
//  MosaicDefinition.swift
//  NemSwift
//
//  Created by Kazuya Okada on 2017/12/01.
//  Copyright © 2017年 OpenApostille. All rights reserved.
//

import Foundation

struct MosaicDefinition: Decodable {
    let creator: String
    let id: MosaicId
    let description: String
    let properties: [MosaicProperty]
    let levy: MosaicLevy?

    private enum CodingKeys: String, CodingKey {
        case creator
        case id
        case description
        case properties
        case levy
    }

    init(from decoder: Decoder) throws {
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
