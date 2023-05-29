import Foundation
import Combine

var subscriptions = Set<AnyCancellable>()

// 01. 過濾 => 跟filter()很像
//example(of: "filter") {
//
//    let multiple = 3
//    let numbers = (1...10).publisher
//
//    numbers
//        .filter { $0.isMultiple(of: multiple) }
//        .sink(receiveValue: { number in print("\(number) 是 \(multiple) 的倍數 !!!")})
//        .store(in: &subscriptions)
//}

// 02. 取得非重複資料 => 跟SQL的SELECT DISTINCT功能很像
//example(of: "removeDuplicates") {
//
//  let words = "hey hey there! want to listen to mister mister ?"
//                  .components(separatedBy: " ")
//                  .publisher
//  words
//    .removeDuplicates()
//    .sink(receiveValue: { print($0) })
//    .store(in: &subscriptions)
//}

// 03. 把Optional值去除 => 跟compactMap()很像
//example(of: "compactMap") {
//
//    let strings = ["a", "1.24", "3", "def", "45", "0.23"].publisher
//
//    strings
//        .compactMap { Float($0) }               /// 過濾Float
//        .sink(receiveValue: { print($0) })
//        .store(in: &subscriptions)
//}

// 04. 忽略發佈者的Output => 取得的值不重要，只關心完成了沒有
//example(of: "ignoreOutput") {
//
//    let numbers = (1...10_000).publisher
//
//    numbers
//        .ignoreOutput()
//        .sink(
//            receiveCompletion: { print("完成: \($0)") },
//            receiveValue: { print($0) }
//        )
//        .store(in: &subscriptions)
//}

// 05. 取得第一個符合過濾的值
//example(of: "first(where:)") {
//
//    let multiple = 2
//    let numbers = (1...9).publisher
//
//    numbers
//        .print("numbers")
//        .first(where: { $0 % multiple == 0 })
//        .sink(
//            receiveCompletion: { print("完成: \($0)") },
//            receiveValue: { print("第一個偶數: \($0)") }
//        )
//        .store(in: &subscriptions)
//}

// 06. 取得最後一個符合過濾的值
//example(of: "last(where:)") {
//
//    let numbers = PassthroughSubject<Int, Never>()
//
//    numbers
//        .first(where: { $0 % 2 == 0 })
//        .sink(
//            receiveCompletion: { print("完成: \($0)") },
//            receiveValue: { print("最後一個偶數: \($0)") }
//        )
//        .store(in: &subscriptions)
//
//    numbers.send(1)
//    numbers.send(2)
//    numbers.send(3)
//    numbers.send(4)
//    numbers.send(5)
//    numbers.send(completion: .finished)   /// 要執行這個後才有值
//}

// 07. 忽略掉前面的值
//example(of: "dropFirst") {
//
//    let numbers = (1...10).publisher
//
//    numbers
//        .dropFirst(8)       /// 忽略掉前8組
//        .sink(receiveValue: { print($0) })
//        .store(in: &subscriptions)
//}

// 08. 有條件的忽略掉數值
//example(of: "drop(while:)") {
//
//    let numbers = (1...10).publisher
//
//    numbers
//        .drop(while: { print("x"); return $0 % 5 != 0})
//        .sink(receiveValue: { print($0) })
//        .store(in: &subscriptions)
//}

// 09. 直到有發出值之後才動作
//example(of: "drop(untilOutputFrom:)") {
//
//    let isReady = PassthroughSubject<Void, Never>()
//    let taps = PassthroughSubject<Int, Never>()
//
//    taps.drop(untilOutputFrom: isReady)         /// 直到isReady變數發出值之後才動作
//        .sink(receiveValue: { print($0) })
//        .store(in: &subscriptions)
//
//    (1...5).forEach { n in
//        taps.send(n)                            /// 在isReady發出值之前都是沒有用的
//        if n == 3 { isReady.send() }            /// isReady發出值
//    }
//}

// 10. 只取前面幾組，後面的不重要
//example(of: "prefix(while:)") {
//
//    let numbers = (1...10).publisher
//
//    numbers
//        .prefix(while: { $0 < 3 })
//        .sink(
//            receiveCompletion: { print("完成: \($0)") },
//            receiveValue: { print($0) }
//        )
//        .store(in: &subscriptions)
//}

// 11. 只取前面符合條件的幾組
//example(of: "prefix(untilOutputFrom:)") {
//    
//    let isReady = PassthroughSubject<Void, Never>()
//    let taps = PassthroughSubject<Int, Never>()
//    
//    taps
//        .prefix(untilOutputFrom: isReady)                   /// 直到isReady變數發出值之後不停止
//        .sink(
//            receiveCompletion: { print("完成: \($0)") },
//            receiveValue: { print($0) }
//        )
//        .store(in: &subscriptions)
//    
//    (1...5).forEach { n in
//        taps.send(n)                                        /// 在isReady發出值之前一直是有效的
//        if n == 2 { isReady.send() }                        /// isReady發出值
//    }
//}
