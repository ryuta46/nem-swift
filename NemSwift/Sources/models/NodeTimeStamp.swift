//
//  Created by Taizo Kusuda on 2018/12/21.
//  Copyright © 2018 T TECH, LIMITED LIABILITY CO. All rights reserved.
//

import Foundation

public struct NodeTimeStamp: Decodable {
    public let sendTimeStamp: UInt64
    public let receiveTimeStamp: UInt64


    public var receiveTimeStampBySeconds: UInt32 {
        return UInt32(receiveTimeStamp / 1000)
    }
}
