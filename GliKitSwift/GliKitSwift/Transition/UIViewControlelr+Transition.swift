//
//  UIViewControlelr+Transition.swift
//  GliKitSwift
//
//  Created by 罗海雄 on 2020/1/22.
//  Copyright © 2020 luohaixiong. All rights reserved.
//

import UIKit

private var transitioningDelegateKey: UInt8 = 0
private var partialPresentPropsKey: UInt8 = 0

///视图过渡扩展
extension UIViewController {
    
    ///过渡动画代理 设置这个可防止 transitioningDelegate 提前释放，不要设置为 self，否则会抛出异常
    var gkTransitioningDelegate: UIViewControllerTransitioningDelegate? {
        set{
            assert(!self.isEqual(newValue), "gkTransitioningDelegate 不能设置为self，如果要设置成self，使用 transitioningDelegate")
            objc_setAssociatedObject(self, &transitioningDelegateKey, newValue, .OBJC_ASSOCIATION_RETAIN_NONATOMIC);
            self.transitioningDelegate = newValue
        }
        get{
            objc_getAssociatedObject(self, &transitioningDelegateKey) as? UIViewControllerTransitioningDelegate
        }
    }

    // MARK: - Partial present

    ///部分显示 属性
    open var partialPresentProps: PartialPresentProps {
        var props = objc_getAssociatedObject(self, &partialPresentPropsKey) as? PartialPresentProps
        if props == nil {
            props = PartialPresentProps()
            objc_setAssociatedObject(self, &partialPresentPropsKey, props, .OBJC_ASSOCIATION_RETAIN_NONATOMIC)
        }
        
        return props!
    }

    ///返回要显示的viewController 默认是self
    open var partialViewController: UIViewController{
        self
    }

    ///从底部部分显示
    open func partialPresentFromBottom(){
        partialPresentProps.transitionStyle = .fromBottom
        partialPresent()
    }

    ///从顶部部分显示
    open func partialPresentFromTop(){
        partialPresentProps.transitionStyle = .fromTop
        partialPresent()
    }
    
    ///部分显示
    open func partialPresent(with completion: (() -> Void)? = nil) {
        
        let viewController = partialViewController
        let props = partialPresentProps
   
        if(props.cornerRadius > 0){
            let frame = props.frame
            viewController.view.gkSetCornerRadius(props.cornerRadius, corners: props.corners, rect: CGRect(x: 0, y: 0, width: frame.width, height: frame.height))
        }
        
        let delegate = PartialPresentTransitionDelegate(props: props)
        delegate.show(viewController, completion: completion)
    }
}
