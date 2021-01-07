//
//  KVOHelper.swift
//  GliKitSwift
//
//  Created by 罗海雄 on 2020/11/24.
//  Copyright © 2020 luohaixiong. All rights reserved.
//

import Foundation

private var KVOContext = "com.glikit.GKKVOContext"

/// 回调
/// @param keyPath  属性，和addObserver 中的一致
/// @param newValue 新值 值类型要拆箱
/// @param oldValue 旧值 值类型要拆箱
public typealias KVOCallback = (_ keyPath: String, _ newValue: Any?, _ oldValue: Any?) -> Void

///回调信息
fileprivate class KVOCallbackModel {
    
    ///回调
    var callback: KVOCallback
    
    ///旧值
    private var _oldValue: Any?
    var oldValue: Any? {
        set{
            if !hasOldValue {
                hasOldValue = true
                _oldValue = newValue
            }
        }
        get{
            _oldValue
        }
    }
    
    ///是否有旧值了
    fileprivate private(set) var hasOldValue: Bool = false
    
    ///新值
    var newValue: Any?
    
    init(callback: @escaping KVOCallback) {
        self.callback = callback
    }
    
    ///重置
    func reset() {
        hasOldValue = false
        oldValue = nil
        newValue = nil
    }
}

///kvo帮助类 要监听的属性必须标记为 @objc dynamic
open class KVOHelper: NSObject {
    
    ///是否监听只读属性
    public var shouldObserveReadonly: Bool = false
    
    ///当前监听的属性
    private lazy var observingKeyPaths: Set<String> = {
        return Set<String>()
    }()
    
    ///回调
    private lazy var callbacks: NSMutableDictionary = {
        return NSMutableDictionary()
    }()
    
    ///被观察者
    private weak var owner: NSObject?
    
    init(owner: NSObject) {
        self.owner = owner
    }
    
    /// 添加一个观察者，必须通过 .语法 设置新值才会触发回调
    /// @param observer 观察者，将使用hash作为 key来保存
    /// @param callback 回调
    /// @param keyPath 要监听的属性，如果为空，则监听所有属性
    public func addObserver(_ observer: NSObject, callback: @escaping KVOCallback, forKeyPath keyPath: String) {
        _addObserver(observer, callback: callback, forKeyPath: keyPath)
    }
    
    public func addObserver(_ observer: NSObject, callback: @escaping KVOCallback, forKeyPaths keyPaths: [String]) {
        guard let owner = self.owner else {
            return
        }
        if keyPaths.count > 0 {
            for keyPath in keyPaths {
                _addObserver(observer, callback: callback, forKeyPath: keyPath)
            }
        } else {
            addObserver(observer, callback: callback, for: owner.classForCoder)
        }
    }
    
    ///该方法不支持 结构体、枚举、可选的基本数据类型
    public func addObserver(_ observer: NSObject, callback: @escaping KVOCallback) {
        addObserver(observer, callback: callback, forKeyPaths: [])
    }
    
    /// 需要手动调用回调 主要用于值可能发生多次改变，但只需要回调一次
    public func addObserver(_ observer: NSObject, manualCallback callback: @escaping KVOCallback, forKeyPath keyPath: String) {
        _addObserver(observer, callback: KVOCallbackModel(callback: callback), forKeyPath: keyPath)
    }
    
    /// 调用未回调的
    public func flushManualCallback(observer: NSObject) {
        if let dic = callbacks[observer.hash] as? NSMutableDictionary {
            for key in dic {
                if let model = dic[key] as? KVOCallbackModel,
                   let keyPath = key.value as? String,
                   model.hasOldValue {
                    model.callback(keyPath, model.newValue, model.oldValue)
                }
            }
        }
    }
    
    /// 移除观察者
    /// @param observer 观察者，将使用hash作为 key来保存
    /// @param keyPath 监听的属性，如果为空，则移除observer对应的所有 keyPath
    public func removeObserver(_ observer: NSObject, for keyPath: String) {
        if let dic = callbacks[observer.hash] as? NSMutableDictionary {
            dic.removeObject(forKey: keyPath)
            if dic.count == 0 {
                callbacks.removeObject(forKey: observer.hash)
            }
        }
    }
    
    public func removeObserver(_ observer: NSObject, forKeyPaths keyPaths: [String]) {
        if let dic = callbacks[observer.hash] as? NSMutableDictionary {
            for keyPath in keyPaths {
                dic.removeObject(forKey: keyPath)
            }
            if dic.count == 0 {
                callbacks.removeObject(forKey: observer.hash)
            }
        }
    }
    
    public func removeObserver(_ observer: NSObject) {
        callbacks.removeObject(forKey: observer.hash)
    }
    
    // MARK: - KVO
    
    private func addObserver(_ observer: NSObject, callback: @escaping KVOCallback, for cls: AnyClass) {
        if cls == KVOHelper.self {
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
                var enable = true
                if !shouldObserveReadonly {
                    guard let attributes = property_getAttributes(property), let attr = String(cString: attributes, encoding: .utf8) else {
                        continue
                    }
                    //判断是否是只读属性
                    let attrs = attr.components(separatedBy: ",")
                    if attrs.contains("R") {
                        enable = false
                    }
                }
                if enable {
                    _addObserver(observer, callback: callback, forKeyPath: name)
                }
            }
            free(properties)
        }

        //递归获取父类的属性
        if let superClass = cls.superclass() {
            addObserver(observer, callback: callback, for: superClass)
        }
    }
    
    private func _addObserver(_ observer: NSObject, callback: Any, forKeyPath keyPath: String) {
        guard let owner = self.owner else {
            return
        }
        
        if !observingKeyPaths.contains(keyPath) {
            owner.addObserver(self, forKeyPath: keyPath, options: [.new, .old], context: &KVOContext)
            observingKeyPaths.insert(keyPath)
        }
        
        var dic = callbacks[observer.hash] as? NSMutableDictionary
        if dic == nil {
            dic = NSMutableDictionary()
            callbacks[observer.hash] = dic
        }
        dic![keyPath] = callback
    }
    
    open override func observeValue(forKeyPath keyPath: String?, of object: Any?, change: [NSKeyValueChangeKey : Any]?, context: UnsafeMutableRawPointer?) {
        guard let keyPath = keyPath,
            let context = context else {
                return
        }
        
        if context.assumingMemoryBound(to: String.self).pointee == KVOContext {
            for key in callbacks {
                let dic = callbacks[key] as? NSMutableDictionary
                let value = dic?[keyPath]
                if let callback = value as? KVOCallback {
                    callback(keyPath, change?[NSKeyValueChangeKey.newKey], change?[NSKeyValueChangeKey.oldKey])
                } else if let model = value as? KVOCallbackModel {
                    model.oldValue = change?[NSKeyValueChangeKey.oldKey]
                    model.newValue = change?[NSKeyValueChangeKey.newKey]
                }
            }
        } else {
            super.observeValue(forKeyPath: keyPath, of: object, change: change, context: context)
        }
    }
    
    deinit {
        guard let owner = self.owner else {
            return
        }
        for keyPath in observingKeyPaths {
            owner.removeObserver(self, forKeyPath: keyPath, context: &KVOContext)
        }
    }
}
