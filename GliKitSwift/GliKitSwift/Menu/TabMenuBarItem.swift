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

    /**
     图标位置 default is 'GKButtonImagePositionLeft'
     */
    @property(nonatomic, assign) GKButtonImagePosition iconPosition;

    /**
     按钮背景图片
     */
    @property(nonatomic, strong, nullable) UIImage *backgroundImage;

    /**
     按钮边缘数据
     */
    @property(nonatomic, copy, nullable) NSString *badgeNumber;

    /**
     标题偏移量
     */
    @property(nonatomic, assign) UIEdgeInsets titleInsets;

    /**
     构造方法
     *@param title 标题
     *@return 已初始化的 GKMenuBarItem
     */
    + (instancetype)itemWithTitle:(NSString*) title;

}
