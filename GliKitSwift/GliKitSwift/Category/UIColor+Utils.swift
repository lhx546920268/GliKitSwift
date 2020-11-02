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
        
        var red: CGFloat = 0
        var green: CGFloat = 0
        var blue: CGFloat = 0
        var alpha: CGFloat = 0
        getRed(&red, green: &green, blue: &blue, alpha: &alpha)
        
        return (red, green, blue, alpha)
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
        
        let hex = hex.replacingOccurrences(of: "#", with: "")
        
        var alpha = 255
        var red = 0
        var green = 0
        var blue = 0

        let length = hex.count
        let hexValue = hex.hexToDecimal
        
        switch (length) {
            case 3 :
                red = (hexValue & 0xf00) >> 8
                green = (hexValue & 0x0f0) >> 4
                blue = (hexValue & 0x00f)
            
            case 4 :
                alpha = (hexValue & 0xf000) >> 16
                red = (hexValue & 0x0f00) >> 8
                green = (hexValue & 0x00f0) >> 4
                blue = (hexValue & 0x000f)
            
            case 6 :
                red = (hexValue & 0xff0000) >> 16
                green = (hexValue & 0x00ff00) >> 8
                blue = (hexValue & 0x0000ff)
            
            case 8 :
                alpha = (hexValue & 0xff000000) >> 32
                red = (hexValue & 0x00ff0000) >> 16
                green = (hexValue & 0x0000ff00) >> 8
                blue = (hexValue & 0x000000ff)
            
            default:
                break
        }
        
        let max: CGFloat = 255
        return (CGFloat(red) / max, CGFloat(green) / max, CGFloat(blue) / max, CGFloat(alpha) / max)
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
        
        return String(Int(alpha * 255) << 32 + red << 16 + green << 8 + blue, radix: 16)
    }
    
    /**
     通过16进制颜色值获取颜色 当hex里面有没有透明度值时，透明度为 1.0
     *@param hex 16进制值
     *@return 一个 UIColor对象
     */
    static func gkColorFromHex(_ hex: String) -> UIColor {
        
        if let argb = UIColor.gkColorARGB(hex: hex) {
            return UIColor(red: argb.red, green: argb.green, blue: argb.blue, alpha: argb.alpha)
        }
        return .clear
    }
    
    /**
     通过16进制颜色值获取颜色 将忽略16进制值里面的透明度
     *@param hex 16进制值
     *@param alpha 0~1.0 透明度
     *@return 一个 UIColor对象
     */
    static func gkColorFromHex(_ hex: String, alpha: CGFloat) -> UIColor {
        
        if let argb = UIColor.gkColorARGB(hex: hex) {
            return UIColor(red: argb.red, green: argb.green, blue: argb.blue, alpha: alpha)
        }
        return .clear
        
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
