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
    public weak var transitionDelegate: PartialPresentTransitionDelegate?
    
    public func transitionDuration(using transitionContext: UIViewControllerContextTransitioning?) -> TimeInterval {
        return transitionDelegate?.animateDuration ?? 0
    }
    
    public func animateTransition(using transitionContext: UIViewControllerContextTransitioning) {
        
        UIView.animate(withDuration: transitionDuration(using: transitionContext),
                       animations: animations(using: transitionContext)) { _ in
            
            transitionContext.completeTransition(true)
        }
    }
    
    ///获取对应的动画
    private func animations(using transitionContext: UIViewControllerContextTransitioning) -> (() -> Void) {
        
        if let delegate = transitionDelegate {
            
            if delegate.animate == .custom {
                if delegate.customAnimate != nil {
                    return delegate.customAnimate!(transitionContext)
                } else {
                    GKLog("customAnimate must not be nil")
                }
            } else {
                
                let fromViewController = transitionContext.viewController(forKey: .from)
                let toViewController = transitionContext.viewController(forKey: .to)
                
                let containerView = transitionContext.containerView;

                //是否是弹出
                let isPresenting = toViewController?.presentingViewController == fromViewController

                
                if isPresenting {
                    if let toView = transitionContext.view(forKey: .to) {
                        
                        var frame = delegate.frame
                        switch delegate.animate {
                        case .fromBottom :
                            
                            frame.origin.y = containerView.gkHeight
                        case .fromTop :
                            
                            frame.origin.y = -frame.size.height
                        case .fromLeft :
                            
                            frame.origin.x = -frame.size.width
                        case .fromRight :
                            
                            frame.origin.x = containerView.gkWidth
                        default:
                            break
                        }
                        
                        toView.frame = frame
                        return {
                            toView.frame = delegate.frame
                        }
                    }
                } else {
                    
                    if let fromView = transitionContext.view(forKey: .from) {
                        
                        var frame = fromView.frame
                        switch delegate.animate {
                        case .fromBottom :
                            
                            frame.origin.y = containerView.gkHeight
                        case .fromTop :
                            
                            frame.origin.y = -frame.size.height
                        case .fromLeft :
                            
                            frame.origin.x = -frame.size.width
                        case .fromRight :
                            
                            frame.origin.x = containerView.gkWidth
                        default:
                            break
                        }
                        
                        return {
                            fromView.frame = frame
                        }
                    }
                }
            }
        }
        return {}
    }
}
