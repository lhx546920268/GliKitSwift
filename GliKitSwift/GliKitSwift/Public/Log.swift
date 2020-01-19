//
//  Log.swift
//  GliKitSwift
//
//  Created by 罗海雄 on 2020/1/19.
//  Copyright © 2020 luohaixiong. All rights reserved.
//

import Foundation

///打印日志信息，release 不打印
func GKLog(_ log: String) {
    
    #if DEBUG
    print(log)
    #endif
}
