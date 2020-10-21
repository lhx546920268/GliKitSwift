//
//  String+Utils.swift
//  GliKitSwift
//
//  Created by 罗海雄 on 2020/1/17.
//  Copyright © 2020 luohaixiong. All rights reserved.
//

import UIKit
import CommonCrypto

public extension String {
    
    ///判断字符串是否为空，会去掉 空格 \n \r
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
    
    ///获取子字符串
    func substring(location: Int, length: Int) -> String {
        
        let from = self.index(self.startIndex, offsetBy: location)
        let to = self.index(self.startIndex, offsetBy: location + length)
        
        return String(self[from ..< to])
    }
    
    /// 获取字符串显示的大小
    /// - Parameters:
    ///   - font: 字体
    ///   - constraintWidth: 最大宽度
    func gkStringSize(font: UIFont, with width: CGFloat = CGFloat.greatestFiniteMagnitude) -> CGSize {
        
        let str = NSString(string: self)
        let constraintSize = CGSize(width: width, height: CGFloat.greatestFiniteMagnitude)
        let attributes: [NSAttributedString.Key: Any] = [.font: font]
        
        let size = str.boundingRect(with: constraintSize, options: [.usesFontLeading, .usesLineFragmentOrigin], attributes: attributes, context: nil).size
        
        return CGSize(width: ceil(size.width), height: ceil(size.height))
    }
    
    ///第一个字符
    var gkFirstCharacter: Character?{
        if self.count > 0 {
            return self[self.startIndex]
        }
        
        return nil
    }

    ///最后一个字符
    var gkLastCharacter: Character?{
        if self.count > 0 {
            return self[self.endIndex]
        }
        
        return nil
    }
    
    ///获取md5字符串
    var gkMD5String: String{
        
        let cStr = self.cString(using: .utf8)
        
        let length = Int(CC_MD5_DIGEST_LENGTH)
        let result = UnsafeMutablePointer<UInt8>.allocate(capacity: length)
        CC_MD5(cStr, CC_LONG(self.lengthOfBytes(using: .utf8)), result)

        let md5 = NSMutableString()
        for i in 0 ..< length {
            md5.appendFormat("%02X", result[i])
        }
        
        result.deallocate()
        
        return String(md5)
    }
}

public extension Character {
    
    ///转成整型
    func toInt() -> Int{
        return String(self).intValue
    }
}
