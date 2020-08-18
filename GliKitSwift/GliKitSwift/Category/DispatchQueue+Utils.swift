//
//  DispatchQueue+Utils.swift
//  GliKitSwift
//
//  Created by 罗海雄 on 2020/3/24.
//  Copyright © 2020 luohaixiong. All rights reserved.
//

import Foundation

public extension DispatchQueue{
    
    private static var onceTokens = [String]()
    
    ///同步锁
    class func synchronized(token: Any, block: VoidClosure) {
        
        objc_sync_enter(token)
        defer{
            objc_sync_exit(token)
        }
        block()
    }
    
    ///只执行一次 类似 objc的
    class func once(token: String, block: VoidClosure) {
        
        synchronized(token: self) {
            guard !onceTokens.contains(token) else {
                return
            }
            onceTokens.append(token)
            block()
        }
    }
    
    ///如果已经是主线程就不再加入主线程队列
    func safeAsync(_ block: @escaping VoidClosure) {
        if self === DispatchQueue.main && Thread.isMainThread {
            block()
        } else {
            async {
                block()
            }
        }
    }
}
