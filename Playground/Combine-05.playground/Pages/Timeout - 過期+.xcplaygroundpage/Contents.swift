import Combine
import SwiftUI
import PlaygroundSupport

enum TimeoutError: Error {
    case timedOut
}

let subject = PassthroughSubject<Void, TimeoutError>()

let timedOutSubject = subject.timeout(.seconds(5), scheduler: DispatchQueue.main, customError: { .timedOut })
let timeline = TimelineView(title: "Button taps")

let view = VStack(spacing: 100) {
    
    Button(action: { subject.send() }) {
        Text("Press me within 5 seconds")
    }
    timeline
}

timedOutSubject.displayEvents(in: timeline)

PlaygroundPage.current.liveView = UIHostingController(rootView: view.frame(width: 600, height: 600))
