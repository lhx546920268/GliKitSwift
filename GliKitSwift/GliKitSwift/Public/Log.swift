//
//  Log.swift
//  GliKitSwift
//
//  Created by 罗海雄 on 2020/1/19.
//  Copyright © 2020 luohaixiong. All rights reserved.
//

import Foundation

///打印日志信息，release 不打印
public func print(_ items: Any..., separator: String = " ", terminator: String = "\n") {
    
    #if DEBUG
    Swift.print(items, separator, terminator)
    #endif
}
