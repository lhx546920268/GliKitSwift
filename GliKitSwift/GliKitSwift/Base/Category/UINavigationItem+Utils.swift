//
//  UINavigationItem+Utils.swift
//  GliKitSwift
//
//  Created by 罗海雄 on 2020/4/23.
//  Copyright © 2020 luohaixiong. All rights reserved.
//

import UIKit

///该类目主要是修正 ios11以下（不包括ios11) 导航栏左右按钮与边框的间距
internal extension UINavigationItem {

    static func swizzleNavigationItemMargins(){
        
        if UIDevice.current.systemVersion.floatValue < 11 {
            
            let selecotrs: [Selector] = [
            #selector(setLeftBarButton(_:animated:)),
            #selector(setLeftBarButtonItems(_:animated:)),
            #selector(getter: leftBarButtonItem),
            #selector(getter: leftBarButtonItems),
            
            #selector(setRightBarButton(_:animated:)),
            #selector(setRightBarButtonItems(_:animated:)),
            #selector(getter: rightBarButtonItem),
            #selector(getter: rightBarButtonItems),
            ]
            
            for selector in selecotrs {
                swizzling(selector1: selector, selector2: Selector("gk_\(NSStringFromSelector(selector))"), cls1: self)
            }
        }
    }

    func gk_setLeftBarButton(_ item: UIBarButtonItem?, animated: Bool){
        
        if item != nil {
            //只有当 item是自定义item 和 图标，系统item 才需要修正
            let fixedItem = self.fixedBarButtonItem
            if shouldFixBarButtonItem(item!) {
                fixedItem.width -= 8
            }
            gk_setLeftBarButtonItems([fixedItem, item!], animated: animated)
        } else {
            setLeftBarButton(item, animated: animated)
        }
    }
    
    func gk_setLeftBarButtonItems(_ items: [UIBarButtonItem]?, animated: Bool){
        
        if var leftBarButtonItems = items, leftBarButtonItems.count > 0 {
            
            let item = leftBarButtonItems.first!
            let fixedItem = self.fixedBarButtonItem
            
            //只有当第一个 item是自定义item 和 图标，系统item 才需要修正
            if shouldFixBarButtonItem(item) {
                fixedItem.width += 8;
            }
            leftBarButtonItems.insert(fixedItem, at: 0)
            gk_setLeftBarButtonItems(leftBarButtonItems, animated: animated)
        } else {
            gk_setLeftBarButtonItems(items, animated: animated)
        }
    }
    
    func gk_setRightBarButton(_ item: UIBarButtonItem?, animated: Bool){
        
        if item != nil {
            
            let fixedItem = self.fixedBarButtonItem
            
            //只有当 item是自定义item 和 图标，系统item 才需要修正
            if shouldFixBarButtonItem(item!) {
                fixedItem.width += 8
            }
            gk_setRightBarButtonItems([fixedItem, item!], animated: animated)
        } else {
            gk_setRightBarButton(item, animated: animated)
        }
    }
    
    func gk_setRightBarButtonItems(_ items: [UIBarButtonItem]?, animated: Bool){
        
        if var rightBarButtonitems = items, rightBarButtonitems.count > 0 {
            
            let item = rightBarButtonitems.first!
            let fixedItem = self.fixedBarButtonItem
            
            //只有当第一个 item是自定义item 和 图标，系统item 才需要修正
            if shouldFixBarButtonItem(item) {
                fixedItem.width += 8;
            }
            rightBarButtonitems.insert(fixedItem, at: 0)
            gk_setRightBarButtonItems(rightBarButtonitems, animated: animated)
        } else {
            gk_setRightBarButtonItems(items, animated: animated)
        }
    }
    
    ///获取修正间距的item
    var fixedBarButtonItem: UIBarButtonItem{
        get{
            let item = UIBarButtonItem(barButtonSystemItem: .fixedSpace, target: nil, action: nil)
            item.width = UIScreen.main.scale == 2 ? -16 : -20
            return item
        }
    }
    
    ///判断是否需要修正
    func shouldFixBarButtonItem(_ item: UIBarButtonItem) -> Bool {
        return !(item.customView != nil || item.image != nil || isSystemItem(item))
    }
    
    ///判断是否是system item
    func isSystemItem(_ item: UIBarButtonItem) -> Bool {
        return item.width == 0 && item.image == nil && item.customView == nil && item.title == nil
    }
    
    // MARK: - getter
    
    func gk_leftBarButtonItem() -> UIBarButtonItem?{
        
        if let items = self.leftBarButtonItems, items.count > 1 {
            return items.last
        } else {
            return gk_leftBarButtonItem()
        }
    }
    
    func gk_leftBarButtonItems() -> [UIBarButtonItem]?{
        
        var items = self.gk_leftBarButtonItems()
        if items != nil && items!.count > 1 {
            let item = items!.first!
            if item.width > 0 {
                items!.remove(at: 0)
                return items
            }
        }
        
        return items
    }
    
    func gk_rightBarButtonItem() -> UIBarButtonItem?{
        
        if let items = self.rightBarButtonItems, items.count > 1 {
            return items.last
        } else {
            return gk_rightBarButtonItem()
        }
    }
    
    func gk_rightBarButtonItems() -> [UIBarButtonItem]?{
        
        var items = self.gk_rightBarButtonItems()
        if items != nil && items!.count > 1 {
            let item = items!.first!
            if item.width > 0 {
                items!.remove(at: 0)
                return items
            }
        }
        
        return items
    }
}
