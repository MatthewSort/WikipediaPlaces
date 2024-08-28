//
//  CustomLog.swift
//  WikipediaPlaces
//
//  Created by Mattia Capasso on 28/08/2024.
//

import Foundation

final class CustomLog {

    enum LogType {
        case warning
        case error
        case debug
        case `default`
        
        public var icon: String {
            switch self {
            case .warning: return "⚠️ [WARNING]"
            case .error: return "🛑 [ERROR]"
            case .debug: return "🔵 [DEBUG]"
            case .default: return "✅ [SUCCESS]"
            }
        }
    }
    
    static func log(
        _ object: Any,
        _ file: String = #file,
        _ function: String = #function,
        _ line: Int = #line,
        logType: LogType = .default
    ) {
        #if DEBUG
        let icon = logType.icon
        let queue = Thread.isMainThread ? "UI" : "BG"
        let fileURL = NSURL(string: file)?.lastPathComponent ?? "Unknown file"
        
        let name = "\(icon) {\(queue)} \(fileURL) > \(function)[\(line)]"
        dump(object, name: name)
        #endif
    }
}
