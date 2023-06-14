import SwiftUI
import Combine

/// 定時發送事件
public final class DisplayTimer: ObservableObject {
    
    @Published var current: CGFloat = 0
    
    var cancellable: Cancellable? = nil
        
    public init(fps: Double = 30) {
        DispatchQueue.main.async { self.cancellable = self.start(fps: fps) }
    }
    
    /// 開始發送事件
    /// - Parameter fps: 幾秒發一次
    /// - Returns: Cancellable
    public func start(fps: Double) -> Cancellable {
        
        return Timer
            .publish(every: 1.0 / fps, on: .main, in: .common)
            .autoconnect()
            .scan(CGFloat(0)) { (counter, _) in counter + 1 }
            .sink { self.current = $0 }
    }
    
    /// 結束發送事件
    /// - Parameter after: 幾秒後
    public func stop(after: TimeInterval) {
        
        DispatchQueue.main.asyncAfter(deadline: .now() + after) {
            self.cancellable?.cancel()
        }
    }
}

/// Combine事件
public struct CombineEvent {
    
    public let index: Int           // 事件的index
    public let time: TimeInterval   // 事件發生的時間
    public let event: Event         // 事件內容
    
    public var groupTime: Int { Int(floor(time * 10.0)) }
    public var isValue: Bool { event == .value }
    public var isCompletion: Bool { event == .completion }
    
    public init(index: Int, time: TimeInterval, event: Event) {
        self.index = index
        self.time = time
        self.event = event
    }
}

/// Combine事件總合
struct CombineEvents: Identifiable {
    
    let events: [CombineEvent]
    
    var time: TimeInterval { events.first?.time ?? 0 }
    var id: Int { ((events.first?.groupTime ?? 0) << 16) | events.count }
}

/// 處理事件們的Holder
final class EventsHolder {
    
    private let lifeTime: TimeInterval  //  事件在畫面上存活的時間
    
    private(set) var events = [CombineEvent]()
    private var startDate = Date()
    private var nextIndex = 1
    
    init() {
        self.lifeTime = 15.0
    }
    
    init(events: [CombineEvent], lifeTime: TimeInterval = 15.0) {
        self.events = events
        self.lifeTime = lifeTime
    }
    
    /// 抓取事件
    /// - Parameter event: Event
    func capture(_ event: Event) {
        
        let time = Date().timeIntervalSince(startDate)
        
        if case .completion = event, let lastEvent = events.last, (time - lastEvent.time) < 1.0 {
            events.append(CombineEvent(index: nextIndex, time: lastEvent.time + 1.0, event: event))
        } else {
            events.append(CombineEvent(index: nextIndex, time: time, event: event))
        }
        
        nextIndex += 1

        while let event = events.first {
            guard (time - event.time) > lifeTime else { break }
            events.removeFirst()
        }
    }
}
