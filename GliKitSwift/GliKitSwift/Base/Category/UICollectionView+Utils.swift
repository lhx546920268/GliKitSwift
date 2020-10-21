//
//  UICollectionView+Utils.swift
//  GliKitSwift
//
//  Created by 罗海雄 on 2020/4/8.
//  Copyright © 2020 luohaixiong. All rights reserved.
//

import UIKit

///方便的注册 cell reuseIdentifierd都是类的名称
public extension UICollectionView {

    func registerNib(_ cls: AnyClass){
        
        let name = String(describing: cls)
        register(UINib(nibName: name, bundle: nil), forCellWithReuseIdentifier: name)
    }

    func registerClass(_ cls: AnyClass){
        register(cls, forCellWithReuseIdentifier: String(describing: cls))
    }

    func registerHeaderClass(_ cls: AnyClass){
        register(cls, forSupplementaryViewOfKind: UICollectionView.elementKindSectionHeader, withReuseIdentifier: String(describing: cls))
    }

    func registerHeaderNib(_ cls: AnyClass){
        
        let name = String(describing: cls)
        register(UINib(nibName: name, bundle: nil), forSupplementaryViewOfKind: UICollectionView.elementKindSectionHeader, withReuseIdentifier: name)
    }

    func registerFooterClass(_ cls: AnyClass){
        register(cls, forSupplementaryViewOfKind: UICollectionView.elementKindSectionFooter, withReuseIdentifier: String(describing: cls))
    }

    func registerFooterNib(_ cls: AnyClass){
        
        let name = String(describing: cls)
        register(UINib(nibName: name, bundle: nil), forSupplementaryViewOfKind: UICollectionView.elementKindSectionFooter, withReuseIdentifier: name)
    }
}
