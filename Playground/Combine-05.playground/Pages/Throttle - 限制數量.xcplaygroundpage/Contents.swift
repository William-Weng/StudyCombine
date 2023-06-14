import Combine
import SwiftUI

let cancellable = Timer.publish(every: 3.0, on: .main, in: .default)    // 每3秒發送一次
    .autoconnect()
    .print("\(Date().description)")
    .throttle(for: 10.0, scheduler: RunLoop.main, latest: true)         // 每10秒內取最後一個
    .sink(
        receiveCompletion: { print ("Completion: \($0).") },
        receiveValue: { print("Received Timestamp \($0).") }
    )


