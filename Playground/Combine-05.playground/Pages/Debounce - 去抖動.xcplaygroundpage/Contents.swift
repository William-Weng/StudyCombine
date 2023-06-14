import Combine
import SwiftUI

let subject = PassthroughSubject<Int, Never>()

let bounces:[(Int, TimeInterval)] = [
    (1, 0.1),   // 0.1秒 => 1
    (2, 0.2),   // 0.2秒 => 2
    (5, 1.1),   // 1.1秒 => 5
    (6, 1.2)    // 1.2秒 => 6
]

var cancellable = subject
    .debounce(for: .seconds(0.5), scheduler: RunLoop.main)
    .sink { index in print ("Received index \(index)") }

for bounce in bounces {
    DispatchQueue.main.asyncAfter(deadline: .now() + bounce.1) {
        subject.send(bounce.0)
    }
}

