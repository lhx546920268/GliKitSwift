//
//  PartialPresentTransitionDelegate.swift
//  GliKitSwift
//
//  Created by 罗海雄 on 2020/1/22.
//  Copyright © 2020 luohaixiong. All rights reserved.
//

import UIKit

///动画方式
public enum PartialPresentTransitionStyle {
    
    ///从底部进入
    case fromBottom
    
    ///从顶部进入
    case fromTop
    
    ///从左边进入
    case fromLeft
    
    ///从右边进入
    case fromRight
}

///
open class PartialPresentProps{
    
    ///部分显示大小
    public var contentSize = CGSize.zero

    ///部分显示区域 默认通过 contentSize 和动画样式计算
    private var _frame = CGRect.zero
    public var frame: CGRect{
        set{
            _frame = newValue
        }
        get{
            if _frame.size.width > 0 && _frame.size.height > 0 {
                return _frame
            }
            
            //弹窗大小位置
            var size = contentSize
            let parentSize = UIScreen.gkSize
            switch (transitionStyle) {
            case .fromTop :
                if frameUseSafeArea, let window = UIApplication.shared.keyWindow {
                    size.height += window.gkSafeAreaInsets.top
                }
                return CGRect(x: (parentSize.width - size.width) / 2.0, y: 0, width: size.width, height: size.height)
                
            case .fromLeft :
                if frameUseSafeArea, let window = UIApplication.shared.keyWindow {
                    size.width += window.gkSafeAreaInsets.left
                }
                return CGRect(x: size.width, y: (parentSize.height - size.height) / 2.0, width: size.width, height: size.height)
                
            case .fromBottom :
                if frameUseSafeArea, let window = UIApplication.shared.keyWindow {
                    size.height += window.gkSafeAreaInsets.bottom
                }
                return CGRect(x: (parentSize.width - size.width) / 2.0, y: parentSize.height - size.height, width: size.width, height: size.height)
                
            case .fromRight :
                if self.frameUseSafeArea, let window = UIApplication.shared.keyWindow {
                    size.width += window.gkSafeAreaInsets.right
                }
                return CGRect(x: parentSize.width - size.width, y: (parentSize.height - size.height) / 2.0, width: size.width, height: size.height)
            }
        }
    }

    ///是否需要自动加上安全区域
    public var frameUseSafeArea = true

    ///圆角
    public var cornerRadius: CGFloat = 0

    ///圆角位置 默认是左上角和右上角
    public var corners: UIRectCorner = [.topLeft, .topRight]

    ///样式
    public var transitionStyle: PartialPresentTransitionStyle = .fromBottom

    ///背景颜色
    public var backgroundColor = UIColor(white: 0, alpha: 0.5)

    ///点击背景是否会关闭当前显示的viewController
    public var cancelable = true

    ///动画时间
    public var transitionDuration: TimeInterval = 0.25

    ///点击半透明背景回调 设置这个时，弹窗不会关闭
    public var cancelCallback: (() -> Void)?

    ///消失时的回调
    public var dismissCallback: (() -> Void)?
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
    
    ///部分显示属性
    public var props: PartialPresentProps!
    
    ///动画
    private lazy var animator: UIViewControllerAnimatedTransitioning = {
       
        return PartialPresentTransitionAnimator(props: self.props)
    }()
    
    public init(props: PartialPresentProps) {
        self.props = props
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

    ///显示一个 视图
    public func show(_ viewController: UIViewController, completion: (() -> Void)? = nil){
        
        if viewController.presentingViewController != nil {
            return
        }

        viewController.gkTransitioningDelegate = self
        if let rootViewController = UIApplication.shared.delegate?.window??.rootViewController {
            rootViewController.gkTopestPresentedViewController.present(viewController, animated: true, completion: completion)
        }
    }
}
