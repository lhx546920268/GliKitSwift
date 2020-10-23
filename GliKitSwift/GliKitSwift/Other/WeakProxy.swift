//
//  WeakProxy.swift
//  GliKitSwift
//
//  Created by 罗海雄 on 2020/10/23.
//  Copyright © 2020 luohaixiong. All rights reserved.
//

import Foundation

///弱引用代理，主要用于 会造成循环引用的地方，比如 计时器的 target
class WeakProxy: NSObject {
    
    public private(set) weak var target: NSObject?
    
    init(target: NSObject?) {
        self.target = target
    }
    
    override func forwardingTarget(for aSelector: Selector!) -> Any? {
        return target
    }
    
    deinit {
        print("WeakProxy")
    }
}

