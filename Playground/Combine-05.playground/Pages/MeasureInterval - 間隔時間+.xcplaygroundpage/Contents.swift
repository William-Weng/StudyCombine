import Combine
import SwiftUI
import PlaygroundSupport

let subject = PassthroughSubject<String, Never>()

let measureSubject = subject.measureInterval(using: DispatchQueue.main)
let measureSubject2 = subject.measureInterval(using: RunLoop.main)

let subjectTimeline = TimelineView(title: "Emitted values")
let measureTimeline = TimelineView(title: "Measured values")

let view = VStack(spacing: 100) {
    subjectTimeline
    measureTimeline
}

subject.displayEvents(in: subjectTimeline)
measureSubject.displayEvents(in: measureTimeline)

let subscription1 = subject.sink {
    print("+\(deltaTime)s: Subject emitted: \($0)")
}

let subscription2 = measureSubject.sink {
    print("+\(deltaTime)s: Measure emitted: \(Double($0.magnitude) / 1_000_000_000.0)")
}

let subscription3 = measureSubject2.sink {
    print("+\(deltaTime)s: Measure2 emitted: \($0)")
}

subject.feed(with: typingHelloWorld)

PlaygroundPage.current.liveView = UIHostingController(rootView: view.frame(width: 375, height: 600))
