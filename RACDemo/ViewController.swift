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
        
        //map
        let eventInteger: Event<Int, NSError> = .value(100)
        let mapEvent: Event<String, NSError> = eventInteger.map { (value) -> String in
            return "You get a grade: \(value)"
        }
        print(mapEvent.value!)
        
        //mapError
        let errorEvent: Event<Int, McyError> = .failed(McyError())
        print(errorEvent.error!.display())
        
        let errorMapEvent: Event<Int, McyError1> = errorEvent.mapError { (error) -> McyError1 in
            return McyError1(message: error.display())
        }
        print(errorMapEvent.error!.display())
        
        //observer
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
        
        
        //Bag
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
    }
}

