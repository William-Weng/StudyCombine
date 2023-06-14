import Foundation

let start = Date()

let deltaFormatter: NumberFormatter = {
    
    let formatter = NumberFormatter()
    formatter.negativePrefix = ""
    formatter.minimumFractionDigits = 1
    formatter.maximumFractionDigits = 1
    
    return formatter
}()

public var deltaTime: String {
    return deltaFormatter.string(for: Date().timeIntervalSince(start)) ?? ""
}
