//
//  DispatchQueue+Utils.swift
//  GliKitSwift
//
//  Created by 罗海雄 on 2020/3/24.
//  Copyright © 2020 luohaixiong. All rights reserved.
//

import Foundation

public extension DispatchQueue{
    
    private static var onceTokens = Set<String>()
    
    ///同步锁
    class func synchronized(token: Any, block: VoidCallback) {
        
        objc_sync_enter(token)
        defer{
            objc_sync_exit(token)
        }
        block()
    }
    
    ///只执行一次 类似 objc的
    class func once(token: String, block: VoidCallback) {
        
        synchronized(token: self) {
            guard !onceTokens.contains(token) else {
                return
            }
            onceTokens.insert(token)
            block()
        }
    }
}

extension DispatchTime: ExpressibleByIntegerLiteral {
    public init(integerLiteral value: Int) {
        self = DispatchTime.now() + .seconds(value)
    }
}

extension DispatchTime: ExpressibleByFloatLiteral {
    public init(floatLiteral value: Double) {
        self = DispatchTime.now() + .milliseconds(Int(value * 1000))
    }
}

