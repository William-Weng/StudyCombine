import UIKit
import Combine

var subscriptions = Set<AnyCancellable>()

// 01. 在原本的publisher之前加入數值
//example(of: "prepend(Output...)") {
//
//    let publisher = ["新會員", "William"].publisher
//
//    publisher
//        .prepend("歡迎來到『人生40才開始』", "別忘了繳入會費喲")   // 再在前面加上 ["歡迎來到『人生40才開始』", "別忘了繳入會費喲"]
//        .prepend("嗨!!!", "您好")                            // 先在前面加上 ["嗨!!!", "您好"]  => ["嗨!!!", "您好", "歡迎來到『人生40才開始』", "別忘了繳入會費喲"]
//        .sink(receiveValue: { print($0) })
//        .store(in: &subscriptions)
//}

// 02. 遵循Sequence Protocol的都可以使用
//example(of: "prepend(Sequence)") {
//
//    let publisher = [5, 6, 7].publisher
//    let array = [3, 4]                              // Array也可以
//    let set = Set(1...2)                            // Set也可以
//    let stride = stride(from: 6, to: 11, by: 2)     // Stride也可以
//
//    publisher
//        .prepend(array)
//        .prepend(set)
//        .prepend(stride)
//        .sink(receiveValue: { print($0) })
//        .store(in: &subscriptions)
//}

// 03. publisher也可以
//example(of: "prepend(Publisher)") {
//
//    let publisher1 = [3, 4].publisher
//    let publisher2 = [1, 2].publisher
//
//    publisher1
//        .prepend(publisher2)
//        .sink(receiveValue: { print($0) })
//        .store(in: &subscriptions)
//}

//example(of: "prepend(Publisher) #2") {
//
//    let publisher1 = [3, 4].publisher
//    let publisher2 = PassthroughSubject<Int, Never>()
//
//    publisher1
//        .prepend(publisher2)
//        .sink(receiveValue: { print($0) })
//        .store(in: &subscriptions)
//
//    publisher2.send(1)
//    publisher2.send(2)
//    publisher2.send(completion: .finished)
//}

// 04. append正好跟prepend相反
//example(of: "append(Output...)") {
//
//    let publisher = ["您好", "我是William"].publisher
//
//    publisher
//        .append("-演出人員名單-", "-配樂清單-")
//        .append("~終~")
//        .sink(receiveValue: { print($0) })
//        .store(in: &subscriptions)
//}

//example(of: "append(Output...) #2") {
//
//    let publisher = PassthroughSubject<Int, Never>()
//
//    publisher
//        .append(3, 4)
//        .append(5)
//        .sink(receiveValue: { print($0) })
//        .store(in: &subscriptions)
//
//    publisher.send(1)
//    publisher.send(2)
//    publisher.send(completion: .finished)
//}

// 05. 跟prepend(Sequence)相反
//example(of: "append(Sequence)") {
//
//    let publisher = [1, 2, 3].publisher
//
//    publisher
//        .append([4, 5])
//        .append(Set([6, 7]))
//        .append(stride(from: 8, to: 11, by: 2))
//        .sink(receiveValue: { print($0) })
//        .store(in: &subscriptions)
//}

// 06. 跟prepend(Publisher)相反
//example(of: "append(Publisher)") {
//
//    let publisher1 = [1, 2].publisher
//    let publisher2 = [3, 4].publisher
//
//    publisher1
//        .append(publisher2)
//        .sink(receiveValue: { print($0) })
//        .store(in: &subscriptions)
//}

// 07. 切換到最後一個Publisher
//example(of: "switchToLatest") {
//
//    let publisher1 = PassthroughSubject<String, Never>()
//    let publisher2 = PassthroughSubject<String, Never>()
//    let publisher3 = PassthroughSubject<String, Never>()
//    let publishers = PassthroughSubject<PassthroughSubject<String, Never>, Never>()
//
//    publishers
//        .switchToLatest()           // 會切到最後一個publisher
//        .sink(
//            receiveCompletion: { _ in print("Completed!") },
//            receiveValue: { print($0) }
//        )
//        .store(in: &subscriptions)
//
//    publishers.send(publisher1)         // 切換到publisher1
//    publisher1.send("publisher1 - 1")   // 此時會執行 - publisher1 => 1, 2
//    publisher1.send("publisher1 - 2")
//
//    publishers.send(publisher2)         // 切換到publisher2
//    publisher1.send("publisher1 - 3")   // 此時這行不會執行 => ∵ 切換到publisher2 => 4, 5
//    publisher2.send("publisher2 - 4")
//    publisher2.send("publisher2 - 5")
//
//    publishers.send(publisher3)         // 切換到publisher3
//    publisher2.send("publisher2 - 6")   // 此時這行不會執行 => ∵ 切換到publisher3 => 7, 8, 9
//    publisher3.send("publisher3 - 7")
//    publisher3.send("publisher3 - 8")
//    publisher3.send("publisher3 - 9")
//
//    publisher3.send(completion: .finished)
//    publishers.send(completion: .finished)
//}

// 08. switchToLatest網路應用
//example(of: "switchToLatest - Network Request") {
//
//    let url = URL(string: "https://picsum.photos/128")!
//    let taps = PassthroughSubject<Void, Never>()
//
//    taps.map { _ in getImage() }
//        .switchToLatest()
//        .sink(receiveValue: { _ in })
//        .store(in: &subscriptions)
//
//    taps.send()                                                                            // 下載圖片動作
//    DispatchQueue.main.asyncAfter(deadline: .now() + 3.0) { print(Date()); taps.send() }
//    DispatchQueue.main.asyncAfter(deadline: .now() + 3.1) { print(Date()); taps.send() }
//    DispatchQueue.main.asyncAfter(deadline: .now() + 3.2) { print(Date()); taps.send() }
//    DispatchQueue.main.asyncAfter(deadline: .now() + 3.3) { print(Date()); taps.send() }
//    DispatchQueue.main.asyncAfter(deadline: .now() + 3.4) { print(Date()); taps.send() }   // 只會留這一個下載圖片動作
//
//    func getImage() -> AnyPublisher<UIImage?, Never> {
//
//        URLSession.shared
//            .dataTaskPublisher(for: url)
//            .map { data, _ in UIImage(data: data) }
//            .print("[image]")
//            .replaceError(with: nil)
//            .eraseToAnyPublisher()
//    }
//}

// 09. 把Publisher們合併在一起
//example(of: "merge(with:)") {
//
//    let publisher1 = PassthroughSubject<Int, Never>()
//    let publisher2 = PassthroughSubject<Int, Never>()
//
//    publisher1
//        .merge(with: publisher2)
//        .sink(
//            receiveCompletion: { _ in print("Completed") },
//            receiveValue: { print($0) }
//        )
//        .store(in: &subscriptions)
//
//    publisher1.send(1)
//    publisher1.send(2)
//
//    publisher2.send(3)
//
//    publisher1.send(4)
//
//    publisher2.send(5)
//
//    publisher1.send(completion: .finished)
//    publisher2.send(completion: .finished)
//}

// 10. 合併最後的一個publisher
//example(of: "combineLatest") {
//
//    let publisher1 = PassthroughSubject<Int, Never>()
//    let publisher2 = PassthroughSubject<String, Never>()
//
//    publisher1
//        .combineLatest(publisher2)
//        .sink(
//            receiveCompletion: { _ in print("Completed") },
//            receiveValue: { print("(\($0), \($1))") }
//        )
//        .store(in: &subscriptions)
//
//    publisher1.send(1)
//    publisher2.send("a")
//
//    publisher1.send(2)
//    publisher2.send("b")
//
//    publisher1.send(3)
//    publisher2.send("c")
//
//    publisher1.send(completion: .finished)
//    publisher2.send(completion: .finished)
//}

// 11. 一對一合併
//example(of: "zip") {
//    
//    let publisher1 = PassthroughSubject<Int, Never>()
//    let publisher2 = PassthroughSubject<String, Never>()
//    
//    publisher1
//        .zip(publisher2)
//        .sink(
//            receiveCompletion: { _ in print("Completed") },
//            receiveValue: { print("(\($0) ,\($1))") }
//        )
//        .store(in: &subscriptions)
//    
//    publisher1.send(1)
//    publisher1.send(2)
//    publisher2.send("a")
//    publisher2.send("b")
//    publisher1.send(3)
//    publisher2.send("c")
//    publisher2.send("d")
//    publisher1.send(4)
//    publisher2.send("e")
//    
//    publisher1.send(completion: .finished)
//    publisher2.send(completion: .finished)
//}
