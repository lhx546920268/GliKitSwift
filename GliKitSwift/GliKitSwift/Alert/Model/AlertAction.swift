//
//  AlertAction.swift
//  GliKitSwift
//
//  Created by 罗海雄 on 2020/8/27.
//  Copyright © 2020 luohaixiong. All rights reserved.
//

import UIKit

///弹窗按钮样式
open class AlertAction {
    
    ///是否可以点击
    public var enable: Bool = true
    
    ///字体 如果没有，则使用默认字体
    public var font: UIFont?
    
    ///字体颜色 如果没有，则使用默认字体颜色
    public var textColor: UIColor?
    
    ///按钮标题
    public var title: String?
    
    ///图标
    public var icon: UIImage?
    
    ///图片和标题的间隔
    public var spacing: CGFloat = 5
    
    ///图标位置
    public var imagePosition: ButtonImagePosition = .left
    
    /**
     构造方法
     @param title 按钮标题
     @param icon 按钮图标
     @return 一个实例
     */
    init(title: String? = nil, icon: UIImage? = nil) {
        self.title = title
        self.icon = icon
    }
}
