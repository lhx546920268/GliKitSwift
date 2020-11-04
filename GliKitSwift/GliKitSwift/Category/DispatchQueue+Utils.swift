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
    static func synchronized(token: Any, block: VoidCallback) {
        
        objc_sync_enter(token)
        defer{
            objc_sync_exit(token)
        }
        block()
    }
    
    ///只执行一次 类似 objc的
    static func once(token: String, block: VoidCallback) {
        
        synchronized(token: self) {
            guard !onceTokens.contains(token) else {
                return
            }
            onceTokens.insert(token)
            block()
        }
    }
    
    ///当前队列名称
    static var currentQueueLabel: String? {
        String(cString: __dispatch_queue_get_label(nil), encoding: .utf8)
    }
    
    ///延迟执行
    func asyncAfter(seconds: Double, block: @escaping VoidCallback) {
        asyncAfter(deadline: DispatchTime(floatLiteral: seconds), execute: block)
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

