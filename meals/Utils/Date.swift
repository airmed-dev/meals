//
// Created by aclowkey on 08/10/2022.
//

import Foundation

class DateUtils {
    // Format a time interval into human readable format
    // Examples 00:00, +01:00, +01:30, -01:00,
    static func formatTimeInterval(timeInterval: TimeInterval) -> String {
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
            prefix += "0:"
        }
        return prefix + formatted
    }

    static func formatTime(date: Date) -> String {
        let formatter = DateFormatter()
        formatter.dateFormat = "HH:mm"
        return formatter.string(from: date)
    }

    static func formatDateWithRelativeDay(date: Date) -> String {
        formatRelativeDayOfWeek(date: date) ?? formatDate(date: date)
    }

    static func dateAndTimeFormat(date: Date) -> String {
        let dateSection = formatRelativeDayOfWeek(date: date) ??
                "\(formatDayOfTheWeek(date: date)), \(formatDate(date: date))"
        return "\(dateSection) at \(formatTime(date: date))"
    }

    static func formatDate(date: Date) -> String {
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy-MM-dd"
        return formatter.string(from: date)
    }

    static func formatDayOfTheWeek(date: Date) -> String {
        if Calendar.current.isDateInToday(date) {
            return "Today"
        }
        if Calendar.current.isDateInYesterday(date) {
            return "Yesterday"
        }
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "EEEE"
        return dateFormatter.string(from: date)
    }

    static func formatRelativeDayOfWeek(date: Date) -> String? {
        if Calendar.current.isDateInToday(date) {
            return "Today"
        }

        if Calendar.current.isDateInYesterday(date) {
            return "Yesterday"

        }
        return nil
    }
}