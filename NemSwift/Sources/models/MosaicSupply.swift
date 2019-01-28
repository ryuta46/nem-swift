//
//  Created by Taizo Kusuda on 2019/01/25.
//  Copyright © 2018 T TECH, LIMITED LIABILITY CO. All rights reserved.
//


import Foundation

public struct MosaicSupply: Decodable {
    public let mosaicId: MosaicId
    public let supply: UInt64
}