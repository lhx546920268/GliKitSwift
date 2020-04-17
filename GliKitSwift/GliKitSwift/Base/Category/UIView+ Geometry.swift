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
    
    init(_ top: CGFloat, _ left: CGFloat, _ bottom: CGFloat, _ right: CGFloat){
        self.init(top: top, left: left, bottom: bottom, right: right)
    }
}
