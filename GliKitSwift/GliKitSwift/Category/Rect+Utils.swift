//
//  Rect+Utils.swift
//  GliKitSwift
//
//  Created by 罗海雄 on 2020/1/20.
//  Copyright © 2020 luohaixiong. All rights reserved.
//

import UIKit

public extension UIView {
    
    ///get and set frame.origin.y
    var gkTop: CGFloat{
        set(value){
            var frame = self.frame
            frame.origin.y = value
            self.frame = frame
        }
        get{
            frame.minY
        }
    }

    ///get and set (frame.origin.y + frame.size.height)
    var gkBottom: CGFloat{
        set(value){
            var frame = self.frame
            frame.origin.y = value - frame.size.height
            self.frame = frame
        }
        get{
            frame.maxY
        }
    }
    
    ///get and set frame.origin.x
    var gkLeft: CGFloat{
        set(value){
            var frame = self.frame
            frame.origin.x = value
            self.frame = frame
        }
        get{
            frame.minX
        }
    }

    ///get and set (frame.origin.x + frame.size.width)
    var gkRight: CGFloat{
        set(value){
            var frame = self.frame
            frame.origin.x = value - frame.size.width
            self.frame = frame
        }
        get{
            frame.maxX
        }
    }

    ///get and set frame.size.width
    var gkWidth: CGFloat{
        set(value){
            var frame = self.frame
            frame.size.width = value
            self.frame = frame
        }
        get{
            frame.width
        }
    }

    ///get and set frame.size.height
    var gkHeight: CGFloat{
        set(value){
            var frame = self.frame
            frame.size.height = value
            self.frame = frame
        }
        get{
            frame.height
        }
    }

    ///get and set frame.size
    var gkSize: CGSize{
        set(value){
            var frame = self.frame
            frame.size = value
            self.frame = frame
        }
        get{
            frame.size
        }
    }

    ///get and set center.x
    var gkCenterX: CGFloat{
        set(value){
            var center = self.center
            center.x = value
            self.center = center
        }
        get{
            center.x
        }
    }

    ///get and set center.y
    var gkCenterY: CGFloat{
        set(value){
            var center = self.center
            center.y = value
            self.center = center
        }
        get{
            center.y
        }
    }
}

public extension UIScreen {
    
    ///获取屏幕宽度
    static var gkWidth: CGFloat{
        main.bounds.width
    }

    ///获取屏幕高度
    static var gkHeight: CGFloat{
        main.bounds.height
    }

    ///获取屏幕大小
    static var gkSize: CGSize{
        main.bounds.size
    }
}

public extension UIScrollView {
    
    ///get and set contentInset
    var gkInsetTop: CGFloat {
        set(value){
            var inset = contentInset
            inset.top = value
            contentInset = inset
        }
        get{
            contentInset.top
        }
    }
    
    ///get and set contentInset
    var gkInsetLeft: CGFloat {
        set(value){
            var inset = contentInset
            inset.left = value
            contentInset = inset
        }
        get{
            contentInset.left
        }
    }
    
    ///get and set contentInset
    var gkInsetBottom: CGFloat {
        set(value){
            var inset = contentInset
            inset.bottom = value
            contentInset = inset
        }
        get{
            contentInset.bottom
        }
    }
    
    ///get and set contentInset
    var gkInsetRight: CGFloat {
        set(value){
            var inset = contentInset
            inset.right = value
            contentInset = inset
        }
        get{
            contentInset.right
        }
    }
}
