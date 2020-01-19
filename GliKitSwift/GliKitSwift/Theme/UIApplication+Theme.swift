//
//  UIApplication+Theme.swift
//  GliKitSwift
//
//  Created by 罗海雄 on 2020/1/19.
//  Copyright © 2020 luohaixiong. All rights reserved.
//

import UIKit

public extension UIApplication {
    
    ///分割线高度
    static var gkSeparatorHeight = 1.0 / UIScreen.main.scale

    ///导航栏间距
    static var gkNavigationBarMargin: CGFloat = 15

    ///导航栏titleView 和 item的间距
    static var gkNavigationBarTitleViewItemMargin: CGFloat = -6

    ///状态栏样式
    static var gkStatusBarStyle = UIStatusBarStyle.default

    ///状态栏高度
    func gkStatusBarHeight() -> CGFloat {
        
        if #available(iOS 13.0, *) {
            if let window = UIApplication.shared.delegate?.window {
                if let statusBarManager = window?.windowScene?.statusBarManager {
                    return statusBarManager.statusBarFrame.size.height
                }
            }
        }
        
        return UIApplication.shared.statusBarFrame.size.height
    }
}
