//
//  TabMenuBar.swift
//  GliKitSwift
//
//  Created by 罗海雄 on 2020/4/3.
//  Copyright © 2020 luohaixiong. All rights reserved.
//

import UIKit

///条形菜单代理
@objc public protocol TabMenuBarDelegate: MenuBarDelegate{
    
    ///要显示自定义视图了 要自己调整位置
    @objc func menuBar(_ menu: TabMenuBar, willDisplay customView: UIView, at index: Int)
}

///条形菜单 当菜单按钮数量过多时，可滑动查看更多的按钮
open class TabMenuBar: MenuBar {

    //MARK: - 按钮样式

    ///菜单按钮字体颜色
    public var normalTextColor = UIColor.darkGray

    ///菜单按钮字体
    public var normalFont = UIFont.systemFont(ofSize: 13)

    ///菜单按钮 选中颜色
    public var selectedTextColor = UIColor.gkThemeColor
    
    ///菜单按钮 选中字体 nil的时候使用 normalFont
    public var _selectedFont: UIFont?
    public var selectedFont: UIFont?{
        get{
            return _selectedFont != nil ? _selectedFont : self.normalFont
        }
        set{
            _selectedFont = newValue
        }
    }

    ///是否显示分隔符 只有 GKTabMenuBarStyleFit 生效
    public var displayItemDidvider = true
    
    //MARK: - 其他

    ///菜单按钮标题 设置此值会导致菜单重新加载数据
    public var titles: [String]?{
        set{
            var items = [TabMenuBarItem]()
            
            if let titles = newValue {
                for title in titles {
                    items.append(TabMenuBarItem(title: title))
                }
            }
            
            self.items = items
        }
        get{
            if let items = self.tabItems {
                var titles = [String]()
                for item in items {
                    titles.append(item.title ?? "")
                }
                return titles
            } else {
                return nil
            }
        }
    }
    
    ///按钮信息 设置此值会导致菜单重新加载数据
    private var tabItems: [TabMenuBarItem]?{
        get{
            super.items as? [TabMenuBarItem]
        }
    }
    
    ///代理
    private var tabDelegate: TabMenuBarDelegate?{
        get{
            super.delegate as? TabMenuBarDelegate
        }
    }


    //MARK: - Init

    /**
    构造方法
    *@param frame 位置大小
    *@param titles 菜单按钮标题
    *@return 一个实例
    */
    init(frame: CGRect = .zero, titles: [String]?){
        super.init(frame: frame, items: nil)
        self.titles = titles
    }

//
//    //MARK: - 设置
//
//    /**
//     *设置按钮边缘数字
//     *@param badgeValue 边缘数字，大于99会显示99+，小于等于0则隐藏
//     *@param index 按钮下标
//     */
//    - (void)setBadgeValue:(nullable NSString*) badgeValue forIndex:(NSUInteger) index;
//
//    /**
//     *改变按钮标题
//     *@param title 按钮标题
//     *@param index 按钮下标
//     */
//    - (void)setTitle:(nullable NSString*) title forIndex:(NSUInteger) index;
//
//    /**
//     *改变按钮图标
//     *@param icon 按钮图标
//     *@param index 按钮下标
//     */
//    - (void)setIcon:(nullable UIImage*) icon forIndex:(NSUInteger) index;
//
//    /**
//     *改变选中按钮图标
//     *@param icon 按钮图标
//     *@param index 按钮下标
//     */
//    - (void)setSelectedIcon:(nullable UIImage*) icon forIndex:(NSUInteger) index;
}
