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
        
        UIView.animate(withDuration: transitionDuration(using: transitionContext),
                       animations: animations(using: transitionContext)) { _ in
                        
                        transitionContext.completeTransition(true)
        }
    }
    
    ///获取对应的动画
    private func animations(using transitionContext: UIViewControllerContextTransitioning) -> (() -> Void) {
        
        let fromViewController = transitionContext.viewController(forKey: .from)
        let toViewController = transitionContext.viewController(forKey: .to)
        
        let containerView = transitionContext.containerView;
        
        //是否是弹出
        let isPresenting = toViewController?.presentingViewController == fromViewController
        
        let frame = props.frame
        if isPresenting {
            if let toView = transitionContext.view(forKey: .to) {
                
                switch props.transitionStyle {
                    
                case .fromTop :
                    toView.frame = frame.offsetBy(dx: 0, dy: -frame.maxY)
                    
                case .fromBottom :
                    toView.frame = frame.offsetBy(dx: 0, dy: frame.maxY)
                    
                case .fromLeft :
                    toView.frame = frame.offsetBy(dx: -frame.maxX, dy: 0)
                    
                case .fromRight :
                    toView.frame = frame.offsetBy(dx: frame.maxX, dy: 0)
                }
                
                containerView.addSubview(toView)
                
                return {
                    toView.frame = frame
                }
            }
        } else {
            
            if let fromView = transitionContext.view(forKey: .from) {
                
                var fromFrame = fromView.frame
                switch props.transitionStyle {
                    
                case .fromTop :
                    fromFrame = frame.offsetBy(dx: 0, dy: -frame.maxY)
                    
                case .fromBottom :
                    fromFrame = frame.offsetBy(dx: 0, dy: frame.maxY)
                    
                case .fromLeft :
                    fromFrame = frame.offsetBy(dx: -frame.maxX, dy: 0)
                    
                case .fromRight :
                    fromFrame = frame.offsetBy(dx: frame.maxX, dy: 0)
                }
                
                return {
                    fromView.frame = fromFrame
                }
            }
        }
        return {}
    }
}
