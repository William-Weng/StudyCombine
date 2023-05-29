import Foundation
import Combine

var subscriptions = Set<AnyCancellable>()

// 01. 將單一值做分組
//example(of: "collect") {
//
//    let array = ["A", "B", "C", "D", "E"]
//
//    array.publisher
//        .collect(2)     // 2個2個一組，預設是1組；如果不加它的話，就是一個一個單獨輸出
//        .sink(
//            receiveCompletion: { print($0) },
//            receiveValue: { print($0) }
//        )
//        .store(in: &subscriptions)
//}

// 02. 把值一個個處理，然後轉成另一種數值
//example(of: "map") {
//
//    let array = [123, 4, 56]
//    let formatter = NumberFormatter()
//
//    formatter.numberStyle = .spellOut
//
//    array.publisher
//        .map({ value in
//            formatter.string(for: NSNumber(integerLiteral: value)) ?? ""
//        })
//        .sink(receiveValue: { print($0) })
//        .store(in: &subscriptions)
//}

// 03. 使用座標(x,y)當成map()的範例
//example(of: "mapping key paths") {
//
//    let publisher = PassthroughSubject<Coordinate, Never>()
//
//    publisher
//        .map(\.x, \.y)      // 也可以這樣取值 (Coordinate.x / Coordinate.y)
//        .sink(receiveValue: { x, y in
//            guard let quadrant = quadrantOf(x: x, y: y) else { print("座標在 (\(x), \(y)) 在軸上"); return }
//            print("座標在 (\(x), \(y)) 第\(quadrant)象限")
//        })
//        .store(in: &subscriptions)
//
//    publisher.send(Coordinate(x: 10, y: -8))
//    publisher.send(Coordinate(x: 0, y: 5))
//}

// 04. 會處理錯誤的map
//example(of: "tryMap") {
//
//    Just("資料夾名稱不存在!!!")
//        .tryMap { try FileManager.default.contentsOfDirectory(atPath: $0) }
//        .sink(
//            receiveCompletion: { print("Completion: \($0)") },
//            receiveValue: { print("ReceiveValue: \($0)") }
//        )
//        .store(in: &subscriptions)
//}

// 05. Publishers => 單一個Publisher (Publisher轉換)
//example(of: "flatMap") {
//
//    func decode(_ codes: [Int]) -> AnyPublisher<String, Never> {
//
//        Just(codes.compactMap { code in
//            guard (32...255).contains(code) else { return nil }
//            return String(UnicodeScalar(code) ?? " ")
//        }.joined())
//        .eraseToAnyPublisher()
//    }
//
//    let array = [72, 101, 108, 108, 111, 44, 32, 87, 111, 114, 108, 100, 33, 33, 33]    /// Hello, World!!! (ASCII)
//
//    array.publisher
//        .collect()
//        .flatMap(decode)                                                                /// 可以接收一個個數值 Publishers => 單一個Publisher
//        .sink(receiveValue: { print($0) })
//        .store(in: &subscriptions)
//}

// 06. 處理nil數值 => 有點像 (value ?? "-")
//example(of: "replaceNil") {
//    ["A", nil, "C"].publisher
//        .eraseToAnyPublisher()
//        .replaceNil(with: "-")      /// 可以試試不使用它的結果
//        .sink(receiveValue: { print($0) })
//        .store(in: &subscriptions)
//}

// 07. 處理空值 => 用在演示或測試用
//example(of: "replaceEmpty(with:)") {
//
//    let empty = Empty<String, Never>()
//
//    empty
//        .replaceEmpty(with: "Test")      /// 可以試試不使用它的結果
//        .sink(
//            receiveCompletion: { print($0) },
//            receiveValue: { print($0) }
//        )
//        .store(in: &subscriptions)
//}

// 08. 累加 => 很像reduce()
//example(of: "scan") {
//    
//    let initValue = 50
//    let maxCount = 10
//    var dailyGainLoss: Int { .random(in: -maxCount...maxCount) }    /// 將產生-10 ~ 10的隨時數
//    
//    let june2023 = (0..<maxCount)                                   /// 產生10組
//        .map { _ in dailyGainLoss }                                 /// [Int]
//        .publisher
//    
//    june2023
//        .scan(initValue) { latest, current in
//            max(0, latest + current)                                /// 累加
//        }
//        .sink(receiveValue: { _ in })
//        .store(in: &subscriptions)
//}

