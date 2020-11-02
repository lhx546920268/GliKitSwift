//
//  TabBar.swift
//  GliKitSwift
//
//  Created by 罗海雄 on 2020/11/2.
//  Copyright © 2020 luohaixiong. All rights reserved.
//

import UIKit

///选项卡代理
public protocol TabBarDelegate: AnyObject {
    
    ///选中第几个
    func tabBar(_ tabBar: TabBar, didSelectItemAt index: Int)
    
    ///是否可以选中
    func tabBar(_ tabBar: TabBar, shouldSelectItemAt index: Int) -> Bool
}

///选项卡
public class TabBar: UIView {
    
    ///选项卡按钮
    public var items: [TabBarItem]? {
        didSet{
            if items != oldValue {
                layoutItems()
            }
        }
    }
    
    ///背景视图 如果设置，大小会调节到选项卡的大小
    public var backgroundView: UIView? {
        didSet{
            if oldValue != backgroundView {
                oldValue?.removeFromSuperview()
                if let view = backgroundView {
                    view.insertSubview(view, at: 0)
                    view.snp.makeConstraints { (make) in
                        make.edges.equalTo(0)
                    }
                }
            }
        }
    }
    
    ///设置选中
    public var selectedIndex: Int = NSNotFound {
        didSet{
            if oldValue != selectedIndex {
                if let items = self.items {
                    if oldValue < items.count {
                        let item = items[oldValue]
                        item.backgroundColor = .clear
                        item.isSelected = false
                    }
                    
                    let item = items[selectedIndex]
                    item.isSelected = true
                    if selectedButtonBackgroundColor != nil {
                        item.backgroundColor = selectedButtonBackgroundColor
                    }
                    
                    delegate?.tabBar(self, didSelectItemAt: selectedIndex)
                }
            }
        }
    }
    
    ///选中按钮的背景颜色
    public var selectedButtonBackgroundColor: UIColor? {
        didSet{
            if oldValue != selectedButtonBackgroundColor {
                if let items = self.items, selectedIndex < items.count {
                    let item = items[selectedIndex]
                    item.backgroundColor = selectedButtonBackgroundColor
                }
            }
        }
    }
    
    ///分割线
    public let divider: Divider = Divider()
    
    ///代理
    public weak var delegate: TabBarDelegate?
    
    init(items: [TabBarItem]?) {
        super.init(frame: .zero)
        
        self.items = items
        backgroundColor = .white
        addSubview(divider)
        
        divider.snp.makeConstraints { (make) in
            make.leading.top.trailing.equalTo(0)
        }
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    /**
     设置选项卡边缘值
     
     @param badgeValue 边缘值
     @param index 下标
     */
    public func setBadgeValue(_ badgeValue: String?, for index: Int) {
        if let items = self.items {
            assert(index < items.count, "\(String(describing: self))setBadgeValue forIndex \(index) 越界")
            let item = items[index]
            item.badgeValue = badgeValue
        }
    }
    
    private func layoutItems() {
        //移除以前的item
        for view in subviews {
            if view != divider {
                view.removeFromSuperview()
            }
        }
        
        if let items = self.items {
            var beforeItem: TabBarItem? = nil
            let bottom = UIApplication.shared.delegate?.window??.gkSafeAreaInsets.bottom ?? 0
            
            for i in 0 ..< items.count {
                let item = items[i]
                item.addTarget(self, action: #selector(handleTap(_:)), for: .touchUpInside)
                insertSubview(item, belowSubview: divider)
                
                item.snp.makeConstraints { (make) in
                    make.top.equalTo(0)
                    make.bottom.equalTo(-bottom)
                    
                    if beforeItem != nil {
                        make.leading.equalTo(beforeItem!.snp.trailing)
                        make.width.equalTo(beforeItem!)
                    } else {
                        make.leading.equalTo(0)
                    }
                    
                    if i == items.count - 1 {
                        make.trailing.equalTo(0)
                    }
                }
                beforeItem = item
            }
        }
    }
    
    // MARK: - Action
    
    //选中某个按钮
    @objc private func handleTap(_ item: TabBarItem) {
        if item.isSelected {
            return
        }
        
        if let index = items!.lastIndex(of: item) {
            let shouldSelect: Bool = delegate?.tabBar(self, shouldSelectItemAt: index) ?? true
            if shouldSelect {
                selectedIndex = index
            }
        }
    }
}
