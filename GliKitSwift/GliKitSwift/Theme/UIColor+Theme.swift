//
//  UIColor+Theme.swift
//  GliKitSwift
//
//  Created by 罗海雄 on 2020/1/17.
//  Copyright © 2020 luohaixiong. All rights reserved.
//

import UIKit

public extension UIColor {
    
    ///app主色调
    static var gkThemeColor = UIColor.white
    
    ///主色调对应的 tintColor
    static var gkThemeTintColor = UIColor.black

    ///导航栏背景颜色
    static var gkNavigationBarBackgroundColor = UIColor.white

    ///导航栏标题颜色
    static var gkNavigationBarTitleColor = UIColor.black

    ///导航栏按钮颜色
    static var gkNavigationBarTintColor = UIColor.black

    ///分割线颜色
    static var gkSeparatorColor = UIColor(white: 0.86, alpha: 1.0)

    ///app背景颜色 灰色那个
    static var gkGrayBackgroundColor = UIColor.gkColorFromHex("F2F2F2")

    ///骨架层背景颜色
    static var gkSkeletonBackgroundColor = UIColor(white: 0.9, alpha: 1.0)
    
    ///高亮灰色背景颜色
    static var gkHighlightedBackgroundColor = UIColor(white: 0.9, alpha: 1.0)

    ///输入框placeholder 颜色
    static var gkPlaceholderColor = UIColor(white: 0.702, alpha: 1.0)
}
