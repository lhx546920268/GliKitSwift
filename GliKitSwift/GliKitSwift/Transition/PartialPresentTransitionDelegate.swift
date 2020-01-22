//
//  PartialPresentTransitionDelegate.swift
//  GliKitSwift
//
//  Created by 罗海雄 on 2020/1/22.
//  Copyright © 2020 luohaixiong. All rights reserved.
//

import UIKit

///动画方式
public enum PartialPresentTransitionAnimate {
    
    ///没动画
    case none
    
    ///从底部进入
    case fromBottom
    
    ///从顶部进入
    case fromTop
    
    ///从左边进入
    case fromLeft
    
    ///从右边进入
    case fromRight
    
    ///自定义动画 要设置动画回调
    case custom
}

/*
 ViewController 部分显示
 
 使用方法
 
 UIViewController *vc = [UIViewController new];
 vc.navigationItem.title = sender.currentTitle;
 vc.view.backgroundColor = UIColor.whiteColor;
 
 UINavigationController *nav = [[UINavigationController alloc] initWithRootViewController:vc];
 nav.partialContentSize = CGSizeMake(UIScreen.gkScreenWidth, 400);
 [nav partialPresentFromBottom];
 */
open class PartialPresentTransitionDelegate: NSObject, UIViewControllerTransitioningDelegate {
    
    ///部分显示区域
    public var frame: CGRect
    
    ///背景颜色
    public var backgroundColor = UIColor(white: 0, alpha: 0.5)
    
    ///点击背景是否会关闭当前显示的viewController
    public var dismissWhenTapBackground = true
    
    ///动画时间
    public var animateDuration: TimeInterval = 0.25
    
    ///动画样式 default is 'GKPresentTransitionStyleCoverVerticalFromBottom'
    public var animate: PartialPresentTransitionAnimate = .fromBottom
    
    ///自定义动画回调
    public var customAnimate: ((UIViewControllerContextTransitioning) -> (() -> Void))?
    
    ///点击半透明背景回调 设置这个时，弹窗不会关闭
    public var tapBackgroundCallback: ((PartialPresentTransitionDelegate) -> Void)?
    
    ///消失时的回调
    public var dismissCallback: (() -> Void)?
    
    ///动画
    private lazy var animator: UIViewControllerAnimatedTransitioning = {
       
        let animator = PartialPresentTransitionAnimator()
        animator.transitionDelegate = self
        return animator
    }()
    
    public init(frame: CGRect) {
        self.frame = frame
        super.init()
    }
    
    // MARK: - UIViewControllerTransitioningDelegate
    
    public func animationController(forPresented presented: UIViewController, presenting: UIViewController, source: UIViewController) -> UIViewControllerAnimatedTransitioning? {
        return animator
    }
    
    public func animationController(forDismissed dismissed: UIViewController) -> UIViewControllerAnimatedTransitioning? {
        return animator
    }

    public func presentationController(forPresented presented: UIViewController, presenting: UIViewController?, source: UIViewController) -> UIPresentationController? {
        
        let controller = PartialPresentationController(presentedViewController: presented, presenting: presenting)
        controller.transitionDelegate = self
        
        return controller
    }


    - (void)showViewController:(UIViewController *)viewController
    {
        viewController.gkTransitioningDelegate = self;
        [UIApplication.sharedApplication.delegate.window.rootViewController.gkTopestPresentedViewController presentViewController:viewController animated:YES completion:nil];
    }

}
