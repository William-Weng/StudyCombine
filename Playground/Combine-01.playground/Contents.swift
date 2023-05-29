import Foundation
import Combine

var subscriptions = Set<AnyCancellable>()

// 01. 通知 - Notification
//example(of: "Notification") {
//
//    let myNotification = Notification.Name("MyNotification")
//    let center = NotificationCenter.default
//    let observer = center.addObserver(forName: myNotification, object: nil, queue: nil) { notification in print("\(notification.object!)") }
//    let object = "「張君雅小妹妹，恁兜的泡麵已經煮好了，恁阿嬤限妳一分鐘內趕緊回去呷；哪嘸，到時麵若爛去，伊是概不負責！」"
//
//    center.post(name: myNotification, object: object)
//    center.removeObserver(observer)
//}

// 02. 發布者 - Publisher
//example(of: "Publisher") {
//
//    let myNotification = Notification.Name("MyNotification")
//    let center = NotificationCenter.default
//    let publisher = center.publisher(for: myNotification, object: nil)
//
//    center.post(name: myNotification, object: nil)
//}

// 03. 訂閱者 - Subscriber
//example(of: "Subscriber") {
//
//    let myNotification = Notification.Name("MyNotification")
//    let center = NotificationCenter.default
//    let publisher = center.publisher(for: myNotification, object: nil)
//    let subscription = publisher.sink { _ in print("收到從發布者傳來的通知了") }
//
//    center.post(name: myNotification, object: nil)
//    subscription.cancel()
//}

// 04. Just - 基本的Publisher
//example(of: "Just") {
//
//    let just = Just("Hello world!")
//
//    let subscription_1 = just.sink(
//        receiveCompletion: {
//            print("Received completion: ", $0)
//        },
//        receiveValue: {
//            print("Received value: ", $0)
//        })
//
//    let subscription_2 = just.sink(
//        receiveCompletion: {
//            print("Received completion (another): ", $0)
//        },
//        receiveValue: {
//            print("Received value (another): ", $0)
//        })
//
//    subscription_1.cancel()
//    subscription_2.cancel()
//}


// 05. 儲存數值 - assign(to:on:)
//example(of: "assign(to:on:)") {
//
//    final class SomeObject {
//        var value: String = "" {
//            didSet { print(value) }
//        }
//    }
//
//    let array = ["Hello", "world!"]
//    let object = SomeObject()
//    let publisher = array.publisher
//
//    _ = publisher.assign(to: \.value, on: object)
//}

// 06. 儲存數值 - assign(to:)
//example(of: "assign(to:)") {
//
//    final class SomeObject {
//        @Published var value = 0
//    }
//
//    let object = SomeObject()
//    object.$value.sink { print("收到的值為: \($0)") }
//
//    (0..<10).publisher.assign(to: &object.$value)
//}

// 07. 自訂Subscriber
//example(of: "Custom Subscriber") {
//
//    final class MagazineSubscriber: Subscriber {
//
//        typealias Input = String                                // 雜誌名稱是文字
//        typealias Failure = Never                               // 不處理錯誤
//
//        private let maxCount = 3
//
//        private var count = 0
//        private var subscription: Subscription?
//
//        func receive(subscription: Subscription) {
//            print(subscription)
//
//            self.subscription = subscription                    // 在這裡，你可以保存subscription，並告訴出版社你要接收雜誌
//            subscription.request(.unlimited)                    // 請求出版商無限制數量的雜誌
//        }
//
//        func receive(_ input: Input) -> Subscribers.Demand {
//
//            print("Received value", input, count)               // 在這裡，你可以處理收到的雜誌內容
//            count += 1
//
//            if (count >= maxCount) { subscription?.cancel() }   // 它表明訂閱者不再需要額外的項目 (目標到達，取消訂閱)
//            return .unlimited                                   // 請求接收更多的雜誌
//        }
//
//        func receive(completion: Subscribers.Completion<Never>) {
//            print("Received completion", completion)
//        }
//    }
//
//    let magazines = ["ABC互動英語", "LIVE互動英語", "CNN互動英語", "互動日本語", "跟我一起學日語", "KOREA韓語學習誌"]
//
//    let publisher = magazines.publisher                         // Array => Publisher
//    let subscriber = MagazineSubscriber()
//
//    publisher.subscribe(subscriber)
//}

// 08. Future - 非同步的Publisher
//example(of: "Future") {
//
//    func futureIncrement(integer: Int, afterDelay delay: UInt32) -> Future<Int, Never> {
//
//        Future<Int, Never> { promise in
//            print("Original => \(integer)")
//            sleep(delay)
//            promise(.success(integer + 1))
//        }
//    }
//
//    let future = futureIncrement(integer: 1, afterDelay: 3)
//
//    future
//        .sink(receiveCompletion: { print("Completion => \($0)") }, receiveValue: { print("Value => \($0)") })
//        .store(in: &subscriptions)
//
//    future
//        .sink(receiveCompletion: { print("Completion => \($0)") }, receiveValue: { print("Value => \($0)") })
//        .store(in: &subscriptions)
//}

// 09. PassthroughSubject - Publisher 延展類
//example(of: "PassthroughSubject") {
//
//    enum MyError: Error {
//        case test
//    }
//
//    final class StringSubscriber: Subscriber {
//
//        typealias Input = String
//        typealias Failure = MyError
//
//        func receive(subscription: Subscription) {
//            subscription.request(.max(2))
//        }
//
//        func receive(_ input: String) -> Subscribers.Demand {
//            print("Received value (input): ", input)
//            return input == "World" ? .max(1) : .none
//        }
//
//        func receive(completion: Subscribers.Completion<MyError>) {
//            print("Received completion (input): ", completion)
//        }
//    }
//
//    let subscriber = StringSubscriber()
//    let subject = PassthroughSubject<String, MyError>()
//
//    subject.subscribe(subscriber)
//
//    let subscription = subject
//        .sink(
//            receiveCompletion: { completion in print("Received completion (sink): ", completion) },
//            receiveValue: { value in print("Received value (sink): ", value) }
//        )
//
//    subject.send("Hello")
//    subject.send("World")
//
//    subscription.cancel()
//
//    subject.send("Still there?")
//
//    subject.send(completion: .failure(MyError.test))
//    subject.send(completion: .finished)
//
//    subject.send("How about another one?")
//}

// 10. CurrentValueSubject - Publisher 延展類
//example(of: "CurrentValueSubject") {
//    
//    let subject = CurrentValueSubject<Int, Never>(0)
//    
//    subject
//        .print()
//        .sink(receiveValue: { print("First subscription: \($0)") })
//        .store(in: &subscriptions)
//    
//    subject.send(1)
//    subject.send(2)
//    
//    print(subject.value)
//    
//    subject.value = 3
//    print(subject.value)
//
//    subject
//        .print()
//        .sink(receiveValue: { print("Second subscription:", $0) })
//        .store(in: &subscriptions)
//    
//    subject.send(completion: .finished)
//}

// 11. 自動校正Demand
//example(of: "Dynamically adjusting Demand") {
//
//    final class IntSubscriber: Subscriber {
//
//        typealias Input = Int
//        typealias Failure = Never
//
//        func receive(subscription: Subscription) {
//            subscription.request(.max(3))   // .max(3): 初始值
//        }
//
//        func receive(_ input: Int) -> Subscribers.Demand {
//
//            print("Received value", input)
//
//            switch input {                  // 累加的 =>
//            case 1: return .max(2)          // .max(3) + .max(2) = .max(4)
//            case 3: return .max(1)          // .max(4) + .max(1) = .max(5)
//            default: return .none           // .max(5)
//            }
//        }
//
//        func receive(completion: Subscribers.Completion<Never>) {
//            print("Received completion: ", completion)
//        }
//    }
//
//    let subscriber = IntSubscriber()
//    let subject = PassthroughSubject<Int, Never>()
//
//    subject.subscribe(subscriber)
//
//    (1...10).forEach { subject.send($0) }
//}

// 12. 轉成AnyPublisher
//example(of: "Type erasure") {
//
//    let subject = PassthroughSubject<Int, Never>()  // PassthroughSubject<Int, Never>
//    let publisher = subject.eraseToAnyPublisher()   // PassthroughSubject<Int, Never> => AnyPublisher<Int, Never>
//
//    publisher
//        .sink(receiveValue: { print($0) })
//        .store(in: &subscriptions)
//
//    subject.send(0)
//    // publisher.send(1)    // ∵ 轉成了AnyPublisher<Int, Never> ∴ 沒有send()
//}

// 13. async / await
//example(of: "async / await") {
//
//    let subject = CurrentValueSubject<Int, Never>(0)    // 設定初值 = 0
//
//    Task {
//        for await element in subject.values { print("Element: \(element)") }
//        print("Completed.")
//    }
//
//    sleep(2)
//    subject.send(1)     // 可以使用在非同步之上
//    sleep(2)
//    subject.send(2)
//    sleep(2)
//    subject.send(3)
//
//    subject.send(completion: .finished)
//}

