//
//  String+Utils.swift
//  GliKitSwift
//
//  Created by 罗海雄 on 2020/1/17.
//  Copyright © 2020 luohaixiong. All rights reserved.
//

import Foundation

public extension String {
    
    /**
     判断字符串是否为空，会去掉 空格 \n \r
     */
    static func isEmpty(_ string: Any?) -> Bool {
        
        if let str = string {
            if str is String {
                var result = str as! String
                if result.count == 0 {
                    return true
                }
                
                result = result.replacingOccurrences(of: " ", with: "")
                if result.count == 0 {
                    return true
                }
                
                result = result.replacingOccurrences(of: "\n", with: "")
                if result.count == 0 {
                    return true
                }
                
                result = result.replacingOccurrences(of: "\r", with: "")
                if result.count == 0 {
                    return true
                }
                
                return false
            }
        }
        
        return true
    }
    
    func substring(location: Int, length: Int) -> String {
        
        let from = self.index(self.startIndex, offsetBy: location)
        let to = self.index(self.startIndex, offsetBy: location + length)
        
        return String(self[from ..< to])
    }
}

public extension Character {
    
    ///转成整型
    func toInt() -> Int{
        
        return Int(String(self).unicodeScalars.first!.value)
    }
}
