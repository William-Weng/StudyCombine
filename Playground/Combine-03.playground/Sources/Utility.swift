import Foundation

public func example(of description: String, action: () -> Void) {
    print("\n=== 範例: \(description) ===")
    action()
}
