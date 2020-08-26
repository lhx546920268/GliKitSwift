//
//  RangeWrapper.swift
//  GliKitSwift
//
//  Created by 罗海雄 on 2020/8/26.
//  Copyright © 2020 luohaixiong. All rights reserved.
//

import Foundation

///值的范围
@propertyWrapper
public struct RangeWrapper<T: Comparable> {
    private var value: T
    private var min: T
    private var max: T
    
    public var wrappedValue: T {
        set{
            if value != newValue {
                value = newValue
                if value < min {
                    value = min
                } else if value > max {
                    value = max
                }
            }
        }
        get{
            value
        }
    }

    public init(value: T, min: T, max: T) {
        self.min = min
        self.max = max
        self.value = value
    }
}
