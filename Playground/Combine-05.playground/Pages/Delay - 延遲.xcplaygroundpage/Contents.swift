import SwiftUI
import Combine

let delaySeccond = 2
let timerSeccond = 1

var subscriptions = Set<AnyCancellable>()

let timerPublisher = Timer
  .publish(every: Double(timerSeccond) , on: .main, in: .common)
  .autoconnect()

timerPublisher
    .handleEvents(receiveOutput: { date in print ("每\(timerSeccond)秒發送訊息\t\t\(date)") })
    .delay(for: .seconds(delaySeccond), scheduler: DispatchQueue.main)
    .sink { value in print("收到前\(delaySeccond)秒的訊息\t\(value)") }
    .store(in: &subscriptions)
