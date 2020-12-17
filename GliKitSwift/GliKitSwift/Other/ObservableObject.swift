//
//  ObservableObject.swift
//  GliKitSwift
//
//  Created by 罗海雄 on 2020/11/24.
//  Copyright © 2020 luohaixiong. All rights reserved.
//

import Foundation

private var ObservableContext = "com.glikit.GKObservableContext"

/// 回调
/// @param keyPath  属性，和addObserver 中的一致
/// @param newValue 新值 值类型要拆箱
/// @param oldValue 旧值 值类型要拆箱
public typealias ObserverCallback = (_ keyPath: String, _ newValue: Any?, _ oldValue: Any?) -> Void

///可观察的对象 要监听的属性必须标记为 @objc dynamic
open class ObservableObject: BaseObject {
    
    ///是否监听只读属性
    public var shouldObserveReadonly: Bool = false
    
    ///当前监听的属性
    private lazy var observingKeyPaths: Set<String> = {
        return Set<String>()
    }()
    
    ///回调
    private lazy var observerCallbacks: NSMutableDictionary = {
        return NSMutableDictionary()
    }()
    
    /// 添加一个观察者，必须通过 .语法 设置新值才会触发回调
    /// @param observer 观察者，将使用hash作为 key来保持
    /// @param callback 回调
    /// @param keyPath 要监听的属性，如果为空，则监听所有属性
    public func addObserver(_ observer: NSObject, callback: @escaping ObserverCallback, forKeyPath keyPath: String) {
        _addObserver(observer, callback: callback, forKeyPath: keyPath)
    }
    
    public func addObserver(_ observer: NSObject, callback: @escaping ObserverCallback, forKeyPaths keyPaths: [String]) {
        if keyPaths.count > 0 {
            for keyPath in keyPaths {
                _addObserver(observer, callback: callback, forKeyPath: keyPath)
            }
        } else {
            addObserver(observer, callback: callback, for: self.classForCoder)
        }
    }
    
    ///该方法不支持 结构体、枚举、可选的基本数据类型
    public func addObserver(_ observer: NSObject, callback: @escaping ObserverCallback) {
        addObserver(observer, callback: callback, forKeyPaths: [])
    }
    
    
    /// 移除观察者
    /// @param observer 观察者，将使用hash作为 key来保持
    /// @param keyPath 监听的属性，如果为空，则移除observer对应的所有 keyPath
    public func removeObserver(_ observer: NSObject, for keyPath: String) {
        if let dic = observerCallbacks[observer.hash] as? NSMutableDictionary {
            dic.removeObject(forKey: keyPath)
            if dic.count == 0 {
                observerCallbacks.removeObject(forKey: observer.hash)
            }
        }
    }
    
    public func removeObserver(_ observer: NSObject, forKeyPaths keyPaths: [String]) {
        if let dic = observerCallbacks[observer.hash] as? NSMutableDictionary {
            for keyPath in keyPaths {
                dic.removeObject(forKey: keyPath)
            }
            if dic.count == 0 {
                observerCallbacks.removeObject(forKey: observer.hash)
            }
        }
    }
    
    public func removeObserver(_ observer: NSObject) {
        observerCallbacks.removeObject(forKey: observer.hash)
    }
    
    // MARK: - KVO
    
    private func addObserver(_ observer: NSObject, callback: @escaping ObserverCallback, for cls: AnyClass) {
        if cls == ObservableObject.self {
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
    
    private func _addObserver(_ observer: NSObject, callback: @escaping ObserverCallback, forKeyPath keyPath: String) {
        if !observingKeyPaths.contains(keyPath) {
            addObserver(observer, forKeyPath: keyPath, options: [.new, .old], context: &ObservableContext)
            observingKeyPaths.insert(keyPath)
        }
        
        var dic = observerCallbacks[observer.hash] as? NSMutableDictionary
        if dic == nil {
            dic = NSMutableDictionary()
            observerCallbacks[observer.hash] = dic
        }
        dic![keyPath] = callback
    }
    
    open override func observeValue(forKeyPath keyPath: String?, of object: Any?, change: [NSKeyValueChangeKey : Any]?, context: UnsafeMutableRawPointer?) {
        guard let keyPath = keyPath,
            let context = context,
            context.assumingMemoryBound(to: String.self).pointee == ObservableContext  else {
                return
        }
        for key in observerCallbacks {
            let dic = observerCallbacks[key] as? NSMutableDictionary
            let callback = dic?[keyPath] as? ObserverCallback
            callback?(keyPath, change?[NSKeyValueChangeKey.newKey], change?[NSKeyValueChangeKey.oldKey])
        }
    }
    
    deinit {
        for keyPath in observingKeyPaths {
            removeObserver(self, forKeyPath: keyPath, context: &ObservableContext)
        }
    }
}
