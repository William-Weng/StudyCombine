import UIKit
import Combine

var subscriptions = Set<AnyCancellable>()

// 01-1. 取最小值
//example(of: "min()") {
//
//    let publisher = [1, -50, 246, 0].publisher
//
//    publisher
//        .print("publisher")
//        .min()
//        .sink(receiveValue: { print("最小值：\($0)") })
//        .store(in: &subscriptions)
//}

// 01-2. 取最小值 (自訂過濾條件)
//example(of: "min non-Comparable") {
//
//    let publisher = ["12345", "ab", "hello world"]
//        .map { Data($0.utf8) }
//        .publisher
//
//    publisher
//        .print("publisher")
//        .min { $0.count < $1.count }
//        .sink { data in
//            guard let string = String(data: data, encoding: .utf8) else { return }
//            print("最小資料的是 \(string), \(string.count) bytes")
//        }.store(in: &subscriptions)
//}

// 02-1. 取最大值
//example(of: "max()") {
//
//    let publisher = ["A", "F", "Z", "E"].publisher
//
//    publisher
//        .print("publisher")
//        .max()
//        .sink(receiveValue: { print("最大值：\($0)") })
//        .store(in: &subscriptions)
//}

// 02-2. 取最大值 (要發佈結束，不然會一直等下去)
//example(of: "max()") {
//
//    let publisher = PassthroughSubject<Int, Never>()
//
//    publisher
//        .print("publisher")
//        .max()
//        .sink(receiveValue: { print("最大值：\($0)") })
//        .store(in: &subscriptions)
//
//    publisher.send(1)
//    publisher.send(2)
//    publisher.send(completion: .finished)
//}

// 03-1. 取第一個值
//example(of: "first()") {
//
//    let publisher = ["A", "F", "Z", "E"].publisher
//
//    publisher
//        .print("publisher")
//        .first()
//        .sink(receiveValue: { print("第一個值：\($0)") })
//        .store(in: &subscriptions)
//}

// 03-2. 取第一個值 (自訂過濾條件)
//example(of: "first(where:)") {
//
//    let publisher = ["J", "O", "H", "N"].publisher
//
//    publisher
//        .print("publisher")
//        .first(where: { "Hello World".contains($0) })
//        .sink(receiveValue: { print("符合條件的第一個值：\($0)") })
//        .store(in: &subscriptions)
//}

// 04. 取最後一個值
//example(of: "last()") {
//
//    let publisher = ["A", "E", "I", "O", "U"].publisher
//
//    publisher
//        .print("publisher")
//        .last()
//        .sink(receiveValue: { print("最後一個值：\($0)") })
//        .store(in: &subscriptions)
//}

// 05-1. 取某一個值
//example(of: "output(at:)") {
//
//    let publisher = ["A", "E", "I", "O", "U"].publisher
//    let index = 2
//
//    publisher
//        .print("publisher")
//        .output(at: index)
//        .sink(receiveValue: { print("index = \(index)的值：\($0)") })
//        .store(in: &subscriptions)
//}

// 05-2. 取某區間的值
//example(of: "output(in:)") {
//
//    let publisher = ["A", "E", "I", "O", "U"].publisher
//    let range = 1...3
//
//    publisher
//        .output(in: range)
//        .sink(
//            receiveCompletion: { print($0) },
//            receiveValue: { print("區間內的值：\($0)") }
//        )
//        .store(in: &subscriptions)
//}

// 06. 取得數量
//example(of: "count()") {
//
//    let publisher = ["A", "B", "C"].publisher
//
//    publisher
//        .print("publisher")
//        .count()
//        .sink(receiveValue: { print("有\($0)個項目") })
//        .store(in: &subscriptions)
//}

// 07-1. 處理包含的值
//example(of: "contains()") {
//
//    let publisher = ["A", "B", "C", "D", "E"].publisher
//    let letter = "C"
//
//    publisher
//        .print("publisher")
//        .contains(letter)
//        .sink(receiveValue: { isContains in
//            print(isContains ? "Publisher包含 - \(letter)" : "Publisher不包含 - \(letter)!")
//        })
//        .store(in: &subscriptions)
//}

// 07-2. 處理包含的值 (自訂過濾條件)
//example(of: "contains(where:)") {
//
//    struct Person {
//        let id: Int
//        let name: String
//    }
//
//    let people = [(123, "Shai Mishali"), (777, "Marin Todorov"), (214, "Florent Pillet")]
//        .map(Person.init)
//        .publisher
//
//    people
//        .contains(where: { $0.id == 800 || $0.name == "Marin Todorov" })
//        .sink(receiveValue: { isContains in
//            print(isContains ? "有找到符合條件的值" : "沒有找到符合條件的值")
//        })
//        .store(in: &subscriptions)
//}

// 08. 找到所有符合條件的值
//example(of: "allSatisfy()") {
//
//    let publisher = stride(from: 0, to: 5, by: 1).publisher
//    let condition: (Int) -> Bool = { $0 % 2 == 0 }
//
//    publisher
//        .print("publisher")
//        .allSatisfy { condition($0) }
//        .sink(receiveValue: { isAllEven in
//            print(isAllEven ? "全部都是偶數" : "不全都是偶數")
//        })
//        .store(in: &subscriptions)
//}

// 09. 依照條件合併
//example(of: "reduce()") {
//
//    let publisher = ["Hel", "lo", " ", "Wor", "ld", "!"].publisher
//
//    publisher
//        .print("publisher")
//        .reduce("", +)
//        .sink(receiveValue: { print("合併為：\($0)") })
//        .store(in: &subscriptions)
//}

