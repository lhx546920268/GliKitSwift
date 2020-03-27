//
//  UIViewController+Dialog.swift
//  GliKitSwift
//
//  Created by 罗海雄 on 2020/3/25.
//  Copyright © 2020 luohaixiong. All rights reserved.
//

import UIKit

/**
弹窗扩展
如果 UIViewController 是 GKBaseViewController 或者其子类，并且没有使用xib，dialog属性将自动设置为 GKContainer
此时 self.view 将不再是 GKContainer，要设置 container的大小和位置
*/
public extension UIViewController{
    
    ///是否以弹窗的样式显示 default is 'NO'
    var isShowAsDialog: Bool{
        get{
            return false
        }
    }
}
