//
//  UIViewController+EmptyView.swift
//  GliKitSwift
//
//  Created by 罗海雄 on 2020/4/23.
//  Copyright © 2020 luohaixiong. All rights reserved.
//

import UIKit

///空视图相关扩展
public extension UIViewController {

    ///空视图
    var gkEmptyView: EmptyView?{
        get{
            return self.view.gkEmptyView
        }
    }

    ///设置显示空视图
    var gkShowEmptyView: Bool{
        set{
            self.view.gkShowEmptyView = newValue
        }
        get{
            self.view.gkShowEmptyView
        }
    }
}
