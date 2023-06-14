import SwiftUI
import Combine

let subscriber = Timer.publish(every: 0.5, on: .main, in: .default) // 每0.5秒發一次
    .autoconnect()
    .collect(.byTime(RunLoop.main, .seconds(3)))                    // 收集3秒內的數值 => 3 / 0.5 = 6個數值
    .sink { print("\($0)", terminator: "\n\n") }
