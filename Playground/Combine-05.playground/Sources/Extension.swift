import Combine

public extension Publisher {
    
    /// 顯示事件
    /// - Parameter view: TimelineView
    func displayEvents(in view: TimelineView) {
        view.capture(publisher: eraseToAnyPublisher())
    }
}
