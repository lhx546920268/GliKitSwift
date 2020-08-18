//
//  UIViewController+Dialog.swift
//  GliKitSwift
//
//  Created by 罗海雄 on 2020/3/25.
//  Copyright © 2020 luohaixiong. All rights reserved.
//

import UIKit

public typealias DialogCompletion = () -> Void
public let dialogAnimationDuration: TimeInterval = 0.25

///弹窗动画类型
public enum DialogAnimate{
    
    ///无动画
    case none
    
    ///缩放
    case scale
    
    ///从上进入
    case fromTop
    
    ///从下进入
    case fromBottom
    
    ///自定义
    case custom
}

private var isShowAsDialogKey: UInt8 = 0
private var dialogKey: UInt8 = 0
private var dialogShouldUseNewWindowKey: UInt8 = 0
private var shouldDismissDialogOnTapTranslucentKey: UInt8 = 0
private var dialogBackgroundViewKey: UInt8 = 0
private var dialogShowAnimateKey: UInt8 = 0
private var dialogDismissAnimateKey: UInt8 = 0
private var isDialogShowingKey: UInt8 = 0
private var dialogShowCompletionKey: UInt8 = 0
private var dialogWillDismissCallbackKey: UInt8 = 0
private var dialogDismissCompletionKey: UInt8 = 0
private var dialogShouldAnimateKey: UInt8 = 0
private var tapDialogBackgroundGestureRecognizerKey: UInt8 = 0
private var isDialogViewDidLayoutSubviewsKey: UInt8 = 0
private var inPresentWayKey: UInt8 = 0

/**
 弹窗扩展
 如果 UIViewController 是 GKBaseViewController 或者其子类，并且没有使用xib，dialog属性将自动设置为 GKContainer
 此时 self.view 将不再是 GKContainer，要设置 container的大小和位置
 */
public extension UIViewController{
    
    ///是否以弹窗的样式显示
    private(set) var isShowAsDialog: Bool{
        set{
            objc_setAssociatedObject(self, &isShowAsDialogKey, newValue, .OBJC_ASSOCIATION_RETAIN_NONATOMIC)
        }
        get{
            objc_getAssociatedObject(self, &isShowAsDialogKey) as? Bool ?? false
        }
    }
    
    /**
     弹窗 子类可在 viewDidLoad中设置，设置后会不会自动添加到view中，要自己设置对应的约束
     如果 UIViewController 是 BaseViewController 或者其子类，并且没有使用xib，dialog属性将自动设置为 Container
     */
    var dialog: UIView?{
        set{
            if let vc = self as? BaseViewController {
                assert(vc.container == nil, "如果 UIViewController 是 BaseViewController 或者其子类，并且没有使用xib，dialog属性将自动设置为 Container")
            }
            objc_setAssociatedObject(self, &dialogKey, newValue, .OBJC_ASSOCIATION_RETAIN_NONATOMIC)
        }
        get{
            if let vc = self as? BaseViewController {
                if vc.container != nil {
                    return vc.container
                }
            }
            
            return objc_getAssociatedObject(self, &dialogKey) as? UIView
        }
    }
    
    ///是否使用新窗口显示 使用新窗口显示可以保证 弹窗始终显示在最前面 必须在 showAsDialog 前设置
    var dialogShouldUseNewWindow: Bool{
        set{
            objc_setAssociatedObject(self, &dialogShouldUseNewWindowKey, newValue, .OBJC_ASSOCIATION_RETAIN_NONATOMIC)
        }
        get{
            objc_getAssociatedObject(self, &dialogShouldUseNewWindowKey) as? Bool ?? false
        }
    }
    
    ///关联的窗口
    var dialogWindow: UIWindow?{
        get{
            if dialogShouldUseNewWindow {
                return UIApplication.shared.dialogWindow
            } else {
                return UIApplication.shared.delegate?.window as? UIWindow
            }
        }
    }
    
    ///是否要点击透明背景dismiss
    var shouldDismissDialogOnTapTranslucent: Bool{
        set{
            objc_setAssociatedObject(self, &shouldDismissDialogOnTapTranslucentKey, newValue, .OBJC_ASSOCIATION_RETAIN_NONATOMIC)
            
        }
        get{
            objc_getAssociatedObject(self, &shouldDismissDialogOnTapTranslucentKey) as? Bool ?? true
        }
    }
    
    ///背景视图
    var dialogBackgroundView: UIView?{
        set{
            objc_setAssociatedObject(self, &dialogBackgroundViewKey, newValue, .OBJC_ASSOCIATION_RETAIN_NONATOMIC)
        }
        get{
            objc_getAssociatedObject(self, &dialogBackgroundViewKey) as? UIView
        }
    }
    
    ///点击背景手势
    var tapDialogBackgroundGestureRecognizer: UITapGestureRecognizer{
        get{
            var tap = objc_getAssociatedObject(self, &tapDialogBackgroundGestureRecognizerKey) as? UITapGestureRecognizer
            if tap == nil {
                tap = UITapGestureRecognizer(target: self, action: #selector(dismissDialog))
                objc_setAssociatedObject(self, &tapDialogBackgroundGestureRecognizerKey, tap, .OBJC_ASSOCIATION_RETAIN_NONATOMIC)
            }
            
            return tap!
        }
    }
    
    ///弹窗是否需要动画
    private var dialogShouldAnimate: Bool{
        set{
            objc_setAssociatedObject(self, &dialogShouldAnimateKey, newValue, .OBJC_ASSOCIATION_RETAIN_NONATOMIC)
        }
        get{
            objc_getAssociatedObject(self, &dialogShouldAnimateKey) as? Bool ?? false
        }
    }
    
    ///出现动画
    var dialogShowAnimate: DialogAnimate{
        set{
            objc_setAssociatedObject(self, &dialogShowAnimateKey, newValue, .OBJC_ASSOCIATION_RETAIN_NONATOMIC)
        }
        get{
            objc_getAssociatedObject(self, &dialogShowAnimateKey) as? DialogAnimate ?? .none
        }
    }
    
    ///消失动画
    var dialogDismissAnimate: DialogAnimate{
        set{
            objc_setAssociatedObject(self, &dialogDismissAnimateKey, newValue, .OBJC_ASSOCIATION_RETAIN_NONATOMIC)
        }
        get{
            objc_getAssociatedObject(self, &dialogDismissAnimateKey) as? DialogAnimate ?? .none
        }
    }
    
    ///弹窗是否已显示
    private(set) var isDialogShowing: Bool{
        set{
            objc_setAssociatedObject(self, &isDialogShowingKey, newValue, .OBJC_ASSOCIATION_RETAIN_NONATOMIC)
        }
        get{
            objc_getAssociatedObject(self, &isDialogShowingKey) as? Bool ?? false
        }
    }
    
    ///显示动画完成回调
    var dialogShowCompletion: DialogCompletion?{
        set{
            objc_setAssociatedObject(self, &dialogShowCompletionKey, newValue, .OBJC_ASSOCIATION_RETAIN_NONATOMIC)
        }
        get{
            objc_getAssociatedObject(self, &dialogShowCompletionKey) as? DialogCompletion
        }
    }
    
    ///将要消失回调
    var dialogWillDismissCallback: ((_ animated: Bool) -> Void)?{
        set{
            objc_setAssociatedObject(self, &dialogWillDismissCallbackKey, newValue, .OBJC_ASSOCIATION_RETAIN_NONATOMIC)
        }
        get{
            objc_getAssociatedObject(self, &dialogWillDismissCallbackKey) as? (Bool) -> Void
        }
    }
    
    ///消失动画完成回调
    var dialogDismissCompletion: DialogCompletion?{
        set{
            objc_setAssociatedObject(self, &dialogDismissCompletionKey, newValue, .OBJC_ASSOCIATION_RETAIN_NONATOMIC)
        }
        get{
            objc_getAssociatedObject(self, &dialogDismissCompletionKey) as? DialogCompletion
        }
    }
    
    ///显示 如果 dialogShouldUseNewWindow，则在新的窗口上显示，否则在 window.rootViewController.topest 通过present方式显示
    func showAsDialog(){
        if self.dialogShouldUseNewWindow {
            if self.isDialogShowing {
                return
            }
            UIApplication.shared.loadDialogWindowIfNeeded()
            self.isShowAsDialog = true
            if let window = self.dialogWindow {
                if let rootViewController = window.rootViewController {
                    self.modalPresentationStyle = .custom
                    rootViewController.gkTopestPresentedViewController.present(self, animated: false, completion: self.dialogShowCompletion)
                } else {
                    window.rootViewController = self
                    self.dialogShowCompletion?()
                }
            }
        } else {
            if let rootViewController = UIApplication.shared.delegate?.window??.rootViewController {
                showAsDialog(in: rootViewController.gkTopestPresentedViewController)
            } else {
                fatalError("There is no rootViewController")
            }
        }
    }
    
    /// 在指定viewController 上显示
    /// - Parameters:
    ///   - viewController: 父视图容器
    ///   - isPresent: 是否通过present的方式显示，如果不是，则直接把弹窗加载 viewController.view上
    ///   - layoutCallback: 布局回调，如果不为空，则手动布局，否则 大小和viewController一样
    func showAsDialog(in viewController: UIViewController, isPresent: Bool = true, layoutCallback:((_ view: UIView, _ superview: UIView) -> Void)? = nil){
        
        if self.isDialogShowing {
            return
        }
        self.isShowAsDialog = true
        self.dialogShouldAnimate = true
        
        if isPresent {
            //设置使背景透明
            self.modalPresentationStyle = .custom
            viewController.present(self, animated: false, completion: self.dialogShowCompletion)
        } else {
            viewController.view.addSubview(self.view)
            viewController.addChild(self)
            if layoutCallback != nil {
                layoutCallback!(self.view, viewController.view)
            } else {
                self.view.snp.makeConstraints { (make) in
                    make.edges.equalTo(0)
                }
            }
            self.dialogShowCompletion?()
        }
    }
    
    // MARK: - 动画
    
    ///执行出场动画
    private func executeShowAnimate() {
        //出场动画
        if let dialog = self.dialog, self.isDialogViewDidLayoutSubviews {
            if self.dialogShouldAnimate {
                self.dialogShouldAnimate = false
                
                switch self.dialogShowAnimate {
                case .none :
                    self.dialogBackgroundView?.alpha = 1
                    
                case .scale :
                    dialog.alpha = 0
                    UIView.animate(withDuration: dialogAnimationDuration) {
                        self.dialogBackgroundView?.alpha = 1.0
                        dialog.alpha = 1.0
                        let animation = CABasicAnimation(keyPath: "transform.scale")
                        animation.fromValue = 1.3
                        animation.toValue = 1.0
                        animation.duration = dialogAnimationDuration
                        dialog.layer.add(animation, forKey: "scale")
                    }
                    
                case .fromTop :
                    UIView.animate(withDuration: dialogAnimationDuration) {
                        self.dialogBackgroundView?.alpha = 1.0
                        dialog.alpha = 1.0
                        let animation = CABasicAnimation(keyPath: "position.y")
                        animation.fromValue = -dialog.gkHeight / 2
                        animation.toValue = dialog.layer.position.y
                        animation.duration = dialogAnimationDuration
                        animation.timingFunction = CAMediaTimingFunction(name: .easeIn)
                        dialog.layer.add(animation, forKey: "position")
                    }
                    
                case .fromBottom :
                    UIView.animate(withDuration: dialogAnimationDuration) {
                        self.dialogBackgroundView?.alpha = 1.0
                        dialog.alpha = 1.0
                        let animation = CABasicAnimation(keyPath: "position.y")
                        animation.fromValue = self.view.gkHeight + dialog.gkHeight / 2
                        animation.toValue = dialog.layer.position.y
                        animation.duration = dialogAnimationDuration
                        animation.timingFunction = CAMediaTimingFunction(name: .easeIn)
                        dialog.layer.add(animation, forKey: "position")
                    }
                    
                case .custom :
                    self.didExecuteDialogShowCustomAnimate { (_) in
                        
                    }
                }
            }else{
                self.dialogBackgroundView?.alpha = 1.0
            }
        }
    }
    
    ///隐藏
    @objc func dismissDialog(animated: Bool = true, completion: DialogCompletion?){
        
        self.dialogWillDismissCallback?(animated)
        UIApplication.shared.keyWindow?.endEditing(true)
        
        if let dialog = self.dialog, animated {
            switch self.dialogDismissAnimate {
            case .none :
                self.onDialogDismiss(completion: completion)
                
            case .scale :
                UIView.animate(withDuration: dialogAnimationDuration, animations: {
                    self.setNeedsStatusBarAppearanceUpdate()
                    self.dialogBackgroundView?.alpha = 0
                    dialog.alpha = 0
                    let animation = CABasicAnimation(keyPath: "transform.scale")
                    animation.fromValue = 1.0
                    animation.toValue = 1.3
                    animation.duration = dialogAnimationDuration
                    animation.fillMode = .forwards
                    animation.isRemovedOnCompletion = false
                    dialog.layer.add(animation, forKey: "scale")
                }) { (_) in
                    self.onDialogDismiss(completion: completion)
                }
                
            case .fromTop :
                UIView.animate(withDuration: dialogAnimationDuration, animations: {
                    self.setNeedsStatusBarAppearanceUpdate()
                    self.dialogBackgroundView?.alpha = 0
                    dialog.alpha = 0
                    
                    let animation = CABasicAnimation(keyPath: "position.y")
                    animation.fromValue = dialog.layer.position.y
                    animation.toValue = -dialog.gkHeight / 2
                    animation.duration = dialogAnimationDuration
                    animation.timingFunction = CAMediaTimingFunction(name: .easeIn)
                    animation.fillMode = .forwards
                    animation.isRemovedOnCompletion = false
                    dialog.layer.add(animation, forKey: "position")
                }) { (_) in
                    self.onDialogDismiss(completion: completion)
                }
                
            case .fromBottom :
                UIView.animate(withDuration: dialogAnimationDuration, animations: {
                    self.setNeedsStatusBarAppearanceUpdate()
                    self.dialogBackgroundView?.alpha = 0
                    dialog.alpha = 0
                    
                    let animation = CABasicAnimation(keyPath: "position.y")
                    animation.fromValue = dialog.layer.position.y
                    animation.toValue = self.view.gkHeight + dialog.gkHeight / 2
                    animation.duration = dialogAnimationDuration
                    animation.timingFunction = CAMediaTimingFunction(name: .easeIn)
                    animation.fillMode = .forwards
                    animation.isRemovedOnCompletion = false
                    dialog.layer.add(animation, forKey: "position")
                }) { (_) in
                    self.onDialogDismiss(completion: completion)
                }

            case .custom :
                self.didExecuteDialogDismissCustomAnimate { (_) in
                    
                }
            }
        }
    }
    
    ///消失动画完成
    private func onDialogDismiss(completion: DialogCompletion?){
        
        if self.dialogShouldUseNewWindow {
            if self.dialogWindow?.rootViewController != nil {
                self.dismiss(animated: false) {
                    self.afterDialogDismiss(completion: completion)
                }
            } else {
                self.afterDialogDismiss(completion: completion)
            }
        } else {
            if self.presentingViewController != nil {
                self.dismiss(animated: false) {
                    self.afterDialogDismiss(completion: completion)
                }
            } else {
                self.view.removeFromSuperview()
                self.removeFromParent()
                self.afterDialogDismiss(completion: completion)
            }
        }
    }
    
    ///弹窗消失
    private func afterDialogDismiss(completion: DialogCompletion?){
        
        completion?()
        self.dialogDismissCompletion?()
        if self.dialogShouldUseNewWindow && self.dialogWindow?.rootViewController != nil {
            self.dialogWindow?.rootViewController = nil
        }
        UIApplication.shared.removeDialogWindowIfNeeded()
    }
    
    ///执行自定义显示动画 子类重写
    @objc func didExecuteDialogShowCustomAnimate(_ completion: ((_ finish: Bool) -> Void)?){
        completion?(true)
    }
    
    ///执行自定义消失动画 子类重写
    @objc func didExecuteDialogDismissCustomAnimate(_ completion: ((_ finish: Bool) -> Void)?){
        completion?(true)
    }
    
    ///键盘弹出来，调整弹窗位置，子类可重写
    @objc func adjustDialogPosition(){
        
        if let dialog = self.dialog {
            var y: CGFloat = 0
            if self.keyboardHidden {
                y = self.view.gkHeight / 2.0
            } else {
                y = min(self.view.gkHeight / 2.0, self.view.gkHeight - self.keyboardFrame.size.height - dialog.gkHeight / 2.0 - 10.0)
            }
            
            UIView.animate(withDuration: 0.25) {
                if let constraint = dialog.gkCenterYLayoutConstraint {
                    constraint.constant = y - self.view.gkHeight / 2.0
                    self.view.layoutIfNeeded()
                } else {
                    dialog.center = CGPoint(dialog.center.x, y - self.view.gkHeight / 2.0)
                }
            }
        }
    }
    
    // MARK: - Swizzle
    
    private(set) var isDialogViewDidLayoutSubviews: Bool{
        set{
            objc_setAssociatedObject(self, &isDialogViewDidLayoutSubviewsKey, newValue, .OBJC_ASSOCIATION_RETAIN_NONATOMIC)
        }
        get{
            objc_getAssociatedObject(self, &isDialogViewDidLayoutSubviewsKey) as? Bool ?? false
        }
    }
    
    static func swizzleForDialog(){
        
        let selectors: [Selector] = [
            #selector(viewWillAppear(_:)),
            #selector(viewWillDisappear(_:)),
            #selector(viewDidAppear(_:)),
            #selector(viewDidLoad),
            #selector(viewDidLayoutSubviews),
        ]
        
        for selector in selectors {
            swizzling(selector1: selector, selector2: Selector("gkDialog_\(NSStringFromSelector(selector))"), cls1: self)
        }
    }
    
    @objc private func gkDialog_viewWillAppear(_ animated: Bool){
        gkDialog_viewWillAppear(animated)
        if self.isShowAsDialog {
            self.isDialogShowing = true
        }
    }
    
    @objc private func gkDialog_viewWillDisappear(_ animated: Bool){
        gkDialog_viewWillDisappear(animated)
        if self.isShowAsDialog {
            self.isDialogShowing = false
        }
    }
    
    @objc private func gkDialog_viewDidAppear(_ animated: Bool){
        gkDialog_viewDidAppear(animated)
        if self.isShowAsDialog {
            executeShowAnimate()
        }
    }
    
    @objc private func gkDialog_viewDidLoad(){
        gkDialog_viewDidLoad()
        
        if self.isShowAsDialog {
            let view = UIView()
            view.alpha = 0
            view.backgroundColor = UIColor(white: 0, alpha: 0.4)
            self.view.insertSubview(view, at: 0)
            
            view.addGestureRecognizer(self.tapDialogBackgroundGestureRecognizer)
            self.tapDialogBackgroundGestureRecognizer.isEnabled = self.shouldDismissDialogOnTapTranslucent
            
            view.snp.makeConstraints { (make) in
                make.edges.equalTo(0)
            }
            self.dialogBackgroundView = view
            
            if #available(iOS 11.0, *) {
                
            } else {
                self.automaticallyAdjustsScrollViewInsets = false
            }
            self.view.backgroundColor = .clear
        }
    }
    
    @objc private func gkDialog_viewDidLayoutSubviews(){
        gkDialog_viewDidLayoutSubviews()
        self.isDialogViewDidLayoutSubviews = true
        
        if self.isShowAsDialog {
            executeShowAnimate()
        }
    }
}
