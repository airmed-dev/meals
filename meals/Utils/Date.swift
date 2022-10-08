//
// Created by aclowkey on 08/10/2022.
//

import Foundation

class DateUtils {
    // Format a time interval into human readable format
    // Examples 00:00, +01:00, +01:30, -01:00,
    static func formatTimeInterval(timeInterval: TimeInterval) -> String{
        if timeInterval == 0 {
            return "0:00"
        }
        let formatter = DateComponentsFormatter()
        formatter.allowedUnits = [.hour, .minute]
        formatter.unitsStyle = .positional
        let formatted = formatter.string(from: timeInterval)!

        var prefix = timeInterval >= 0 ? "+" : "-"
        if formatted.count < 3 {
            // The formatter will exclude hours if they don't exist
            prefix+="0:"
        }
        return prefix+formatted
    }
}
