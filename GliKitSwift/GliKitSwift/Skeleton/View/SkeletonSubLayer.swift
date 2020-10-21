//
//  SkeletonSubLayer.swift
//  GliKitSwift
//
//  Created by 罗海雄 on 2020/10/21.
//  Copyright © 2020 luohaixiong. All rights reserved.
//

import UIKit

///骨架子图层
public class SkeletonSubLayer : CALayer {
    
    ///复制属性
    public func copyProperties(from layer: CALayer) {
        cornerRadius = layer.cornerRadius
        masksToBounds = layer.masksToBounds
    }
}
