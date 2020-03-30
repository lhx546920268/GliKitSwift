//
//  UIViewControlelr+Transition.swift
//  GliKitSwift
//
//  Created by 罗海雄 on 2020/1/22.
//  Copyright © 2020 luohaixiong. All rights reserved.
//

import UIKit

private var transitioningDelegateKey: UInt8 = 0
private var partialFrameKey: UInt8 = 0
private var partialFrameUseSafeAreaKey: UInt8 = 0

///视图过渡扩展
extension UIViewController {
    
    ///过渡动画代理 设置这个可防止 transitioningDelegate 提前释放，不要设置为 self，否则会抛出异常
    var gkTransitioningDelegate: UIViewControllerTransitioningDelegate? {
        set{
            assert(self.isEqual(newValue), "gkTransitioningDelegate 不能设置为self，如果要设置成self，使用 transitioningDelegate")
            objc_setAssociatedObject(self, &transitioningDelegateKey, gkTransitioningDelegate, .OBJC_ASSOCIATION_RETAIN_NONATOMIC);
            self.transitioningDelegate = gkTransitioningDelegate
        }
        get{
            objc_getAssociatedObject(self, &transitioningDelegateKey) as? UIViewControllerTransitioningDelegate
        }
    }

    // MARK: - Partial present

    ///部分显示区域 子类可重写
    open var partialFrame: CGRect {
        set{
            objc_setAssociatedObject(self, &partialFrameKey, newValue, .OBJC_ASSOCIATION_RETAIN_NONATOMIC)
        }
        get{
            objc_getAssociatedObject(self, &partialFrameKey) as? CGRect ?? CGRect.zero
        }
    }
    
    ///是否需要自动加上安全区域
    open var partialFrameUseSafeArea: Bool {
        set{
            objc_setAssociatedObject(self, &partialFrameUseSafeAreaKey, newValue, .OBJC_ASSOCIATION_RETAIN_NONATOMIC)
        }
        get{
            objc_getAssociatedObject(self, &partialFrameUseSafeAreaKey) as? Bool ?? true
        }
    }

    ///返回要显示的viewController 默认是self
    open var partialViewController: UIViewController{
        get{
            self
        }
    }

    ///从底部部分显示
    open func partialPresentFromBottom(){
        partialPresent(with: .fromBottom)
    }

    ///从顶部部分显示
    open func partialPresentFromTop(){
        partialPresent(with: .fromTop)
    }
    
    ///部分显示
    open func partialPresent(with animate: PartialPresentTransitionAnimate) {
        
        var frame = partialFrame
        if partialFrameUseSafeArea {
            
            switch animate {
            case .fromBottom :
                frame.size.height += self.view.gkSafeAreaInsets.bottom
                
            case .fromTop :
                frame.size.height += self.view.gkSafeAreaInsets.top
                
                case .fromLeft :
                frame.size.width += self.view.gkSafeAreaInsets.left
                
                case .fromRight :
                frame.size.width += self.view.gkSafeAreaInsets.right
            default:
                break
            }
        }
        let delegate = PartialPresentTransitionDelegate(frame: frame)
    }

    ///部分显示 可设置要显示的viewController、样式和大小
    - (void)partialPresentViewController:(UIViewController*) viewController style:(GKPresentTransitionStyle) style contentSize:(CGSize) contentSize;
    
    - (void)partialPresentFromBottom
    {
        CGSize size = self.partialContentSize;
        size.height += self.gkCurrentViewController.view.gkSafeAreaInsets.bottom;
        [self partialPresentWithStyle:GKPresentTransitionStyleCoverVerticalFromBottom contentSize:size];
    }

    - (void)partialPresentFromTop
    {
        CGSize size = self.partialContentSize;
        size.height += self.gkStatusBarHeight;
        [self partialPresentWithStyle:GKPresentTransitionStyleCoverVerticalFromTop contentSize:size];
    }

    - (void)partialPresentWithStyle:(GKPresentTransitionStyle) style contentSize:(CGSize) contentSize
    {
        [self partialPresentViewController:self.partialViewController style:style contentSize:contentSize];
    }

    - (void)partialPresentViewController:(UIViewController*) viewController style:(GKPresentTransitionStyle) style contentSize:(CGSize) contentSize
    {
        GKPartialPresentTransitionDelegate *delegate = [GKPartialPresentTransitionDelegate new];
        delegate.transitionStyle = style;
        delegate.partialContentSize = contentSize;
        [delegate showViewController:viewController];
    }
}
