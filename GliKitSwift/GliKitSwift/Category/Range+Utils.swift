//
//  Range+Utils.swift
//  GliKitSwift
//
//  Created by 罗海雄 on 2020/11/11.
//  Copyright © 2020 luohaixiong. All rights reserved.
//

import Foundation

public extension NSRange {
    
    var min: Int {
        location
    }
    
    var max: Int {
        location + length
    }
    
    var isValid: Bool {
        location != NSNotFound && location >= 0
    }
}

public extension CFRange {
    
    var min: CFIndex {
        location
    }
    
    var max: CFIndex {
        location + length
    }
    
    var isValid: Bool {
        location != NSNotFound && location >= 0
    }
}
