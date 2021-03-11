//
//  Swizzlling.swift
//  GliKitSwift
//
//  Created by 罗海雄 on 2020/3/24.
//  Copyright © 2020 luohaixiong. All rights reserved.
//

import Foundation

///黑魔法 方法交互 同一个类的
func swizzling(selector1: Selector, selector2: Selector,  cls1: AnyClass) {
    
    swizzling(selector1: selector1, cls1: cls1, selector2: selector2, cls2: cls1)
}

///黑魔法 方法交互 替换实现
func swizzling(selector1: Selector, cls1: AnyClass, selector2: Selector, cls2: AnyClass) {
    
    guard let method1 = class_getInstanceMethod(cls1, selector1),
        let method2 = class_getInstanceMethod(cls2, selector2) else {
        if class_getInstanceMethod(cls1, selector1) == nil {
            print(selector1)
        }
        if class_getInstanceMethod(cls2, selector2) == nil {
            print(selector2)
        }
        return
    }
    
    method_exchangeImplementations(method1, method2)
}
