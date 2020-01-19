//
//  ThreadUtils.swift
//  GliKitSwift
//
//  Created by 罗海雄 on 2020/1/19.
//  Copyright © 2020 luohaixiong. All rights reserved.
//

import Foundation

///在主线程执行
func dispatchAsyncMainSafe(_ block: @escaping () -> Void){
    
    if Thread.current.isMainThread {
        block()
    } else {
        DispatchQueue.main.async(execute: block)
    }
}
