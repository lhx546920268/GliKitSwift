//
//  SkeletonLayer.swift
//  GliKitSwift
//
//  Created by 罗海雄 on 2020/10/21.
//  Copyright © 2020 luohaixiong. All rights reserved.
//

import UIKit

///骨架图层
public class SkeletonLayer : CALayer {

    ///骨架背景
    public var skeletonBackgroundColor: UIColor = UIColor.gkSkeletonBackgroundColor
    
    ///设置骨架子图层
    public var skeletonSubLayers: NSArray? {
        didSet{
            if oldValue != skeletonSubLayers {
                if let layers = oldValue {
                    for layer in layers {
                        (layer as! CALayer).removeFromSuperlayer()
                    }
                }
                
                if let layers = skeletonSubLayers {
                    for layer in layers {
                        let layer = layer as! CALayer
                        layer.backgroundColor = skeletonBackgroundColor.cgColor
                        addSublayer(layer)
                    }
                }
            }
        }
    }
}
