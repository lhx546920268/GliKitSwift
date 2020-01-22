//
//  NSObject+Utils.swift
//  GliKitSwift
//
//  Created by 罗海雄 on 2020/1/22.
//  Copyright © 2020 luohaixiong. All rights reserved.
//

import Foundation

public extension NSObject {
    
    ///获取 class name
    static var gkNameOfClass: String{
        get{
            NSStringFromClass(self.classForCoder())
        }
    }
    
    var gkNameOfClass: String{
        get{
            NSStringFromClass(self.classForCoder)
        }
    }
}
