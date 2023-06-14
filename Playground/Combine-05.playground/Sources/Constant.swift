import Foundation

/// Combine事件
public enum Event: Equatable {
    case value          // 事件的值
    case completion     // 事件完成
    case failure        // 事件失敗
}
