import SwiftUI
import Combine

// MARK: - 時間軸 + 彈珠球事件
public struct TimelineView: View {
    
    @ObservedObject var displayTimer: DisplayTimer
    
    let holder: EventsHolder
    let title: String
    
    private let fps: Double = 60
    private let completedLineSize: CGSize = CGSize(width: 4, height: 38)
    private var marbleDiameter: CGFloat { get { return fps - 10 }}
    private var groupedEvents: [CombineEvents] { return sortGroupedEvents() }
    
    public init(title: String) {
        self.title = title
        self.holder = EventsHolder()
        self.displayTimer = DisplayTimer(fps: fps)
    }
    
    public init(title: String, events: [CombineEvent]) {
        self.title = title
        self.holder = EventsHolder(events: events)
        self.displayTimer = DisplayTimer(fps: fps)
    }
    
    public var body: some View { bodyMaker() }
    
    func capture<I, F>(publisher: AnyPublisher<I, F>) {
        
        let observer = captureSubscriber() as AnySubscriber<I, F>
        
        publisher
            .subscribe(on: DispatchQueue.main)
            .subscribe(observer)
    }
}

// MARK: - 小工具 for TimelineView
private extension TimelineView {
    
    /// 產生View
    /// - Returns: some View
    func bodyMaker() -> some View {
        
        let view = VStack(alignment: .leading) {
            TitleView(title: title, color: .gray, paddingLength: 8)
            ZStack(alignment: .topTrailing) {
                CurrentLineView(height: 1.0, color: .gray, offsetY: marbleDiameter * 0.5)
                ForEach(groupedEvents) { SimultaneousEventsView(events: $0.events, marbleDiameter: marbleDiameter, completedLineSize: completedLineSize).offset(x: CGFloat($0.time) * fps - displayTimer.current, y: 0) }
            }
            .frame(minHeight: marbleDiameter)
            .onReceive(displayTimer.objectWillChange) { _ in if self.holder.events.contains(where: { $0.event != .value }) { displayTimer.stop(after: 0.5) }}
        }
        
        return view
    }
    
    /// 將CombineEvents依照時間分組，再照index大小排序
    /// - Returns: [CombineEvents]
    func sortGroupedEvents() -> [CombineEvents] {
        
        let dictionary = Dictionary(grouping: holder.events) { $0.groupTime }
        let sortedKeys = dictionary.keys.sorted()
        let sortedCombineEvents = sortedKeys.map { dictionary[$0] }.compactMap { $0 }.map { CombineEvents(events: $0.sorted { $0.index < $1.index }) }
        
        return sortedCombineEvents
    }
    
    /// 抓取用的Subscriber
    /// - Returns: AnySubscriber<I, F>
    func captureSubscriber<I, F>() -> AnySubscriber<I, F> {
        
        let observer = AnySubscriber(receiveSubscription: { subscription in
            subscription.request(.unlimited)
        }, receiveValue: { (value: I) -> Subscribers.Demand in
            holder.capture(.value)
            return .unlimited
        }, receiveCompletion: { (completion: Subscribers.Completion<F>) in
            switch completion {
            case .finished: holder.capture(.completion)
            case .failure: holder.capture(.failure)
            }
        })

        return observer
    }
}

// MARK: - 小工具
/// 模擬事件的View
struct SimultaneousEventsView: View {
    
    let events: [CombineEvent]
    let marbleDiameter: CGFloat
    let completedLineSize: CGSize
    
    public init(events: [CombineEvent], marbleDiameter: CGFloat, completedLineSize: CGSize) {
        self.events = events
        self.marbleDiameter = marbleDiameter
        self.completedLineSize = completedLineSize
    }
    
    var body: some View {
        VStack(alignment: .center, spacing: 0) {
            ForEach(0..<self.events.count, id: \.self) { EventView(event: self.events[$0], marbleDiameter: marbleDiameter, completedLineSize: completedLineSize) }
        }
    }
}

// MARK: - Identifiable
extension SimultaneousEventsView: Identifiable {
    var id: Int { return events.first?.groupTime ?? 0}
}

// MARK: - View
/// 事件View的總合 (彈珠球事件 / 彈珠球錯誤事件 / 事件完成線)
struct EventView: View {
    
    let event: CombineEvent
    let marbleDiameter: CGFloat
    let completedLineSize: CGSize
    
    public init(event: CombineEvent, marbleDiameter: CGFloat, completedLineSize: CGSize) {
        self.event = event
        self.marbleDiameter = marbleDiameter
        self.completedLineSize = completedLineSize
    }
    
    var body: some View {
        switch event.event {
        case .value: return AnyView(MarbleValueView(index: event.index, size: CGSize(width: marbleDiameter, height: marbleDiameter), color: .blue))
        case .completion: return AnyView(EventCompletedLineView(size: completedLineSize, color: .gray))
        case .failure: return AnyView(MarbleFailureView(size: CGSize(width: marbleDiameter, height: marbleDiameter), color: .red))
        }
    }
}

/// 彈珠球事件View
struct MarbleValueView: View {
    
    let index: Int
    let size: CGSize
    let color: Color
    
    var body: some View {
        Text("\(index)").padding(3.0).frame(width: size.width, height: size.height).allowsTightening(true).minimumScaleFactor(0.1).foregroundColor(.white).background(Circle().fill(color)).fixedSize()
    }
}

/// 彈珠球錯誤事件View
struct MarbleFailureView: View {
    
    let size: CGSize
    let color: Color
    
    var body: some View {
        Text("X").padding(3.0).frame(width: size.width, height: size.height).foregroundColor(.white).background(Circle().fill(color))
    }
}

/// 事件完成線
struct EventCompletedLineView: View {
    
    let size: CGSize
    let color: Color

    var body: some View {
        Rectangle().frame(width: size.width, height: size.height).offset(x: 0, y: -3).foregroundColor(color)
    }
}

/// 時間軸
struct CurrentLineView: View {
    
    let height: CGFloat
    let color: Color
    let offsetY: CGFloat
    
    var body: some View {
        Rectangle().frame(height: height).offset(x: 0, y: offsetY).foregroundColor(color)
    }
}

/// 標題列
struct TitleView: View {
    
    let title: String
    let color: Color
    let paddingLength: CGFloat
        
    var body: some View {
        Text(title).fixedSize(horizontal: false, vertical: true).padding(.bottom, paddingLength).foregroundColor(color)
    }
}

