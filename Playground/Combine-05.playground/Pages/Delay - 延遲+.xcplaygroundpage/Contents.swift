import Combine
import SwiftUI
import PlaygroundSupport

let valuesPerSecond = 1.0
let delayInSeconds = 1.5

let sourcePublisher = PassthroughSubject<Date, Never>()
let delayedPublisher = sourcePublisher.delay(for: .seconds(delayInSeconds), scheduler: DispatchQueue.main)

let subscription = Timer
    .publish(every: 1.0, on: .main, in: .common)
    .autoconnect()
    .subscribe(sourcePublisher)

let sourceTimeline = TimelineView(title: "發射數值 - \(valuesPerSecond) 個/秒")
let delayedTimeline = TimelineView(title: "發射數值 - 延遲\(delayInSeconds)秒")

let view = VStack(spacing: 50) {
    sourceTimeline
    delayedTimeline
}

sourcePublisher.displayEvents(in: sourceTimeline)
delayedPublisher.displayEvents(in: delayedTimeline)

PlaygroundPage.current.liveView = UIHostingController(rootView: view.frame(width: 800, height: 600))
