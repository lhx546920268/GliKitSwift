//
//  UIView+NavigationBarUtils.swift
//  GliKitSwift
//
//  Created by 罗海雄 on 2020/4/23.
//  Copyright © 2020 luohaixiong. All rights reserved.
//

import UIKit

///该扩展主要是适配 ios 11及以上 导航栏左右按钮间距无法设置的问题
internal extension UIView {
    
    private static let NavigationBarContentViewName = "_UINavigationBarContentView"

    static func swizzleNavigationBarMargins(){
        
        if #available(iOS 11, *) {
            swizzling(selector1: #selector(gkLayoutMargins), selector2: #selector(setter: layoutMargins), cls1: self)
            swizzling(selector1: #selector(gkDirectionalLayoutMargins), selector2: #selector(setter: directionalLayoutMargins), cls1: self)
        }
    }
    
    @objc func gkLayoutMargins() -> UIEdgeInsets {
        if gkIsAppNavigationBar {
            return .zero
        } else {
            return self.gkLayoutMargins()
        }
    }
    
    @available(iOS 11, *)
    @objc func gkDirectionalLayoutMargins() -> NSDirectionalEdgeInsets {
        if gkIsAppNavigationBar {
            return .zero
        } else {
            return self.gkDirectionalLayoutMargins()
        }
    }
    
    ///是否自己的导航栏
    var gkIsAppNavigationBar: Bool{
        get{
            return self.gkNameOfClass == UIView.NavigationBarContentViewName && superview?.classForCoder === SystemNavigationBar.self
        }
    }
}
