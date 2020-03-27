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
        return
    }
    
    //添加失败 说明 方法2已存在，直接交换实现
    if(class_addMethod(cls1, selector2, method_getImplementation(method2), method_getTypeEncoding(method2))){
        
        //添加成功 替换方法1的实现
        class_replaceMethod(cls1, selector1, method_getImplementation(method2), method_getTypeEncoding(method2))
    }else{
        method_exchangeImplementations(method1, method2)
    }
}
