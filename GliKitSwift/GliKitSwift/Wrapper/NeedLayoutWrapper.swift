//
//  NeedLayoutWrapper.swift
//  GliKitSwift
//
//  Created by 罗海雄 on 2020/8/26.
//  Copyright © 2020 luohaixiong. All rights reserved.
//

import UIKit

///值改变后会 setNeedsLayout，必须设置 view 的值，可通过_property.view = xx 设置
@propertyWrapper
public struct NeedLayoutWrapper<T: Equatable> {
    
    weak var view: UIView?
    private var value: T
    
    public var wrappedValue: T {
        set{
            if value != newValue {
                value = newValue
                view?.setNeedsLayout()
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
