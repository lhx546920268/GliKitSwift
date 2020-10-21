//
//  GKSkeletonAnimationHelper.swift
//  GliKitSwift
//
//  Created by 罗海雄 on 2020/10/21.
//  Copyright © 2020 luohaixiong. All rights reserved.
//

import UIKit

///骨架动画帮助类
class SkeletonAnimationHelper: NSObject, CAAnimationDelegate {
    
    ///动画完成回调
    public var completion: VoidCallback?
    
    ///执行透明度渐变动画
    public func executeOpacityAnimation(for layer: CALayer, completion: VoidCallback?) {
        self.completion = completion
        let animation = CABasicAnimation(keyPath: "opacity")
        animation.fromValue = 1.0
        animation.toValue = 0.0
        animation.duration = 0.25
        animation.timingFunction = CAMediaTimingFunction(name: .easeInEaseOut)
        animation.delegate = self
        animation.fillMode = .forwards
        animation.isRemovedOnCompletion = false
        layer.add(animation, forKey: "opacity")
    }
    
    func animationDidStop(_ anim: CAAnimation, finished flag: Bool) {
        completion?()
        completion = nil
    }
}
