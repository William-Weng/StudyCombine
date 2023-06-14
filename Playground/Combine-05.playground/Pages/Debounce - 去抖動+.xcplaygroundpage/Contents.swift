import Combine
import SwiftUI
import PlaygroundSupport

let subject = PassthroughSubject<String, Never>()

let debounced = subject
  .debounce(for: .seconds(1.0), scheduler: DispatchQueue.main)
  .share()

let subjectTimeline = TimelineView(title: "Emitted values")
let debouncedTimeline = TimelineView(title: "Debounced values")

let view = VStack(spacing: 100) {
  subjectTimeline
  debouncedTimeline
}

subject.displayEvents(in: subjectTimeline)
debounced.displayEvents(in: debouncedTimeline)

let subscription1 = subject
  .sink { string in
    print("+\(deltaTime)s: Subject emitted: \(string)")
  }

let subscription2 = debounced
  .sink { string in
    print("+\(deltaTime)s: Debounced emitted: \(string)")
  }

subject.feed(with: typingHelloWorld)

PlaygroundPage.current.liveView = UIHostingController(rootView: view.frame(width: 600, height: 600))

