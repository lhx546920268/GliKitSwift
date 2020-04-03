//
//  TabMenuBarItem.swift
//  GliKitSwift
//
//  Created by 罗海雄 on 2020/4/2.
//  Copyright © 2020 luohaixiong. All rights reserved.
//

import UIKit

///菜单按钮信息
class TabMenuBarItem: MenuBarItem {
    
    ///标题
    public var title: String?

    ///按钮图标
    public var icon: UIImage?

    ///选中按钮图标
    public var selectedIcon: UIImage?

    ///图标和标题的间隔
    public var iconPadding: CGFloat = 0

    ///自定义视图
    public var customView: UIView?

    ///图标位置
    public var iconPosition = ButtonImagePosition.left

    ///按钮背景图片
    public var backgroundImage: UIImage?

    ///按钮边缘数据
    public var badgeNumber: String?

    ///标题偏移量
    public var titleInsets = UIEdgeInsets.zero

    /**
     构造方法
     *@param title 标题
     *@return 已初始化的 GKMenuBarItem
     */
    init(title: String?) {
        self.title = title
        super.init()
    }
}
