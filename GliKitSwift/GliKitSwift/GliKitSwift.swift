//
//  GliKitSwift.swift
//  GliKitSwift
//
//  Created by 罗海雄 on 2020/1/16.
//  Copyright © 2020 luohaixiong. All rights reserved.
//

import UIKit

public typealias VoidCallback = () -> Void

public class GliKitSwift {

    ///初始化 只调用一次
    public class func initialize(){
        DispatchQueue.once(token: "GliKitSwift.initialize"){
            UIView.swizzleNavigationBarMargins()
            UITableView.swizzleTableViewRowHeight()
            UICollectionView.swizzleCollectionViewItemSize()
            UIViewController.swizzleForDialog()
            UIView.swizzleSkeletonMethod()
            UIScrollView.swizzleNestedScrollMethod()
        }
    }
}



