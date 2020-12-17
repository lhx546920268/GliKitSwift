//
//  NSObject+Utils.swift
//  GliKitSwift
//
//  Created by 罗海雄 on 2020/1/22.
//  Copyright © 2020 luohaixiong. All rights reserved.
//

import Foundation

///可复制协议 在属性前面加上@objc，或者在类的上面加上@objcMembers，否则会抛出异常 不支持结构体、枚举、可选的基本数据类型
public protocol Copyable{
    
    func gkCopy() -> Self
}

public extension Copyable where Self: NSObject{
    
    func gkCopy() -> Self{
        
        let cls = self.classForCoder as! Self.Type
        let obj = cls.init()
        gkCopy(cls, to: obj)
        
        return obj
    }
    
    private func gkCopy(_ cls: AnyClass, to object: Self){
        
        if cls == NSObject.self {
            return
        }
        
        //获取当前类的所有属性，该方法无法获取父类或者子类的属性
        var count: UInt32 = 0
        if let properties = class_copyPropertyList(cls, &count) {
            for i in 0 ..< Int(count) {
                let property = properties[i]
                guard let name = String(cString: property_getName(property), encoding: .utf8) else {
                    continue
                }
                guard let attributes = property_getAttributes(property), let attr = String(cString: attributes, encoding: .utf8) else {
                    continue
                }
                //判断是否是只读属性
                let attrs = attr.components(separatedBy: ",")
                if !attrs.contains("R") {
                    object.setValue(value(forKey: name), forKey: name)
                }
            }
            free(properties)
        }
        if let superClass = cls.superclass() {
            gkCopy(superClass, to: object)
        }
    }
}

/// 默认的归档实现 不支持结构体、枚举、可选的基本数据类型
/// 每个子类必须实现
/// public override class var supportsSecureCoding: Bool {true}
@objcMembers
open class DefaultSecureCoding: NSObject, NSSecureCoding {
    
    public class var supportsSecureCoding: Bool {
        true
    }
    
    public func encode(with coder: NSCoder) {
        gkEncode(with: coder, cls: classForCoder)
    }
    
    private func gkEncode(with coder: NSCoder, cls: AnyClass) {
        if cls == NSObject.self {
            return
        }
        
        //获取当前类的所有属性，该方法无法获取父类或者子类的属性
        var count: UInt32 = 0
         if let properties = class_copyPropertyList(cls, &count) {
             for i in 0 ..< Int(count) {
                 let property = properties[i]
                 guard let name = String(cString: property_getName(property), encoding: .utf8) else {
                     continue
                 }
                 guard let attributes = property_getAttributes(property), let attr = String(cString: attributes, encoding: .utf8) else {
                     continue
                 }
                 //判断是否是只读属性
                 let attrs = attr.components(separatedBy: ",")
                 if !attrs.contains("R") {
                    coder.encode(value(forKey: name), forKey: name)
                 }
             }
             free(properties)
         }
         if let superClass = cls.superclass() {
            gkEncode(with: coder, cls: superClass)
         }
    }
    
    public override init() {
        super.init()
    }
    
    public required init?(coder: NSCoder) {
        super.init()
        gkInit(with: coder, cls: classForCoder)
    }
    
    private func gkInit(with decoder: NSCoder, cls: AnyClass) {
        if cls == NSObject.self {
            return
        }
        
        //获取当前类的所有属性，该方法无法获取父类或者子类的属性
        var count: UInt32 = 0
         if let properties = class_copyPropertyList(cls, &count) {
             for i in 0 ..< Int(count) {
                 let property = properties[i]
                 guard let name = String(cString: property_getName(property), encoding: .utf8) else {
                     continue
                 }
                 guard let attributes = property_getAttributes(property), let attr = String(cString: attributes, encoding: .utf8) else {
                     continue
                 }
                 //判断是否是只读属性
                 let attrs = attr.components(separatedBy: ",")
                if attrs.count > 0 && !attrs.contains("R") {
                    
                    var type = attrs.first!
                    var value: Any? = nil
                    
                    //判断是否是对象属性
                    if type.contains("@\"") {
                        type = type.replacingOccurrences(of: "T@\"", with: "")
                        type = type.replacingOccurrences(of: "\"", with: "")
                        
                        if let clazz = NSClassFromString(type) {
                            value = decoder.decodeObject(of: [clazz], forKey: name)
                        }
                    } else {
                        value = decoder.decodeObject(forKey: name)
                    }
                    setValue(value, forKey: name)
                 }
             }
             free(properties)
         }
         if let superClass = cls.superclass() {
            gkInit(with: decoder, cls: superClass)
         }
    }
}

public extension NSObject {
    
    ///获取 class name
    class var gkNameOfClass: String{
        String(describing: self.classForCoder())
    }
    
    var gkNameOfClass: String{
        String(describing: self.classForCoder)
    }
}
