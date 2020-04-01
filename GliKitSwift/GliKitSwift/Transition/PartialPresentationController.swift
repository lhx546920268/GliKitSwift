//
//  PartialPresentationController.swift
//  GliKitSwift
//
//  Created by 罗海雄 on 2020/1/22.
//  Copyright © 2020 luohaixiong. All rights reserved.
//

import UIKit

///部分显示
open class PartialPresentationController: UIPresentationController, UIGestureRecognizerDelegate {
    
    ///关联的
    public weak var transitionDelegate: PartialPresentTransitionDelegate?
    
    ///背景视图
    public private(set) lazy var backgroundView: UIView = {
        
        let view = UIView()
        view.backgroundColor = transitionDelegate?.props.backgroundColor
        
        let tap = UITapGestureRecognizer(target: self, action: #selector(self.handleTap))
        tap.delegate = self
        view.addGestureRecognizer(tap)
        
        return view
    }()
    
    open override func presentationTransitionWillBegin() {
        
        //添加背景
        if backgroundView.superview == nil {
            self.containerView?.addSubview(backgroundView)
            
            backgroundView.snp.makeConstraints { (maker) in
                maker.edges.equalTo(0)
            }
        }
        
        //背景渐变动画
        backgroundView.alpha = 0
        self.presentedViewController.transitionCoordinator?.animate(alongsideTransition: { _ in
            
            self.backgroundView.alpha = 1.0
        }, completion: nil)
    }
    
    open override func presentationTransitionDidEnd(_ completed: Bool) {
        
        //如果展示过程被中断了，移除背景
        if !completed {
            backgroundView.removeFromSuperview()
        }
    }

    open override func dismissalTransitionWillBegin() {
        
        //背景渐变
        self.presentedViewController.transitionCoordinator?.animate(alongsideTransition: { _ in
            
            self.backgroundView.alpha = 0
        }, completion: nil)
    }

    open override func dismissalTransitionDidEnd(_ completed: Bool) {
        
        //界面被关闭了，移除背景
        if completed {
            backgroundView.removeFromSuperview()
        }else{
            self.backgroundView.alpha = 1.0
        }
    }

    open override var shouldPresentInFullscreen: Bool{
        get{
            false
        }
    }
    
    open override var shouldRemovePresentersView: Bool{
        get{
            false
        }
    }

    open override func containerViewDidLayoutSubviews() {
        
        //系统还会调整视图大小的，所以这里要设置成我们需要的大小
        self.presentedView?.frame = self.frameOfPresentedViewInContainerView
    }
    
    open override var frameOfPresentedViewInContainerView: CGRect{
        get{
            //弹窗大小位置
            transitionDelegate?.props.frame ?? CGRect.zero
        }
    }

    // MARK: - Action

    ///点击背景
    @objc private func handleTap()
    {
        if let delegate = transitionDelegate {
            
            if delegate.props.cancelCallback != nil {
                delegate.props.cancelCallback!()
            } else {
                if delegate.props.cancelable {
                    self.presentedViewController.dismiss(animated: true, completion: delegate.props.dismissCallback)
                }
            }
        }
    }

    // MARK: - UIGestureRecognizerDelegate

    public func gestureRecognizerShouldBegin(_ gestureRecognizer: UIGestureRecognizer) -> Bool {
        
        let point = gestureRecognizer.location(in: gestureRecognizer.view)
        
        return !self.presentedViewController.view.frame.contains(point)
    }
}