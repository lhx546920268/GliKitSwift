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
    static var gkSeparatorColor = UIColor.init(white: 0.86, alpha: 1.0)

    ///app背景颜色 灰色那个
    static var gkGrayBackgroundColor = UIColor.gkGrayBackgroundColor

    ///骨架层背景颜色
    @property(class, nonatomic, strong) UIColor *gkSkeletonBackgroundColor;

    ///输入框placeholder 颜色
    @property(class, nonatomic, strong) UIColor *gkPlaceholderColor;
}
