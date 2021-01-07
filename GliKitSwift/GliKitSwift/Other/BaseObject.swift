//
//  BaseObject.swift
//  GliKitSwift
//
//  Created by 罗海雄 on 2020/11/24.
//  Copyright © 2020 luohaixiong. All rights reserved.
//

import Foundation

open class BaseObject: NSObject {
    
    ///必须的，否则 cls.init() 会报错
    required override public init() {
        
    }
    
    ///kvo 帮助类
    public private(set) lazy var kvoHelper: KVOHelper = {
       return KVOHelper(owner: self)
    }()
    
    /**
     通过字典创建
     
     @param dic 数据
     @return 一个实例
     */
    public class func modelFrom(_ dic: JSONDictionary) -> Self {
        let cls = self as BaseObject.Type
        let obj = cls.init()
        obj.setDictionary(dic)
        
        return obj as! Self
    }

    /**
     通过数组字典创建一个数组

     @param array 包含字典的数组
     @return 如果array 大于0 返回包含对应子类的数组，否则返回nil
     */
    public class func modelsFrom<T: BaseObject>(_ array: [JSONDictionary]?) -> [T]? {
        if let array = array, array.count > 0 {
            var models: [T] = []
            for dic in array {
                models.append(modelFrom(dic) as! T)
            }
            return models
        }
        return nil
    }
    
    /**
     通过数组字典创建一个数组

     @param array 包含字典的数组
      @param maxCount 最大数量
     @return 如果array 大于0 返回包含对应子类的数组，否则返回nil
     */
    public class func modelsFrom<T: BaseObject>(_ array: [JSONDictionary]?, max: Int) -> [T]? {
        if let array = array, array.count > 0 {
            var models: [T] = []
            for dic in array {
                models.append(modelFrom(dic) as! T)
                if models.count >= max {
                    break
                }
            }
            return models
        }
        return nil
    }

    /**
     子类要重写这个

     @param dic 包含数据的字典
     */
    open func setDictionary(_ dic: JSONDictionary) {

    }
}
