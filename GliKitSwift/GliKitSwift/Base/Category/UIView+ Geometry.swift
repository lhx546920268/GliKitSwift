//
//  UIView+ Geometry.swift
//  GliKitSwift
//
//  Created by 罗海雄 on 2020/4/17.
//  Copyright © 2020 luohaixiong. All rights reserved.
//

import UIKit

public extension CGPoint{
    
    init(_ x: CGFloat, _ y: CGFloat){
        self.init(x: x, y: y)
    }
    
    init(_ x: Int, _ y: Int){
        self.init(x: x, y: y)
    }
    
    init(_ x: Double, _ y: Double){
        self.init(x: x, y: y)
    }
}

public extension CGSize{
    
    init(_ width: CGFloat, _ height: CGFloat){
        self.init(width: width, height: height)
    }
    
    init(_ width: Int, _ height: Int){
        self.init(width: width, height: height)
    }
    
    init(_ width: Double, _ height: Double){
        self.init(width: width, height: height)
    }
    
    ///是否有个0
    var hasZero: Bool {
        width == 0 || height == 0
    }
    
    ///是否有个0或者负数
    var hasZeroOrNegative: Bool {
        width <= 0 || height <= 0
    }
    
    ///是否都是0
    var bothZero: Bool {
        width == 0 && height == 0
    }
    
    ///是否都是0或者负数
    var bothZeroOrNegative: Bool {
        width <= 0 && height <= 0
    }
}

public extension CGRect{
    
    init(_ x: CGFloat, _ y: CGFloat, _ width: CGFloat, _ height: CGFloat){
        self.init(x: x, y: y, width: width, height: height)
    }
    
    init(_ x: Int, _ y: Int, _ width: Int, _ height: Int){
        self.init(x: x, y: y, width: width, height: height)
    }
    
    init(_ x: Double, _ y: Double, _ width: Double, _ height: Double){
        self.init(x: x, y: y, width: width, height: height)
    }
}

public extension UIEdgeInsets{
    
    init(_ top: CGFloat, _ left: CGFloat, _ bottom: CGFloat, _ right: CGFloat) {
        self.init(top: top, left: left, bottom: bottom, right: right)
    }
    
    static func all(_ all: CGFloat) -> UIEdgeInsets {
        self.init(all, all, all, all)
    }
    
    static func only(top: CGFloat = 0, left: CGFloat = 0, bottom: CGFloat = 0, right: CGFloat = 0) -> UIEdgeInsets  {
        self.init(top, left, bottom, right)
    }
    
    var width: CGFloat{
        left + right
    }
    
    var height: CGFloat{
        top + bottom
    }
}

