//
//  NSObject+Utils.swift
//  GliKitSwift
//
//  Created by 罗海雄 on 2020/1/22.
//  Copyright © 2020 luohaixiong. All rights reserved.
//

import Foundation

///可复制协议
public protocol Copyable{
    
    func copy() -> Self
}

extension Copyable where Self: NSObject{
    
    func copy() -> Self{
        
        let cls = self.classForCoder as? Self.Type
        let obj = cls!.init()
        copy(cls, to: obj)
        
        return obj
    }
    
    private func copy(_ cls: AnyClass?, to object: Self){
        
        if cls == NSObject.self {
            return
        }
        
        //获取当前类的所有属性，该方法无法获取父类或者子类的属性
        var count: UInt32 = 0
        let iVars = class_copyIvarList(cls, &count)
        
        for i in 0 ..< Int(count) {
            
            let iVar = iVars![i]
            
            if let iVarName = ivar_getName(iVar), let name = String(cString: iVarName, encoding: .utf8) {
            
                object.setValue(self.value(forKey: name), forKey: name)
            }
            
        }
        
        if iVars != nil {
            free(iVars!)
        }
        copy(cls?.superclass(), to: object)
    }
}

public extension NSObject {
    
    ///获取 class name
    class var gkNameOfClass: String{
        
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