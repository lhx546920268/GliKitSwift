//
//  UIViewController+SafeAreaCompatible.swift
//  GliKitSwift
//
//  Created by 罗海雄 on 2020/1/17.
//  Copyright © 2020 luohaixiong. All rights reserved.
//

import UIKit
import SnapKit

///安全区域兼容 iOS11
public extension UIViewController{
    
    ///安全区域 顶部
    var gkSafeAreaLayoutGuideTop: ConstraintItem{
        if #available(iOS 11, *) {
            return self.view.safeAreaLayoutGuide.snp.top
        }else{
            return self.topLayoutGuide.snp.bottom
        }
    }
    
    ///安全区域 底部
    var gkSafeAreaLayoutGuideBottom: ConstraintItem{
        if #available(iOS 11, *) {
            return self.view.safeAreaLayoutGuide.snp.bottom
        }else{
            return self.bottomLayoutGuide.snp.top
        }
    }

    ///安全区域 左边
    var gkSafeAreaLayoutGuideLeft: ConstraintItem{
        if #available(iOS 11, *) {
            return self.view.safeAreaLayoutGuide.snp.leading
        }else{
            return self.view.snp.leading
        }
    }

    ///安全区域 右边
    var gkSafeAreaLayoutGuideRight: ConstraintItem{
        if #available(iOS 11, *) {
            return self.view.safeAreaLayoutGuide.snp.trailing
        }else{
            return self.view.snp.trailing
        }
    }
}
