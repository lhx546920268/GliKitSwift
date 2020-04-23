//
//  WeakObjectContainer.swift
//  GliKitSwift
//
//  Created by 罗海雄 on 2020/3/24.
//  Copyright © 2020 luohaixiong. All rights reserved.
//

import Foundation

///主要用于类目中设置 weak的属性， 因为 objc_setAssociatedObject 是没有weak的
open class WeakObjectContainer: NSObject {
    
    ///需要weak引用的对象
    public weak var weakObject: AnyObject?
    
    override init() {
        super.init()
    }

    init(weakObject: AnyObject) {
        super.init()
        self.weakObject = weakObject
    }
}
