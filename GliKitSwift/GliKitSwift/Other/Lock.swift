//
//  Lock.swift
//  GliKitSwift
//
//  Created by 罗海雄 on 2020/11/4.
//  Copyright © 2020 luohaixiong. All rights reserved.
//

import Foundation

///互斥锁
public class Lock: NSLocking {
    
    private let semaphore: DispatchSemaphore = DispatchSemaphore(value: 1)
    
    public func lock() {
        semaphore.wait()
    }
    
    public func unlock() {
        semaphore.signal()
    }
}
