//
//  UIView+Utils.swift
//  GliKitSwift
//
//  Created by 罗海雄 on 2020/1/22.
//  Copyright © 2020 luohaixiong. All rights reserved.
//

import UIKit

public extension UIView {
    
   
     //通过xib加载 xib的名称必须和类的名称一致
    static func loadFromNib<T: UIView>() -> T?{
        
        return Bundle.main.loadNibNamed(self.gkNameOfClass, owner: nil, options: nil)?.last as? T
    }
    
    ///删除所有子视图
    func gkRemoveAllSubviews() {
        for view in subviews {
            view.removeFromSuperview()
        }
    }

    /**
     安全区域 兼容ios 11
     */
    var gkSafeAreaInsets: UIEdgeInsets {
        if #available(iOS 11, *) {
            
            return self.safeAreaInsets
        } else {
            
            return UIEdgeInsets.zero
        }
    }
}
