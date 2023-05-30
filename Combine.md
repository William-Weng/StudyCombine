# [Swift Combine - iOS 13](https://developer.apple.com/documentation/combine)

## [轉移到 Combine](https://medium.com/jeremy-xue-s-blog/swift-轉移到-combine-9b9cc91a0748)
- 先做一個[公用程式](https://heckj.github.io/swiftui-notes/index_zh-CN.html)，印出範例用…
- 其實，Combine的功能有很大一部分是用到[Result&lt;Value, Error>](https://medium.com/彼得潘的-swift-ios-app-開發問題解答集/成功和失敗二擇一的-result-type-e234c6fccc9c)的設定，成功和失敗二擇一的參數應用…
- Combine也是有所謂的[生命週期](https://ithelp.ithome.com.tw/articles/10217930)
- 當然[RxJS Marbles的彈珠圖](https://rxmarbles.com/)也是可以參考的…
```swift
public func example(of description: String, action: () -> Void) {
    print("\n=== 範例: \(description) ===")
    action()
}
```


## Lesson.01 - Notification vs Combine
### [通知 - Notification](https://www.appcoda.com.tw/notificationcenter/)
- 先以一個iOS基本的Notification為基準
- 
```swift
example(of: "Notification") {
    
    let myNotification = Notification.Name("MyNotification")
    let center = NotificationCenter.default
    let observer = center.addObserver(forName: myNotification, object: nil, queue: nil) { notification in print("\(notification.object!)") }
    let object = "「張君雅小妹妹，恁兜的泡麵已經煮好了，恁阿嬤限妳一分鐘內趕緊回去呷；哪嘸，到時麵若爛去，伊是概不負責！」"
    
    center.post(name: myNotification, object: object)
    center.removeObserver(observer)
}
```
```bash
=== 範例: Notification ===
「張君雅小妹妹，恁兜的泡麵已經煮好了，恁阿嬤限妳一分鐘內趕緊回去呷；哪嘸，到時麵若爛去，伊是概不負責！」
```

### [發布者 - Publisher](https://developer.apple.com/documentation/foundation/notificationcenter/publisher)
- 可以類比成NotificationCenter.default.post()的功能
- 有發布訊息的功能 (單向)
- 
```swift
example(of: "Publisher") {
    
    let myNotification = Notification.Name("MyNotification")
    let center = NotificationCenter.default
    let publisher = center.publisher(for: myNotification, object: nil)
    
    center.post(name: myNotification, object: nil)
}
```

### 訂閱者 - Subscriber
- 可以類比成NotificationCenter.default.addObserver()的功能
- 有收接訊息的功能 (單向)
- 
```swift
example(of: "Subscriber") {
    
    let myNotification = Notification.Name("MyNotification")
    let center = NotificationCenter.default
    let publisher = center.publisher(for: myNotification, object: nil)
    let subscription = publisher.sink { _ in print("收到從發布者傳來的通知了") }
    
    center.post(name: myNotification, object: nil)
    subscription.cancel()
}
```

## 我心中的Combine
![](image/Combine.png)

## 初學Publisher
### Just
- 使用Combine時，最基本的Publisher
- 一個發布者，可由多個訂閱者接收
- 
```swift
example(of: "Just") {
    
    let just = Just("Hello world!")
    
    let subscription_1 = just.sink(
        receiveCompletion: {
            print("Received completion: ", $0)
        },
        receiveValue: {
            print("Received value: ", $0)
        })
    
    let subscription_2 = just.sink(
        receiveCompletion: {
            print("Received completion (another): ", $0)
        },
        receiveValue: {
            print("Received value (another): ", $0)
        })
    
    subscription_1.cancel()
    subscription_2.cancel()
}
```
```bash
=== 範例: Just ===
Received value:  Hello world!
Received completion:  finished
Received value (another):  Hello world!
Received completion (another):  finished
```

## Combine運算子
### [儲存數值 - assign(to:on:)](https://developer.apple.com/documentation/combine/just/assign(to:on:&#41;)
- 萬物都可以轉成Publisher，試著把Array轉成Publisher
- 利用assign(to:on:)，把發布者發布的值存到變數裡面
- 從didSet()取值 => [KVO - Key-Value Observing](https://davidlinnn.medium.com/swift-4-kvo-筆記-4c89a996e022)
- 
```swift
example(of: "assign(to:on:)") {
    
    final class SomeObject {
        var value: String = "" {
            didSet { print(value) }
        }
    }
    
    let array = ["Hello", "world!"]
    let object = SomeObject()
    let publisher = array.publisher
    
    _ = publisher.assign(to: \.value, on: object)
}
```
```bash
=== 範例: assign(to:on:) ===
Hello
world!
```

### [儲存數值 - assign(to:)](https://developer.apple.com/documentation/combine/just/assign(to:&#41;)
- 這是個相當經典的例子
- 利用[@Published](https://medium.com/彼得潘的-swift-ios-app-開發教室/swiftui-什麼是-published-observableobject-eb950f8295a)，將變數value轉成Publisher，這時候的value就要用$value來處理
- 而要存到變數value，就要使用&object來處理
- 使用[sink()](https://developer.apple.com/documentation/combine/just/sink(receivevalue:&#41;)取值，而不是從數值去取值了
- 
```swift
example(of: "assign(to:)") {
    
    final class SomeObject {
        @Published var value = 0
    }
    
    let object = SomeObject()
    object.$value.sink { print("收到的值為: \($0)") }
    
    (0..<10).publisher.assign(to: &object.$value)
}
```
```bash
=== 範例: assign(to:) ===
收到的值為: 0
收到的值為: 0
收到的值為: 1
收到的值為: 2
收到的值為: 3
收到的值為: 4
收到的值為: 5
收到的值為: 6
收到的值為: 7
收到的值為: 8
收到的值為: 9
```

### 自訂Subscriber
- 只要使用協定Subscriber就可以自己產生一個自訂Subscriber
- 如果使用subscription.request(.max(3)) + return .none，就只會印三個，而且不會結束
- 但如果把return .none改成return .unlimited，就只會印全部，而且會結束
- 
```swift
example(of: "Custom Subscriber") {

    final class MagazineSubscriber: Subscriber {

        typealias Input = String                                // 雜誌名稱是文字
        typealias Failure = Never                               // 不處理錯誤

        private let maxCount = 3
        
        private var count = 0
        private var subscription: Subscription?
        
        func receive(subscription: Subscription) {
            print(subscription)
            
            self.subscription = subscription                    // 在這裡，你可以保存subscription，並告訴出版社你要接收雜誌
            subscription.request(.unlimited)                    // 請求出版商無限制數量的雜誌
        }

        func receive(_ input: Input) -> Subscribers.Demand {

            print("Received value", input, count)               // 在這裡，你可以處理收到的雜誌內容
            count += 1
            
            if (count >= maxCount) { subscription?.cancel() }   // 它表明訂閱者不再需要額外的項目 (目標到達，取消訂閱)
            return .unlimited                                   // 請求接收更多的雜誌
        }

        func receive(completion: Subscribers.Completion<Never>) {
            print("Received completion", completion)
        }
    }

    let magazines = ["ABC互動英語", "LIVE互動英語", "CNN互動英語", "互動日本語", "跟我一起學日語", "KOREA韓語學習誌"]
    
    let publisher = magazines.publisher                         // Array => Publisher
    let subscriber = MagazineSubscriber()

    publisher.subscribe(subscriber)
}
```
```bash
=== 範例: Custom Subscriber ===
["ABC互動英語", "LIVE互動英語", "CNN互動英語", "互動日本語", "跟我一起學日語", "KOREA韓語學習誌"]
Received value ABC互動英語 0
Received value LIVE互動英語 1
Received value CNN互動英語 2
```

## Publisher
### [Future - 非同步Publisher](https://developer.apple.com/documentation/combine/future)
- 聽名字就知道，接收未來資料與事件[非同步](https://www.jianshu.com/p/c5dbc67fcfcb)的Publisher
- 在這裡我們讓它停止3秒，再顯示值
- 
```swift
var subscriptions = Set<AnyCancellable>()
example(of: "Future") {
    
    func futureIncrement(integer: Int, afterDelay delay: UInt32) -> Future<Int, Never> {
        
        Future<Int, Never> { promise in
            print("Original => \(integer)")
            sleep(delay)
            promise(.success(integer + 1))
        }
    }
    
    let future = futureIncrement(integer: 1, afterDelay: 3)
    
    future
        .sink(receiveCompletion: { print("Completion => \($0)") }, receiveValue: { print("Value => \($0)") })
        .store(in: &subscriptions)
    
    future
        .sink(receiveCompletion: { print("Completion => \($0)") }, receiveValue: { print("Value => \($0)") })
        .store(in: &subscriptions)
}
```
```bash
=== 範例: Future ===
Original => 1
Value => 2
Completion => finished
Value => 2
Completion => finished
```

## [Subject - Publisher 延展類](https://louyu.cc/articles/ios-swift/2021/03/?p=2857/)
### [PassthroughSubject](https://ithelp.ithome.com.tw/articles/10219418)
- 與之前我們討論的 Publisher 不同的是，Subject 的最大特點就是可以手動傳送資料
- 
```swift
example(of: "PassthroughSubject") {

    enum MyError: Error {
        case test
    }

    final class StringSubscriber: Subscriber {

        typealias Input = String
        typealias Failure = MyError

        func receive(subscription: Subscription) {
            subscription.request(.max(2))
        }

        func receive(_ input: String) -> Subscribers.Demand {
            print("Received value (input): ", input)
            return input == "World" ? .max(1) : .none
        }

        func receive(completion: Subscribers.Completion<MyError>) {
            print("Received completion (input): ", completion)
        }
    }

    let subscriber = StringSubscriber()
    let subject = PassthroughSubject<String, MyError>()

    subject.subscribe(subscriber)

    let subscription = subject
        .sink(
            receiveCompletion: { completion in print("Received completion (sink): ", completion) },
            receiveValue: { value in print("Received value (sink): ", value) }
        )

    subject.send("Hello")
    subject.send("World")

    subscription.cancel()

    subject.send("Still there?")

    // subject.send(completion: .failure(MyError.test))
    subject.send(completion: .finished)

    subject.send("How about another one?")
}
```
```bash
=== 範例: PassthroughSubject ===
Received value (sink):  Hello
Received value (input):  Hello
Received value (sink):  World
Received value (input):  World
Received value (input):  Still there?
Received completion:  finished
```

### [CurrentValueSubject - Publisher 延展類](https://www.avanderlee.com/combine/passthroughsubject-currentvaluesubject-explained/)
- 與 PassthroughSubject 不同，CurrentValueSubject 會保留一個最後的資料，並在被訂閱時將這個資料傳送給下游的 Publisher 或 Subscriber。
- 
```SWift
example(of: "CurrentValueSubject") {
    
    let subject = CurrentValueSubject<Int, Never>(0)	// 設定初值
    
    subject
        .print()
        .sink(receiveValue: { print("First subscription: \($0)") })
        .store(in: &subscriptions)
    
    subject.send(1)
    subject.send(2)
    
    print(subject.value)
    
    subject.value = 3
    print(subject.value)

    subject
        .print()
        .sink(receiveValue: { print("Second subscription:", $0) })
        .store(in: &subscriptions)
    
    subject.send(completion: .finished)
}
```
```bash
=== 範例: CurrentValueSubject ===
receive subscription: (CurrentValueSubject)
request unlimited
receive value: (0)
First subscription: 0
receive value: (1)
First subscription: 1
receive value: (2)
First subscription: 2
2
receive value: (3)
First subscription: 3
3
receive subscription: (CurrentValueSubject)
request unlimited
receive value: (3)
Second subscription: 3
receive finished
receive finished
```

### [自動校正Demand](https://developer.apple.com/documentation/combine/subscribers/demand)
- 這裡是自動根據輸入的值，去改變Subscribers.Demand
- 
```swift
example(of: "Dynamically adjusting Demand") {
    
    final class IntSubscriber: Subscriber {
        
        typealias Input = Int
        typealias Failure = Never
        
        func receive(subscription: Subscription) {
            subscription.request(.max(3))   // .max(3): 初始值
        }
        
        func receive(_ input: Int) -> Subscribers.Demand {
            
            print("Received value", input)
            
            switch input {                  // 累加的 =>
            case 1: return .max(2)          // .max(3) + .max(2) = .max(4)
            case 3: return .max(1)          // .max(4) + .max(1) = .max(5)
            default: return .none           // .max(5)
            }
        }
        
        func receive(completion: Subscribers.Completion<Never>) {
            print("Received completion: ", completion)
        }
    }
    
    let subscriber = IntSubscriber()
    let subject = PassthroughSubject<Int, Never>()
    
    subject.subscribe(subscriber)
    
    (1...10).forEach { subject.send($0) }
}
```
```bash
=== 範例: Dynamically adjusting Demand ===
Received value 1
Received value 2
Received value 3
Received value 4
Received value 5
Received value 6
```

### [eraseToAnyPublisher()](https://developer.apple.com/documentation/combine/publisher/erasetoanypublisher(;&#41)
- 轉成AnyPublisher
- 讓Publisher的類型[簡單化](https://ithelp.ithome.com.tw/articles/10221967)
- 
```swift
example(of: "Type erasure") {
    
    let subject = PassthroughSubject<Int, Never>()  // PassthroughSubject<Int, Never>
    let publisher = subject.eraseToAnyPublisher()   // PassthroughSubject<Int, Never> => AnyPublisher<Int, Never>
    
    publisher
        .sink(receiveValue: { print($0) })
        .store(in: &subscriptions)
    
    subject.send(0)
    // publisher.send(1)    // ∵ 轉成了AnyPublisher<Int, Never> ∴ 沒有send()
}
```
```bash
=== 範例: Type erasure ===
0
```

### async / await
- 非同步使用的範例
- 
```swift
example(of: "async / await") {
    
    let subject = CurrentValueSubject<Int, Never>(0)    // 設定初值 = 0
    
    Task {
        for await element in subject.values { print("Element: \(element)") }
        print("Completed.")
    }
    
    sleep(2)
    subject.send(1)     // 可以使用在非同步之上
    sleep(2)
    subject.send(2)
    sleep(2)
    subject.send(3)
    
    subject.send(completion: .finished)
}
```
```bash
=== 範例: async / await ===
Element: 0
Element: 1
Element: 2
Element: 3
Completed.
```

## Lesson.02 - Operators也是Publisher
### [collect()](https://juejin.cn/post/7017265258263740424)
- 將單一值做分組…
```swift
example(of: "collect") {
    
    let array = ["A", "B", "C", "D", "E"]
    
    array.publisher
        .collect(2)     // 2個2個一組，預設是1組；如果不加它的話，就是一個一個單獨輸出
        .sink(
            receiveCompletion: { print($0) },
            receiveValue: { print($0) }
        )
        .store(in: &subscriptions)
}
```
```bash
=== 範例: collect ===
["A", "B"]
["C", "D"]
["E"]
finished
```

### [map()](https://cocoacasts.com/combine-essentials-how-to-use-combine-map-and-compactmap-operators)
- 其實這個跟swift的[高階函數 - map](https://franksios.medium.com/swift3-高階函數-higher-order-function-a97cf4577a11)很像，把值一個個處理，然後轉成另一種數值…
```swift
example(of: "map") {
    
    let array = [123, 4, 56]
    let formatter = NumberFormatter()
    
    formatter.numberStyle = .spellOut
    
    array.publisher
        .map({ value in
            formatter.string(for: NSNumber(integerLiteral: value)) ?? ""
        })
        .sink(receiveValue: { print($0) })
        .store(in: &subscriptions)
}
```
```bash
=== 範例: map ===
one hundred twenty-three
four
fifty-six
```
- 使用座標(x,y)當成map()的範例
```swift
example(of: "mapping key paths") {

    let publisher = PassthroughSubject<Coordinate, Never>()
    
    publisher
        .map(\.x, \.y)      // 也可以這樣取值 (Coordinate.x / Coordinate.y)
        .sink(receiveValue: { x, y in
            guard let quadrant = quadrantOf(x: x, y: y) else { print("座標在 (\(x), \(y)) 在軸上"); return }
            print("座標在 (\(x), \(y)) 第\(quadrant)象限")
        })
        .store(in: &subscriptions)
    
    publisher.send(Coordinate(x: 10, y: -8))
    publisher.send(Coordinate(x: 0, y: 5))
}
```
```bash
=== 範例: mapping key paths ===
座標在 (10, -8) 第4象限
座標在 (0, 5) 在軸上
```

### [tryMap()](https://juejin.cn/post/7023214404007264263)
- 有錯誤處理的map
```swift
example(of: "tryMap") {
    
    Just("資料夾名稱不存在!!!")
        .tryMap { try FileManager.default.contentsOfDirectory(atPath: $0) }
        .sink(
            receiveCompletion: { print("Completion: \($0)") },
            receiveValue: { print("ReceiveValue: \($0)") }
        )
        .store(in: &subscriptions)
}
```
```bash
=== 範例: tryMap ===
Completion: failure(Error Domain=NSCocoaErrorDomain Code=260 "The folder “資料夾名稱不存在!!!” doesn’t exist." UserInfo={NSUserStringVariant=(
    Folder
), NSFilePath=資料夾名稱不存在!!!, NSUnderlyingError=0x600003aff900 {Error Domain=NSPOSIXErrorDomain Code=2 "No such file or directory"}})
```

### [flatMap()](https://kingnight.github.io/programming/2020/10/29/Combine中重要函数flatMap.html)
- 字如其義，就是扁平化的意思 - flat，把Publishers => 單一個Publisher (Publisher轉換)
```swift
example(of: "flatMap") {
    
    func decode(_ codes: [Int]) -> AnyPublisher<String, Never> {
        
        Just(codes.compactMap { code in
            guard (32...255).contains(code) else { return nil }
            return String(UnicodeScalar(code) ?? " ")
        }.joined())
        .eraseToAnyPublisher()
    }
    
    let array = [72, 101, 108, 108, 111, 44, 32, 87, 111, 114, 108, 100, 33, 33, 33]    /// Hello, World!!! (ASCII)
    
    array.publisher
        .collect()
        .flatMap(decode)                                                                /// 可以接收一個個數值 Publishers => 單一個Publisher
        .sink(receiveValue: { print($0) })
        .store(in: &subscriptions)
}
```
```bash
=== 範例: flatMap ===
Hello, World!!!
```

### [replaceNil(with:)](https://cocoacasts.com/combine-essentials-how-to-use-combine%27s-replacenil-operator)
- 字如其義，就是處理nil值，有點像 (value ?? "-")
```swift
// 06. 處理nil數值 => 有點像 (value ?? "-")
example(of: "replaceNil") {
    ["A", nil, "C"].publisher
        .eraseToAnyPublisher()
        .replaceNil(with: "-")      /// 可以試試不使用它的結果
        .sink(receiveValue: { print($0) })
        .store(in: &subscriptions)
}
```
```bash
=== 範例: replaceNil ===
A
-
C
```

### [replaceEmpty(with:)](https://juejin.cn/post/7017356750735015966)
- 字如其義，就是處理空值，用在演示或測試用
- ```swift
example(of: "replaceEmpty(with:)") {
    
    let empty = Empty<String, Never>()
    
    empty
        .replaceEmpty(with: "Test")      /// 可以試試不使用它的結果
        .sink(
            receiveCompletion: { print($0) },
            receiveValue: { print($0) }
        )
        .store(in: &subscriptions)
}
```
```bash
=== 範例: replaceEmpty(with:) ===
Test
finished
```

### [scan()](https://juejin.cn/s/swift combine scan example)
- 累加之用，很像[reduce()](https://medium.com/彼得潘的-swift-ios-app-開發教室/array-的高階函式-filter-map-and-reduce-39fb8ba5a9f7)
- ```swift
example(of: "scan") {
    
    let initValue = 50
    let maxCount = 10
    var dailyGainLoss: Int { .random(in: -maxCount...maxCount) }    /// 將產生-10 ~ 10的隨時數
    
    let june2023 = (0..<maxCount)                                   /// 產生10組
        .map { _ in dailyGainLoss }                                 /// [Int]
        .publisher
    
    june2023
        .scan(initValue) { latest, current in
            max(0, latest + current)                                /// 累加
        }
        .sink(receiveValue: { _ in })
        .store(in: &subscriptions)
}
```
![](image/Scan.png)

## Lesson.03 - 過濾用的Operator
### [filter()](https://www.kodeco.com/books/combine-asynchronous-programming-with-swift/v2.0/chapters/4-filtering-operators)
- 過濾之用，跟[filter()](https://www.inote.tw/swift-array-filter)很像
- ```swift
example(of: "filter") {
    
    let multiple = 3
    let numbers = (1...10).publisher
    
    numbers
        .filter { $0.isMultiple(of: multiple) }
        .sink(receiveValue: { number in print("\(number) 是 \(multiple) 的倍數 !!!")})
        .store(in: &subscriptions)
}
```
```bash
=== 範例: filter ===
3 是 3 的倍數 !!!
6 是 3 的倍數 !!!
9 是 3 的倍數 !!!
```

### [removeDuplicates()](https://paigeshin1991.medium.com/swift-combine-removeduplicates-you-can-totally-misuse-it-if-you-dont-read-this-9bf9c3c36296)
- 取得非重複資料，跟SQL的[SELECT DISTINCT](https://www.fooish.com/sql/distinct.html)功能很像
```swift
example(of: "removeDuplicates") {

  let words = "hey hey there! want to listen to mister mister ?"
                  .components(separatedBy: " ")
                  .publisher
  words
    .removeDuplicates()
    .sink(receiveValue: { print($0) })
    .store(in: &subscriptions)
}
```
```bash
hey
there!
want
to
listen
to
mister
?
```

### [compactMap()](https://juejin.cn/post/7017623451858894862)
- 把Optional值去除，跟[compactMap()](https://medium.com/jeremy-xue-s-blog/swift-transforming-an-array-e2bcb4f4d67d)很像
```swift
example(of: "compactMap") {
    
    let strings = ["a", "1.24", "3", "def", "45", "0.23"].publisher
    
    strings
        .compactMap { Float($0) }               /// 過濾Float
        .sink(receiveValue: { print($0) })
        .store(in: &subscriptions)
}
```
```bash
=== 範例: compactMap ===
1.24
3.0
45.0
0.23
```

### [ignoreOutput()](https://www.kodeco.com/books/combine-asynchronous-programming-with-swift/v3.0/chapters/4-filtering-operators)
- 取得的值不重要，只關心[完成](https://zhuanlan.zhihu.com/p/341961251)了沒有
```swift
example(of: "ignoreOutput") {

    let numbers = (1...10_000).publisher

    numbers
        .ignoreOutput()
        .sink(
            receiveCompletion: { print("完成: \($0)") },
            receiveValue: { print($0) }
        )
        .store(in: &subscriptions)
}
```
```bash
=== 範例: ignoreOutput ===
完成: finished
```

### [first(where:)](https://juejin.cn/post/7017623451858894862)
- 取得第一個符合過濾的值
```swift
example(of: "first(where:)") {
    
    let multiple = 2
    let numbers = (1...9).publisher
    
    numbers
        .print("numbers")
        .first(where: { $0 % multiple == 0 })
        .sink(
            receiveCompletion: { print("完成: \($0)") },
            receiveValue: { print("第一個偶數: \($0)") }
        )
        .store(in: &subscriptions)
}
```
```bash
=== 範例: first(where:) ===
numbers: receive subscription: (1...9)
numbers: request unlimited
numbers: receive value: (1)
numbers: receive value: (2)
numbers: receive cancel
第一個偶數: 2
完成: finished
```

### [last(where:)](https://juejin.cn/post/7017623451858894862)
- 取得最後一個符合過濾的值
- 取得第一個很簡單，只要有符合就行了；但是最後一個的話，就要finished才可以
```swift
example(of: "last(where:)") {
    
    let numbers = PassthroughSubject<Int, Never>()
    
    numbers
        .last(where: { $0 % 2 == 0 })
        .sink(
            receiveCompletion: { print("完成: \($0)") },
            receiveValue: { print("最後一個偶數: \($0)") }
        )
        .store(in: &subscriptions)
    
    numbers.send(1)
    numbers.send(2)
    numbers.send(3)
    numbers.send(4)
    numbers.send(5)
    numbers.send(completion: .finished)		/// 要執行這個後才有值
}
```
```bash
=== 範例: last(where:) ===
最後一個偶數: 4
完成: finished
```

### [dropFirst()](https://www.kodeco.com/books/combine-asynchronous-programming-with-swift/v3.0/chapters/4-filtering-operators)
- 忽略掉前面的值
```swift
example(of: "dropFirst") {
    
    let numbers = (1...10).publisher
    
    numbers
        .dropFirst(8)       /// 忽略掉前8組
        .sink(receiveValue: { print($0) })
        .store(in: &subscriptions)
}
```
```bash
=== 範例: dropFirst ===
9
10
```

### [drop(while:)](https://juejin.cn/post/7017853525271150599)
- 有條件的忽略掉數值
```swift
example(of: "drop(while:)") {

    let numbers = (1...10).publisher

    numbers
        .drop(while: { print("x"); return $0 % 5 != 0})
        .sink(receiveValue: { print($0) })
        .store(in: &subscriptions)
}
```
```bash
=== 範例: dropFirst ===
9
10
```

### [drop(while:)](https://juejin.cn/post/7017853525271150599)
- 有條件的忽略掉數值
```swift
example(of: "drop(untilOutputFrom:)") {
    
    let isReady = PassthroughSubject<Void, Never>()
    let taps = PassthroughSubject<Int, Never>()
    
    taps.drop(untilOutputFrom: isReady)         /// 直到isReady變數發出值之後才動作
        .sink(receiveValue: { print($0) })
        .store(in: &subscriptions)
    
    (1...5).forEach { n in
        taps.send(n)                            /// 在isReady發出值之前都是沒有用的
        if n == 3 { isReady.send() }            /// isReady發出值
    }
}
```
```bash
=== 範例: drop(untilOutputFrom:) ===
4
5
```

### [prefix(while:)](https://juejin.cn/post/7017853525271150599)
- 跟drop(while:)相反的功能，只取前面幾組，後面的不重要
```swift
example(of: "prefix(while:)") {
    
    let numbers = (1...10).publisher
    
    numbers
        .prefix(while: { $0 < 3 })
        .sink(
            receiveCompletion: { print("完成: \($0)") },
            receiveValue: { print($0) }
        )
        .store(in: &subscriptions)
}
```
```bash
=== 範例: prefix(while:) ===
1
2
完成: finished
```

### [prefix(while:)](https://juejin.cn/post/7017853525271150599)
- 跟drop(while:)相反的功能，只取前面幾組，後面的不重要
```swift
example(of: "prefix(while:)") {
    
    let numbers = (1...10).publisher
    
    numbers
        .prefix(while: { $0 < 3 })
        .sink(
            receiveCompletion: { print("完成: \($0)") },
            receiveValue: { print($0) }
        )
        .store(in: &subscriptions)
}
```
```bash
=== 範例: prefix(while:) ===
1
2
完成: finished
```

### [prefix(untilOutputFrom:)](https://juejin.cn/post/7017853525271150599)
- 跟drop(untilOutputFrom:)相反的功能，只取前面幾組，後面的不重要
```swift
example(of: "prefix(untilOutputFrom:)") {
    
    let isReady = PassthroughSubject<Void, Never>()
    let taps = PassthroughSubject<Int, Never>()
    
    taps
        .prefix(untilOutputFrom: isReady)                   /// 直到isReady變數發出值之後不停止
        .sink(
            receiveCompletion: { print("完成: \($0)") },
            receiveValue: { print($0) }
        )
        .store(in: &subscriptions)
    
    (1...5).forEach { n in
        taps.send(n)                                        /// 在isReady發出值之前一直是有效的
        if n == 2 { isReady.send() }                        /// isReady發出值
    }
}
```
```bash
=== 範例: prefix(untilOutputFrom:) ===
1
2
完成: finished
```

## Lesson.04 - 結合用的Operator
### [prepend(Output...)](https://juejin.cn/post/7018447582229692452)
- 在原本的publisher之前加入數值，可以應用在一些一定要出現的介紹詞之上…
```swift
example(of: "prepend(Output...)") {
    
    let publisher = ["新會員", "William"].publisher
    
    publisher
        .prepend("歡迎來到『人生40才開始』", "別忘了繳入會費喲")   // 再在前面加上 ["歡迎來到『人生40才開始』", "別忘了繳入會費喲"]
        .prepend("嗨!!!", "您好")                            // 先在前面加上 ["嗨!!!", "您好"]  => ["嗨!!!", "您好", "歡迎來到『人生40才開始』", "別忘了繳入會費喲"]
        .sink(receiveValue: { print($0) })
        .store(in: &subscriptions)
}
```
```bash
=== 範例: prepend(Output...) ===
嗨!!!
您好
歡迎來到『人生40才開始』
別忘了繳入會費喲
新會員
William
```

### [prepend(Sequence)]()
- 遵循[Sequence Protocol](https://developer.apple.com/documentation/swift/sequence)的都可以使用
- 也就是有順序關係的，像：[Array](https://developer.apple.com/documentation/swift/array) / [Set](https://developer.apple.com/documentation/swift/set) / [Stride](https://developer.apple.com/documentation/swift/stride(from:to:by:&#41;)
```swift
example(of: "prepend(Sequence)") {
    
    let publisher = [5, 6, 7].publisher
    let array = [3, 4]                              // Array也可以
    let set = Set(1...2)                            // Set也可以
    let stride = stride(from: 6, to: 11, by: 2)     // Stride也可以
    
    publisher
        .prepend(array)
        .prepend(set)
        .prepend(stride)
        .sink(receiveValue: { print($0) })
        .store(in: &subscriptions)
}
```
```bash
=== 範例: prepend(Sequence) ===
6
8
10
1
2
3
4
5
6
7
```

### [prepend(Publisher)](https://developer.apple.com/documentation/combine/publisher/prepend(_:%#41;-v9sb)
- publisher當參數也可以
```swift
example(of: "prepend(Publisher)") {
    
    let publisher1 = [3, 4].publisher
    let publisher2 = [1, 2].publisher
    
    publisher1
        .prepend(publisher2)
        .sink(receiveValue: { print($0) })
        .store(in: &subscriptions)
}
```
```bash
=== 範例: prepend(Publisher) ===
1
2
3
4
```
- 這樣也行
```swift
example(of: "prepend(Publisher) #2") {
    
    let publisher1 = [3, 4].publisher
    let publisher2 = PassthroughSubject<Int, Never>()
    
    publisher1
        .prepend(publisher2)
        .sink(receiveValue: { print($0) })
        .store(in: &subscriptions)
    
    publisher2.send(1)
    publisher2.send(2)
    publisher2.send(completion: .finished)
}
```
```bash
=== 範例: prepend(Publisher) #2 ===
1
2
3
4
```

### [append(Output...)](https://juejin.cn/post/7018447582229692452)
- append正好跟prepend相反，它是加在後面的功能…
```swift
example(of: "append(Output...)") {

    let publisher = ["您好", "我是William"].publisher

    publisher
        .append("-演出人員名單-", "-配樂清單-")
        .append("~終~")
        .sink(receiveValue: { print($0) })
        .store(in: &subscriptions)
}
```
```bash
=== 範例: append(Output...) ===
您好
我是William
-演出人員名單-
-配樂清單-
~終~
```

- 這樣也可以
```swift
example(of: "append(Output...) #2") {
    
    let publisher = PassthroughSubject<Int, Never>()
    
    publisher
        .append(3, 4)
        .append(5)
        .sink(receiveValue: { print($0) })
        .store(in: &subscriptions)
    
    publisher.send(1)
    publisher.send(2)
    publisher.send(completion: .finished)
}
```
```bash
=== 範例: append(Output...) #2 ===
1
2
3
4
5
```

### [append(Sequence)](https://juejin.cn/post/7018447582229692452)
- 跟append(Sequence)相反，就不多做介紹了
```swift
example(of: "append(Sequence)") {
    
    let publisher = [1, 2, 3].publisher
    
    publisher
        .append([4, 5])
        .append(Set([6, 7]))
        .append(stride(from: 8, to: 11, by: 2))
        .sink(receiveValue: { print($0) })
        .store(in: &subscriptions)
}
```
```bash
=== 範例: append(Sequence) ===
1
2
3
4
5
7
6
8
10
```

### [append(Publisher)](https://juejin.cn/post/7018447582229692452)
- 跟append(Publisher)相反，也不多做介紹了
```swift
example(of: "append(Publisher)") {
    
    let publisher1 = [1, 2].publisher
    let publisher2 = [3, 4].publisher
    
    publisher1
        .append(publisher2)
        .sink(receiveValue: { print($0) })
        .store(in: &subscriptions)
}
```
```bash
=== 範例: append(Publisher) ===
1
2
3
4
```

### [switchToLatest](https://zhuanlan.zhihu.com/p/345054834)
- 切換到最後一個Publisher
- 在應用上的話，就像及時搜尋單字框，會一直送request，但是我們只需要最後一次的單字就好，中間的不要動作，減少多餘的request發送
```swift
example(of: "switchToLatest") {
    
    let publisher1 = PassthroughSubject<Int, Never>()
    let publisher2 = PassthroughSubject<Int, Never>()
    let publisher3 = PassthroughSubject<Int, Never>()
    let publishers = PassthroughSubject<PassthroughSubject<Int, Never>, Never>()
    
    publishers
        .switchToLatest()
        .sink(
            receiveCompletion: { _ in print("Completed!") },
            receiveValue: { print($0) }
        )
        .store(in: &subscriptions)
    
    publishers.send(publisher1)
    publisher1.send(1)
    publisher1.send(2)
    
    publishers.send(publisher2)
    publisher1.send(3)
    publisher2.send(4)
    publisher2.send(5)
    
    publishers.send(publisher3)
    publisher2.send(6)
    publisher3.send(7)
    publisher3.send(8)
    publisher3.send(9)
    
    publisher3.send(completion: .finished)
    publishers.send(completion: .finished)
}
```
```bash
=== 範例: switchToLatest ===
publisher1 - 1
publisher1 - 2
publisher2 - 4
publisher2 - 5
publisher3 - 7
publisher3 - 8
publisher3 - 9
Completed!
```
- 實際應用
![](image/SwitchToLatest.png)
```swift
example(of: "switchToLatest - Network Request") {
    
    let url = URL(string: "https://picsum.photos/128")!
    let taps = PassthroughSubject<Void, Never>()
    
    taps.map { _ in getImage() }
        .switchToLatest()
        .sink(receiveValue: { _ in })
        .store(in: &subscriptions)
    
    taps.send()                                                                            // 下載圖片動作
    DispatchQueue.main.asyncAfter(deadline: .now() + 3.0) { print(Date()); taps.send() }
    DispatchQueue.main.asyncAfter(deadline: .now() + 3.1) { print(Date()); taps.send() }
    DispatchQueue.main.asyncAfter(deadline: .now() + 3.2) { print(Date()); taps.send() }
    DispatchQueue.main.asyncAfter(deadline: .now() + 3.3) { print(Date()); taps.send() }
    DispatchQueue.main.asyncAfter(deadline: .now() + 3.4) { print(Date()); taps.send() }   // 只會留這一個下載圖片動作

    func getImage() -> AnyPublisher<UIImage?, Never> {
        
        URLSession.shared
            .dataTaskPublisher(for: url)
            .map { data, _ in UIImage(data: data) }
            .print("[image]")
            .replaceError(with: nil)
            .eraseToAnyPublisher()
    }
}
```
```bash
=== 範例: switchToLatest - Network Request ===
[image]: receive subscription: (DataTaskPublisher)
[image]: request unlimited
[image]: receive value: (Optional(<UIImage:0x600001eec480 anonymous {128, 128} renderingMode=automatic(original)>))
[image]: receive finished
2023-05-30 07:02:02 +0000
[image]: receive subscription: (DataTaskPublisher)
[image]: request unlimited
2023-05-30 07:02:02 +0000
[image]: receive cancel
[image]: receive subscription: (DataTaskPublisher)
[image]: request unlimited
2023-05-30 07:02:02 +0000
[image]: receive cancel
[image]: receive subscription: (DataTaskPublisher)
[image]: request unlimited
2023-05-30 07:02:02 +0000
[image]: receive cancel
[image]: receive subscription: (DataTaskPublisher)
[image]: request unlimited
2023-05-30 07:02:02 +0000
[image]: receive cancel
[image]: receive subscription: (DataTaskPublisher)
[image]: request unlimited
[image]: receive value: (Optional(<UIImage:0x600001eec5a0 anonymous {128, 128} renderingMode=automatic(original)>))
[image]: receive finished
```

### [merge(with:)](https://ithelp.ithome.com.tw/articles/10221533)
- 把Publisher們合併在一起
```swift
example(of: "merge(with:)") {
    
    let publisher1 = PassthroughSubject<Int, Never>()
    let publisher2 = PassthroughSubject<Int, Never>()
    
    publisher1
        .merge(with: publisher2)
        .sink(
            receiveCompletion: { _ in print("Completed") },
            receiveValue: { print($0) }
        )
        .store(in: &subscriptions)
    
    publisher1.send(1)
    publisher1.send(2)
    
    publisher2.send(3)
    
    publisher1.send(4)
    
    publisher2.send(5)
    
    publisher1.send(completion: .finished)
    publisher2.send(completion: .finished)
}
```
```bash
=== 範例: merge(with:) ===
1
2
3
4
5
Completed
```

### [combineLatest()](https://ithelp.ithome.com.tw/articles/10221533)
- 合併最後的一個publisher
```swift
example(of: "combineLatest") {
    
    let publisher1 = PassthroughSubject<Int, Never>()
    let publisher2 = PassthroughSubject<String, Never>()
    
    publisher1
        .combineLatest(publisher2)
        .sink(
            receiveCompletion: { _ in print("Completed") },
            receiveValue: { print("(\($0), \($1))") }
        )
        .store(in: &subscriptions)
    
    publisher1.send(1)
    publisher2.send("a")

    publisher1.send(2)
    publisher2.send("b")
    
    publisher1.send(3)
    publisher2.send("c")
    
    publisher1.send(completion: .finished)
    publisher2.send(completion: .finished)
}
```
```bash
=== 範例: combineLatest ===
(1, a)
(2, a)
(2, b)
(3, b)
(3, c)
Completed
```

### [zip()](https://augmentedcode.io/2022/10/03/combine-publishers-merge-zip-and-combinelatest-on-ios/)
- 這個跟combineLatest不太一樣，它是一對一合併
```swift
example(of: "zip") {
    
    let publisher1 = PassthroughSubject<Int, Never>()
    let publisher2 = PassthroughSubject<String, Never>()
    
    publisher1
        .zip(publisher2)
        .sink(
            receiveCompletion: { _ in print("Completed") },
            receiveValue: { print("(\($0) ,\($1))") }
        )
        .store(in: &subscriptions)
    
    publisher1.send(1)
    publisher1.send(2)
    publisher2.send("a")
    publisher2.send("b")
    publisher1.send(3)
    publisher2.send("c")
    publisher2.send("d")
    publisher1.send(4)
    publisher2.send("e")
    
    publisher1.send(completion: .finished)
    publisher2.send(completion: .finished)
}
```
```bash
=== 範例: zip ===
(1 ,a)
(2 ,b)
(3 ,c)
(4 ,d)
Completed
```