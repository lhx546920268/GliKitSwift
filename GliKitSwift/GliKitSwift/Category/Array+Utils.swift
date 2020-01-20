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
