//
//  Array+Utils.swift
//  GliKitSwift
//
//  Created by 罗海雄 on 2020/1/20.
//  Copyright © 2020 luohaixiong. All rights reserved.
//

import Foundation

public extension Array where Array.Element: Equatable {
    
    ///删除元素
    @discardableResult
    mutating func remove(_ obj: Element) -> Int? {
        
        if let index = firstIndex(of: obj) {
            remove(at: index)
            return index
        }
        return nil
    }
}

public extension Dictionary{
    
    ///去空获取对象 并且如果对象是数字将会转化成字符串
    func get(_ key: Key) -> String?{
        
        let value = self[key]
        if let intValue = value as? Int {
            return String(intValue)
        }
        
        if let floatValue = value as? Float {
            return String(floatValue)
        }
        
        if let doubleValue = value as? Double {
            return String(doubleValue)
        }
        
        if let boolValue = value as? Bool {
            return String(boolValue)
        }
        
        if let stringValue = value as? String {
            return stringValue
        }
        
        return nil
    }
    
    ///去空获取对象 并且如果对象是数字将会转化成字符串，如果 == nil 返回 ""
    func get(_ key: Key) -> String{
        
        var value: String? = get(key)
        if value == nil {
            value = ""
        }
        return value!
    }
    
    ///获取整数
    func get(_ key: Key) -> Int{
        
        let value = self[key]
        if let intValue = value as? Int {
            return intValue
        }
        
        if let floatValue = value as? Float {
            return Int(floatValue)
        }
        
        if let doubleValue = value as? Double {
            return Int(doubleValue)
        }
        
        if let boolValue = value as? Bool {
            return boolValue ? 1 : 0
        }
        
        if let stringValue = value as? String {
            return Int(stringValue) ?? 0
        }
        
        return 0
    }
    
    ///获取小数点
    func get(_ key: Key) -> Float{
        
        let value = self[key]
        if let intValue = value as? Int {
            return Float(intValue)
        }
        
        if let floatValue = value as? Float {
            return floatValue
        }
        
        if let doubleValue = value as? Double {
            return Float(doubleValue)
        }
        
        if let boolValue = value as? Bool {
            return boolValue ? 1.0 : 0
        }
        
        if let stringValue = value as? String {
            return Float(stringValue) ?? 0
        }
        
        return 0
    }
    
    ///获取小数点
    func get(_ key: Key) -> Double{
        
        let value = self[key]
        if let intValue = value as? Int {
            return Double(intValue)
        }
        
        if let floatValue = value as? Float {
            return Double(floatValue)
        }
        
        if let doubleValue = value as? Double {
            return doubleValue
        }
        
        if let boolValue = value as? Bool {
            return boolValue ? 1.0 : 0
        }
        
        if let stringValue = value as? String {
            return Double(stringValue) ?? 0
        }
        
        return 0
    }
    
    ///获取布尔
    func get(_ key: Key) -> Bool{
        
        let value = self[key]
        if let intValue = value as? Int {
            return intValue > 0 ? true : false
        }
        
        if let floatValue = value as? Float {
            return floatValue > 0 ? true : false
        }
        
        if let doubleValue = value as? Double {
            return doubleValue > 0 ? true : false
        }
        
        if let boolValue = value as? Bool {
            return boolValue
        }
        
        if let stringValue = value as? String {
            return Bool(stringValue) ?? false
        }
        
        return false
    }
    
    ///获取字典
    func get(_ key: Key) -> Dictionary?{
        
        if let value = self[key] as? Dictionary {
            return value
        }
        return nil
    }
    
    ///获取数组
    func get(_ key: Key) -> Array<Any>?{
        
        if let value = self[key] as? Array<Any> {
            return value
        }
        return nil
    }
}

public extension Set {
    
    ///删除多个元素
    mutating func remove(_ elements: Set<Element>){
        
        for element in elements {
            remove(element)
        }
    }
}
