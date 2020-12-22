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
                toCenter = view.center
                
                view.bounds = CGRect(0, 0, frame.width, frame.height)
                view.center = center
                containerView.addSubview(view)
            }else{
                
                view = transitionContext.view(forKey: .from)!
                toCenter = center
            }
            
            UIView.animate(withDuration: props.transitionDuration,
                           delay: 0,
                           usingSpringWithDamping: 1.0,
                           initialSpringVelocity: 0,
                           options: .beginFromCurrentState) {
                view.center = toCenter
            } completion: { (_) in
                transitionContext.completeTransition(!transitionContext.transitionWasCancelled)
            }
        }
    }
}
