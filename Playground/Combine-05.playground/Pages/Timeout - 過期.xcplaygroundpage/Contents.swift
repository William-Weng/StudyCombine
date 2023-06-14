import Combine
import SwiftUI

let WaitTime : Int = 2
let TimeoutTime : Int = 5

let subject = PassthroughSubject<String, Never>()
let cancellable = subject
    .timeout(.seconds(TimeoutTime), scheduler: DispatchQueue.main, options: nil, customError:nil)
    .sink(
        receiveCompletion: { print ("\(Date()) - \(TimeoutTime)秒後完成: \($0)") },
        receiveValue: { print ("\(Date()) - 數值: \($0)") }
    )

print("\(Date()) - 開始")

DispatchQueue.main.asyncAfter(deadline: .now() + .seconds(WaitTime), execute: { subject.send("\(Date()) - 等\(WaitTime)秒後發出") } )
