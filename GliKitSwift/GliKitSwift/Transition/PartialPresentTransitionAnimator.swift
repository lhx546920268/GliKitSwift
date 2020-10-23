//
//  PartialPresentTransitionAnimator.swift
//  GliKitSwift
//
//  Created by 罗海雄 on 2020/1/22.
//  Copyright © 2020 luohaixiong. All rights reserved.
//

import UIKit

///部分展示过渡动画
open class PartialPresentTransitionAnimator: NSObject, UIViewControllerAnimatedTransitioning {
    
    ///关联的
    public var props: PartialPresentProps!
    
    init(props: PartialPresentProps) {
        self.props = props
    }
    
    public func transitionDuration(using transitionContext: UIViewControllerContextTransitioning?) -> TimeInterval {
        return props.transitionDuration
    }
    
    public func animateTransition(using transitionContext: UIViewControllerContextTransitioning) {
        
        if !transitionContext.isInteractive {
            let fromViewController = transitionContext.viewController(forKey: .from)
            let toViewController = transitionContext.viewController(forKey: .to)
            
            let containerView = transitionContext.containerView
            
            //是否是弹出
            let isPresenting = toViewController?.presentingViewController == fromViewController
            
            var view: UIView
            var fromCenter: CGPoint
            var toCenter: CGPoint
            let frame = props.frame
            
            var center: CGPoint
            switch props.transitionStyle {
                    
            case .fromTop :
                center = CGPoint(frame.midX, -frame.height / 2)
                
            case .fromBottom :
                center = CGPoint(frame.midX, containerView.gkBottom + frame.height / 2)
                
            case .fromLeft :
                center = CGPoint(-frame.width / 2, frame.midY)
                
            case .fromRight :
                center = CGPoint(containerView.gkRight + frame.width / 2, frame.midY)
            }
            
            if isPresenting {
                view = transitionContext.view(forKey: .to)!
                view.frame = frame
                fromCenter = center
                toCenter = view.center
                containerView.addSubview(view)
            }else{
                
                view = transitionContext.view(forKey: .from)!
                fromCenter = view.center
                toCenter = center
            }
            
            let keyPath = "position"
            CATransaction.begin()
            CATransaction.setCompletionBlock {
                view.layer.removeAnimation(forKey: keyPath)
                transitionContext.completeTransition(!transitionContext.transitionWasCancelled)
            }
            
            let animation = CABasicAnimation(keyPath: keyPath)
            animation.duration = transitionDuration(using: transitionContext)
            animation.isRemovedOnCompletion = false
            animation.fillMode = .both
            animation.timingFunction = CAMediaTimingFunction(controlPoints: 0, 0, 0.2, 1)
            
            animation.fromValue = fromCenter
            animation.toValue = toCenter
            view.layer.add(animation, forKey: keyPath)
            
            CATransaction.commit()
        }
    }
}
