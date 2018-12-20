//
//  Created by Taizo Kusuda on 2018/12/21.
//  Copyright © 2018 T TECH, LIMITED LIABILITY CO. All rights reserved.
//

import Foundation

public class TimeUtil {
    private init(){}

    public static func genesisDateTime() -> Date {
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "yyyy/MM/dd HH:mm:ss"
        dateFormatter.timeZone = TimeZone(identifier: "UTC")

        return dateFormatter.date(from: "2015/03/29 00:06:25")!
    }

    public static func currentTimeFromGenesisTime(date: Date) -> UInt32 {
        return UInt32(-genesisDateTime().timeIntervalSince(date))
    }



}
