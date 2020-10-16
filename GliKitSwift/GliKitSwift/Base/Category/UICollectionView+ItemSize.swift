//
//  UICollectionView+ItemSize.swift
//  GliKitSwift
//
//  Created by 罗海雄 on 2020/10/16.
//  Copyright © 2020 luohaixiong. All rights reserved.
//

import UIKit

private var registerObjectsKey: UInt8 = 0
private var registerCellsKey: UInt8 = 0

///保存item大小的
public protocol ItemSizeModel: NSObjectProtocol {
    
    ///item大小
    var itemSize: CGSize?{
        get
        set
    }
}

///可配置的item
public protocol CollectionConfigurableItem where Self: UIView{
    
    ///对应的数据
    var model: ItemSizeModel?{
        get
        set
    }
}

public extension UICollectionView {
    
}
