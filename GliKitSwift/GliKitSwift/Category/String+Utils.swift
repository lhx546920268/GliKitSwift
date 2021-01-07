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
        guard var str = string as? String else {
            return true
        }
        
        if str.count == 0 {
            return true
        }
        
        str = str.replacingOccurrences(of: " ", with: "")
        if str.count == 0 {
            return true
        }
        
        str = str.replacingOccurrences(of: "\n", with: "")
        if str.count == 0 {
            return true
        }
        
        str = str.replacingOccurrences(of: "\r", with: "")
        if str.count == 0 {
            return true
        }
        
        return false
    }
    
    ///获取子字符串
    func substring(location: Int, length: Int) -> String {
        return substring(in: NSRange(location: location, length: length))
    }
    
    func substring(in range: NSRange) -> String {
        let from = index(startIndex, offsetBy: range.location)
        let to = index(startIndex, offsetBy: range.location + range.length)
        
        return String(self[from ..< to])
    }
    
    ///替换字符串
    func replaceString(in range: NSRange, with string: String) -> String {
        let from = index(startIndex, offsetBy: range.location)
        let to = index(startIndex, offsetBy: range.location + range.length)
        
        return replacingCharacters(in: from ..< to, with: string)
    }
    
    /// 获取字符串显示的大小
    /// - Parameters:
    ///   - font: 字体
    ///   - width: 最大宽度
    func gkStringSize(font: UIFont, with width: CGFloat = CGFloat.greatestFiniteMagnitude) -> CGSize {
        
        let str = NSString(string: self)
        let constraintSize = CGSize(width: width, height: CGFloat.greatestFiniteMagnitude)
        let attributes: [NSAttributedString.Key: Any] = [.font: font]
        
        let size = str.boundingRect(with: constraintSize, options: [.usesFontLeading, .usesLineFragmentOrigin], attributes: attributes, context: nil).size
        
        return CGSize(width: ceil(size.width), height: ceil(size.height))
    }
    
    ///第一个字符
    var gkFirstCharacter: Character?{
        if count > 0 {
            return self[startIndex]
        }
        
        return nil
    }

    ///最后一个字符
    var gkLastCharacter: Character?{
        if count > 0 {
            return self[endIndex]
        }
        
        return nil
    }
    
    ///获取md5字符串
    var gkMD5String: String{
        
        let cStr = cString(using: .utf8)
        
        let length = Int(CC_MD5_DIGEST_LENGTH)
        let result = UnsafeMutablePointer<UInt8>.allocate(capacity: length)
        CC_MD5(cStr, CC_LONG(lengthOfBytes(using: .utf8)), result)

        let md5 = NSMutableString()
        for i in 0 ..< length {
            md5.appendFormat("%02X", result[i])
        }
        
        result.deallocate()
        return String(md5)
    }
    
    ///获取sha256字符串
    var gkSha256String: String{
        let cStr = cString(using: .utf8)
        
        let length = Int(CC_SHA256_DIGEST_LENGTH)
        let result = UnsafeMutablePointer<UInt8>.allocate(capacity: length)
        CC_SHA256(cStr, CC_LONG(lengthOfBytes(using: .utf8)), result)

        let sha256 = NSMutableString()
        for i in 0 ..< length {
            sha256.appendFormat("%02X", result[i])
        }
        
        result.deallocate()
        return String(sha256)
    }
}

// MARK: - 校验

public extension String {
   
    ///是否是纯数字
    var isDigitalOnly: Bool {
        trimmingCharacters(in: CharacterSet.decimalDigits).count == 0
    }

    ///是否是整数
    var isInteger: Bool {
        let scan = Scanner(string: self)
        var val: Int = 0
        return scan.scanInt(&val) && scan.isAtEnd
    }
}

public extension Character {
    
    ///转成整型
    func toInt() -> Int{
        return String(self).intValue
    }
}
