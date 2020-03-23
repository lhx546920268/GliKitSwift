//
//  NavigationItemHelper.swift
//  GliKitSwift
//
//  Created by 罗海雄 on 2020/3/20.
//  Copyright © 2020 luohaixiong. All rights reserved.
//

import UIKit

///导航栏item帮助类
open class NavigationItemHelper {
    
    ///关联的viewController
    public private(set) weak var viewController: BaseViewController?

    ///标题
    public var title: String?
    public var viewControllerTitle: String?
    public var titleView: UIView?

    //返回按钮
    public var backBarButtonItem: UIBarButtonItem?
    public var hidesBackButton = false

    ///左边item
    public var leftBarButtonItem: UIBarButtonItem?
    public var leftBarButtonItems: [UIBarButtonItem]?

    ///右边item
    public var rightBarButtonItem: UIBarButtonItem?
    public var rightBarButtonItems: [UIBarButtonItem]?

    ///设置导航栏隐藏item
    public var hiddenItem = false{
        didSet{
            if oldValue != self.hiddenItem {
                
            }
        }
    }

    ///通过viewController 构建
    init(viewController: BaseViewController?) {
        self.viewController = viewController
    }

    ///隐藏并且保存item的状态
    func hideAndSaveItem(){
        
        if let vc = self.viewController {
            let item = vc.navigationItem
            
            self.title = item.title
            self.viewControllerTitle = vc.title
            self.titleView = item.titleView
            
            self.backBarButtonItem = item.backBarButtonItem
            self.hidesBackButton = item.hidesBackButton
            
            self.leftBarButtonItem = item.leftBarButtonItem
            self.leftBarButtonItems = item.leftBarButtonItems
            
            self.rightBarButtonItem = item.rightBarButtonItem
            self.rightBarButtonItems = item.rightBarButtonItems
            
            vc.title = nil
            item.title = nil
            item.titleView = nil
            
            item.backBarButtonItem = nil
            item.hidesBackButton = true
            
            item.leftBarButtonItem = nil
            item.leftBarButtonItems = nil
            
            item.rightBarButtonItem = nil
            item.rightBarButtonItems = nil
        }
    }

    ///恢复上一次保存的item
    func restoreItem(){
        
        if let vc = self.viewController {
            let item = vc.navigationItem
            
            vc.title = self.viewControllerTitle
            item.title = self.title
            item.titleView = self.titleView
            
            item.backBarButtonItem = self.backBarButtonItem
            item.hidesBackButton = self.hidesBackButton
            
            if (leftBarButtonItems?.count ?? 0) > 0 {
                item.leftBarButtonItems = self.leftBarButtonItems
            }else{
                item.leftBarButtonItem = self.leftBarButtonItem
            }
            
            if (rightBarButtonItems?.count ?? 0) > 0{
                item.rightBarButtonItems = self.rightBarButtonItems
            }else{
                item.rightBarButtonItem = self.rightBarButtonItem
            }
        }
    }
}
