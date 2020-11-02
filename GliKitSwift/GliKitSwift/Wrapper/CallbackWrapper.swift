//
//  CallbackWrapper.swift
//  GliKitSwift
//
//  Created by 罗海雄 on 2020/11/2.
//  Copyright © 2020 luohaixiong. All rights reserved.
//

import Foundation

///值改变后会回调，可通过_property.callback = xx 设置
@propertyWrapper
public struct CallbackWrapper<T: Equatable> {
    
    var callback: VoidCallback?
    
    private var value: T
    
    public var wrappedValue: T {
        set{
            if value != newValue {
                value = newValue
                callback?()
            }
        }
        get{
            value
        }
    }

    public init(wrappedValue: T) {
        value = wrappedValue
    }
}
