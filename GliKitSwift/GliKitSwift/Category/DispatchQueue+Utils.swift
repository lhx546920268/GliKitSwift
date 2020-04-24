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
    
    ///只执行一次 类似 objc的
    class func once(token: String, block: () -> Void){
        
        objc_sync_enter(self)
        defer{
            objc_sync_exit(self)
        }
        guard !onceTokens.contains(token) else {
            return
        }
        onceTokens.append(token)
        block()
    }
}
