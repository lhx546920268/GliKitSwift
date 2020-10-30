//
//  JSONSerialization+Utils.swift
//  GliKitSwift
//
//  Created by 罗海雄 on 2020/3/27.
//  Copyright © 2020 luohaixiong. All rights reserved.
//

import Foundation

public typealias JSONDictionary = Dictionary<String, Any>
public typealias JSONArray = Array<Any>

public extension JSONSerialization{
    
    /**
     便利的Json解析 避免了 data = nil时，抛出异常
     
     *@param data Json数据
     *@return Any
     */
    class func gkObject(_ data: Data?) -> Any?{
        
        if data == nil {
            return nil
        }
        
        do {
            let obj = try JSONSerialization.jsonObject(with: data!, options: .mutableContainers)
            return obj
        } catch {
            
            #if DEBUG
            if let str = String(data: data!, encoding: .utf8) {
                print(str)
            }
            print(error)
            #endif
            
            return nil
        }
    }
    
    /**
     便利的Json解析
     
     *@param string Json数据
     *@return JSONDictionary
     */
    class func gkDictionary(_ string: String?) -> JSONDictionary?{
        
        return gkDictionary(string?.data(using: .utf8))
    }
    
    /**
     便利的Json解析 避免了 data = nil时，抛出异常
     
     *@param data Json数据
     *@return JSONDictionary
     */
    class func gkDictionary(_ data: Data?) -> JSONDictionary?{
        
        if let dic = gkObject(data) as? JSONDictionary {
            return dic
        }
        
        return nil
    }
    
    /**
     便利的Json解析
     
     *@param string Json数据
     *@return JSONArray
     */
    class func gkArray(_ string: String?) -> JSONArray?{
        
        return gkArray(string?.data(using: .utf8))
    }
    
    /**
     便利的Json解析 避免了 data = nil时，抛出异常
     
     *@param data Json数据
     *@return JSONArray
     */
    class func gkArray(_ data: Data?) -> JSONArray?{
        
        if let array = gkObject(data) as? JSONArray {
            return array
        }
        
        return nil
    }
    
    /**
     把Json 对象转换成 json字符串
     
     *@param object 要转换成json的对象
     *@return json字符串
     */
    class func gkString(_ obj: Any?) -> String?{
        
        if let data = gkData(obj) {
            return String(data: data, encoding: .utf8)
        }
        
        return nil
    }
    
    /**
     把 json 对象转换成 json二进制
     
     *@param object 要转换成json的对象
     *@return json字符串
     */
    class func gkData(_ obj: Any?) -> Data?{
        
        if obj != nil {
            if JSONSerialization.isValidJSONObject(obj!) {
                
                do {
                    let data = try JSONSerialization.data(withJSONObject: obj!, options: WritingOptions(rawValue: 0))
                    return data
                } catch {
                    debugPrint("生成json 出错", error)
                    return nil
                }
            }
        }
        
        return nil
    }
}
