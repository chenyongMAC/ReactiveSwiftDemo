//
//  ViewController.swift
//  RACDemo
//
//  Created by ucmed on 2017/7/13.
//  Copyright © 2017年 mcy. All rights reserved.
//

import UIKit
import ReactiveSwift
import Result

class McyError: Error {
    func display() -> String {
        return "McyError: Error message."
    }
}

class McyError1: Error {
    var message: String
    init(message: String) {
        self.message = message
    }
    func display() -> String {
        return message + "\n" + "McyError2: Cool!"
    }
}

class ViewController: UIViewController {

    override func viewDidLoad() {
        super.viewDidLoad()
        
        //---------------------------------------------------------map
        let eventInteger: Event<Int, NSError> = .value(100)
        let mapEvent: Event<String, NSError> = eventInteger.map { (value) -> String in
            return "You get a grade: \(value)"
        }
        print(mapEvent.value!)
        
        
        //---------------------------------------------------------mapError
        let errorEvent: Event<Int, McyError> = .failed(McyError())
        print(errorEvent.error!.display())
        
        let errorMapEvent: Event<Int, McyError1> = errorEvent.mapError { (error) -> McyError1 in
            return McyError1(message: error.display())
        }
        print(errorMapEvent.error!.display())
        
        
        //---------------------------------------------------------observer
        let observer = Observer<String, NSError>(value: { (value) in
            print(value)
        }, failed: { (error) in
            print(error)
        }, completed: { 
            print("observer finished")
        }) { 
            print("observer failed")
        }
        
        observer.send(value: "hello world")
        observer.send(error: NSError(domain: "send error", code: 1111, userInfo: ["userInfo" : "value"]))
        observer.sendCompleted()
        observer.sendInterrupted()
        print("\n")
        
        
        
        //---------------------------------------------------------Bag
        var myBags = Bag<String>()
        var bagsTokens = ContiguousArray<RemovalToken>()
        
        for i in 0..<10 {
            let token = myBags.insert("\(i)")
            bagsTokens.append(token)
        }
        print("-----------------输出Token对象的Hash值")
        for i in bagsTokens.indices.reversed() {
            let identifier = ObjectIdentifier(bagsTokens[i])
            print(identifier.hashValue)
        }
        print("-----------------初始化后的myBags")
        dump(myBags)
        
        myBags.remove(using: bagsTokens[0])
        print("startIndex = \(myBags.startIndex)")
        print("endIndex = \(myBags.endIndex))")
        
        var myBagsIterator = myBags.makeIterator()
        while let element = myBagsIterator.next() {
            print(element)
        }
        
        
        //---------------------------------------------------------Signal
        //never
        let neverSignal = Signal<Int, NoError>.never
        let observer1 = Observer<Int, NoError>(value: { (value) in
            print("value not called")
        }, failed: { (error) in
            print("error not called")
        }, completed: {
            print("completed not called")
        }) {
            print("interrupted not called")
        }
        neverSignal.observe(observer1)
        
        //empty
        let emptySignal = Signal<Int, NoError>.empty
        let observer2 = Observer<Int, NoError>(value: { (value) in
            print("value not called")
        }, failed: { (error) in
            print("error not called")
        }, completed: {
            print("completed not called")
        }) {
            print("interrupted called")
        }
        emptySignal.observe(observer2)
        
        
        //---------------------------------------------------------pipe
        let (signal, sendMessage) = Signal<Int, NoError>.pipe()
        let subscriber1 = Observer<Int, NoError>(value: {
            print("Subscrober 1 received \($0)")
        })
        let actionDisposable1 = signal.observe(subscriber1)
        sendMessage.send(value: 10)
        print(actionDisposable1?.isDisposed as Any)
        actionDisposable1?.dispose()
        print(actionDisposable1?.isDisposed as Any)
        
        
        //---------------------------------------------------------SignalProtocol
        let (signalX, _) = Signal<Int, NSError>.pipe()
        signalX.observe { (event) in
            if case let Event.value(value) = event {
                print("value : \(value)")
            }
            if case let Event.failed(error) = event {
                print("error : \(error)")
            }
            if case Event.completed = event {
                print("completed")
            }
            if case Event.interrupted = event {
                print("interrupted")
            }
        }
        
        
        //---------------------------------------------------------高阶函数
        let (signalY, observerY) = Signal<Int, NSError>.pipe()
        //通过Event的map方法将event中的value类型改变，然后重新生成observer，再绑定到新的signal上
        let mappedSignal: Signal<String, NSError> = signalY.map { (value) -> String in
            return "map rule: \(value * 3)"
        }
        let subscriberY = Observer<String, NSError>(value: {
            print("subscriber received : \($0)")
        })
        mappedSignal.observe(subscriberY)
        observerY.send(value: 10)
        //链式写法
        signalY.map { (value) -> String in
            return "map rule: \(value * 5)"
            }.observe(Observer<String, NSError>(value: {
                print("subscriber received : \($0)")
            }))
        observerY.send(value: 10)
        
    }
}














