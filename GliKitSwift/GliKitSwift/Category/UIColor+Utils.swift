//
//  UIColor+Utils.swift
//  GliKitSwift
//
//  Created by 罗海雄 on 2020/1/17.
//  Copyright © 2020 luohaixiong. All rights reserved.
//

import UIKit

/**
 16进制可不带#，格式为 #c0f，c0f，#cc00ff，cc00ff，#fc0f，fc0f，#ffcc00ff，ffcc00ff
 返回的16进制是不带#的 小写字母
 返回的ARGB 值 rgb，透明度为0~1.0
 */
public extension UIColor {
    
    /**
     获取颜色的ARGB值 0 ~ 1.0
     */
    func gkColorARGB() -> (red: CGFloat, green: CGFloat, blue: CGFloat, alpha: CGFloat) {
        
        let red = UnsafeMutablePointer<CGFloat>.allocate(capacity: 0)
        let green = UnsafeMutablePointer<CGFloat>.allocate(capacity: 0)
        let blue = UnsafeMutablePointer<CGFloat>.allocate(capacity: 0)
        let alpha = UnsafeMutablePointer<CGFloat>.allocate(capacity: 0)
        
        getRed(red, green: green, blue: blue, alpha: alpha)
        
        let result = (red.pointee, green.pointee, blue.pointee, alpha.pointee)
        red.deallocate()
        green.deallocate()
        blue.deallocate()
        alpha.deallocate()
        
        return result
    }
    
    /**
     获取颜色的16进制 含透明度 FFFFFFFF
     */
    func gkColorHex() -> String {
        
        let argb = gkColorARGB()
        
        return UIColor.gkColorHex(red: Int(argb.red * 255),
                                  green: Int(argb.green * 255),
                                  blue: Int(argb.blue * 255),
                                  alpha: argb.alpha)
    }
    
    /**
     颜色是否相同
     *@param color 要比较的颜色
     */
    func isEqualToColor(_ comparedColor: UIColor?) -> Bool {
        
        if let color = comparedColor {
            
            let argb1 = gkColorARGB()
            let argb2 = color.gkColorARGB()
            
            return argb1.red == argb2.red &&
                argb1.green == argb2.green &&
                argb1.blue == argb2.blue &&
                argb1.alpha == argb2.alpha
        }
        
        return false
    }
    
    /**
     为某个颜色设置透明度
     *@param alpha 透明度 0 ~ 1.0
     *@return 设置了透明度的颜色
     */
    func gkColor(withAlpha alpha: CGFloat) -> UIColor {
        
        let argb = gkColorARGB()
        return UIColor(red: argb.red, green: argb.green, blue: argb.blue, alpha: alpha)
    }
    
    /**
     通过16进制值获取颜色 rgb，如果hex里面没有包含rgb，则透明度为1.0
     @param hex 16进制
     @return 颜色 ARBG
     */
    static func gkColorARGB(hex: String) -> (red: CGFloat, green: CGFloat, blue: CGFloat, alpha: CGFloat)? {
        if String.isEmpty(hex) {
            return nil
        }
        
        let hex = hex.replacingOccurrences(of: "#", with: "").lowercased()
        
        let value: CGFloat = 255
        var alpha = 255
        var red = 0
        var green = 0
        var blue = 0
        
        var index = 0;
        var len = 0;
        let length = hex.count;
        
        switch (length) {
        case 3, 4 :
            let hexArray = Array(hex)
            len = 1;
            if length == 4 {
                let a = UIColor.gkDecimal(hexChar: hexArray[index])
                alpha = a * 16 + a
                index += len
            }
            var value = UIColor.gkDecimal(hexChar: hexArray[index])
            red = value * 16 + value
            index += len
            
            value = UIColor.gkDecimal(hexChar: hexArray[index])
            green = value * 16 + value
            index += len
            
            value = UIColor.gkDecimal(hexChar: hexArray[index])
            blue = value * 16 + value;
        case 6, 8 :
            len = 2;
            if length == 8 {
                alpha = UIColor.gkDecimal(hex: hex.substring(location: index, length: len))
                index += len
            }
            red = UIColor.gkDecimal(hex: hex.substring(location: index, length: len))
            index += len
            
            green = UIColor.gkDecimal(hex: hex.substring(location: index, length: len))
            index += len
            
            blue = UIColor.gkDecimal(hex: hex.substring(location: index, length: len))
        default: break
            
        }
        
        return (CGFloat(red) / value, CGFloat(green) / value, CGFloat(blue) / value, CGFloat(alpha) / value)
    }
    
    /**
     通过ARGB值获取颜色的16进制
     *@param red 红色 0~255
     *@param green 绿色 0~255
     *@param blue 蓝色 0~255
     *@param alpha 透明度
     *@return 16进制颜色值，FFFFFFFF
     */
    static func gkColorHex(red: Int, green: Int, blue: Int, alpha: CGFloat) -> String {
        
        return String(format: "%02x%02x%02x%02x", Int(alpha * 255), red, green, blue)
    }
    
    /**
     通过16进制颜色值获取颜色 当hex里面有没有透明度值时，透明度为 1.0
     *@param hex 16进制值
     *@return 一个 UIColor对象
     */
    static func gkColorFromHex(_ hex: String) -> UIColor? {
        
        if let argb = UIColor.gkColorARGB(hex: hex) {
            return UIColor(red: argb.red, green: argb.green, blue: argb.blue, alpha: argb.alpha)
        }
        return nil
    }
    
    /**
     通过16进制颜色值获取颜色 将忽略16进制值里面的透明度
     *@param hex 16进制值
     *@param alpha 0~1.0 透明度
     *@return 一个 UIColor对象
     */
    static func gkColorFromHex(_ hex: String, alpha: CGFloat) -> UIColor? {
        
        if let argb = UIColor.gkColorARGB(hex: hex) {
            return UIColor(red: argb.red, green: argb.green, blue: argb.blue, alpha: alpha)
        }
        return nil
        
    }
    
    /**
     获取10进制
     *@param hex 16进制
     *@return 10进制值
     */
    static func gkDecimal(hex: String) -> Int {
        var result = 0;
        var than = 1;
        let array = Array(hex)
        for i in 0 ..< array.count {
            let c = array[i]
            
            result += gkDecimal(hexChar: c) * than;
            than *= 16;
        }

        return result;
    }
    
    /**
     获取10进制
     *@param c 16进制
     *@return 10进制值
     */
    static func gkDecimal(hexChar: String.Element) -> Int{
        var value = 0
        switch (hexChar) {
        case "A", "a" :
            value = 10
        case "B", "b" :
            value = 11
        case "C", "c" :
            value = 12
        case "D", "d" :
            value = 13
        case "E", "e" :
            value = 14
        case "F", "f" :
            value = 15
        default :
            value = hexChar.toInt()
        }
        return value
    }
    
    /**
     *以整数rpg初始化
     *@param red 红色 0 ~ 255
     *@param green 绿色 0 ~ 255
     *@param blue 蓝色 0 ~ 255
     *@param alpha 透明度 0 ~ 1.0
     *@return 一个初始化的颜色对象
     */
    static func gkColor(red: Int, green: Int, blue: Int, alpha: CGFloat) -> UIColor {
        
        let value: CGFloat = 255
        return UIColor(red: CGFloat(red) / value, green: CGFloat(green) / value, blue: CGFloat(blue) / value, alpha: alpha)
    }
}
