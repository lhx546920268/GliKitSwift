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
    
    required public init?(coder: NSCoder) {
        super.init(coder: coder)
    }
    
    open override func didInitCollectionView(_ collectionView: UICollectionView) {
        collectionView.registerClass(TabMenuBarCell.self)
    }
    
    open override func onMeasureItems() -> CGFloat {
        
        var totalWidth: CGFloat = 0
        
        if let items = self.tabItems {
            for i in items.indices {
                let item = items[i]
                var size = item.title?.gkStringSize(font: normalFont) ?? CGSize.zero
                if item.icon != nil {
                    size.width += item.icon!.size.width + item.iconPadding
                    size.height = max(size.height, item.icon!.size.height)
                }
                item.contentSize = size
                item.itemWidth = size.width + itemPadding
                
                totalWidth += item.itemWidth
                if i != items.count - 1 {
                    totalWidth += itemInterval
                }
            }
        }
        return totalWidth
    }

    // MARK: - UICollectionView delegate
    
    override public func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: TabMenuBarCell.gkNameOfClass, for: indexPath) as! TabMenuBarCell
        
        let item = tabItems![indexPath.item]
        cell.button.setTitleColor(selectedTextColor, for: .selected)
        cell.button.setTitleColor(normalTextColor, for: .normal)
        cell.button.titleLabel?.font = selectedIndex == indexPath.item ? selectedFont : normalFont
        
        cell.item = item
        cell.tick = selectedIndex == indexPath.item
        cell.divider.isHidden = !displayItemDidvider || indexPath.item == tabItems!.count - 1 || currentStyle == .fit
        
        return cell
    }

    public func collectionView(_ collectionView: UICollectionView, willDisplay cell: UICollectionViewCell, forItemAt indexPath: IndexPath) {
        let item = tabItems![indexPath.item]
        if item.customView != nil {
            tabDelegate?.menuBar(self, willDisplay: item.customView!, at: indexPath.item)
        }
    }

    //MARK: - 设置

    /**
     *设置按钮边缘数字
     *@param badgeValue 边缘数字，大于99会显示99+，小于等于0则隐藏
     *@param index 按钮下标
     */
    public func setBadgeValue(_ badgeValue: String?, index: Int){
        assert(index < self.items?.count ?? 0, "\(self.gkNameOfClass) setBadgeValue, index \(index) 已越界")
        
        if let item = self.items?[index] as? TabMenuBarItem {
            item.badgeNumber = badgeValue
            self.collectionView.reloadItems(at: [IndexPath(item: index, section: 0)])
        }
    }

    /**
     *改变按钮标题
     *@param title 按钮标题
     *@param index 按钮下标
     */
    public func setTitle(_ title: String?, index: Int){
        assert(index < self.items?.count ?? 0, "\(self.gkNameOfClass) setTitle, index \(index) 已越界")
        
        if let item = self.items?[index] as? TabMenuBarItem {
            item.title = title
            self.collectionView.reloadItems(at: [IndexPath(item: index, section: 0)])
        }
    }

    /**
     *改变按钮图标
     *@param icon 按钮图标
     *@param index 按钮下标
     */
    public func setIcon(_ icon: UIImage?, index: Int){
        assert(index < self.items?.count ?? 0, "\(self.gkNameOfClass) setIcon, index \(index) 已越界")
        
        if let item = self.items?[index] as? TabMenuBarItem {
            item.icon = icon
            self.collectionView.reloadItems(at: [IndexPath(item: index, section: 0)])
        }
    }

    /**
     *改变选中按钮图标
     *@param icon 按钮图标
     *@param index 按钮下标
     */
    public func setSelectedIcon(_ icon: UIImage?, index: Int){
        assert(index < self.items?.count ?? 0, "\(self.gkNameOfClass) setSelectedIcon, index \(index) 已越界")
        
        if let item = self.items?[index] as? TabMenuBarItem {
            item.selectedIcon = icon
            self.collectionView.reloadItems(at: [IndexPath(item: index, section: 0)])
        }
    }
}
