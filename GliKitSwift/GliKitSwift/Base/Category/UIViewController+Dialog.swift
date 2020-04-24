//
//  UIViewController+Dialog.swift
//  GliKitSwift
//
//  Created by 罗海雄 on 2020/3/25.
//  Copyright © 2020 luohaixiong. All rights reserved.
//

import UIKit

public typealias DialogCompletion = () -> Void

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

    ///在指定viewController 上显示
    func showAsDialog(in viewController: UIViewController){
        
    }

    /**
     显示在制定viewControlelr
     *@param layoutHandler 布局回调 如果为空，则在viewController 上铺满
     */
    - (void)showAsDialogInViewController:(UIViewController *)viewController layoutHandler:(void(NS_NOESCAPE ^ __nullable)(UIView *view, UIView *superview)) layoutHandler;

    /**
     隐藏
     */
    @objc func dismissDialog(){
        
    }

    /**
     执行自定义显示动画 子类重写
     */
    - (void)didExecuteDialogShowCustomAnimate:(void(^_Nullable)(BOOL finish)) completion;

    /**
     执行自定义消失动画 子类重写
     */
    - (void)didExecuteDialogDismissCustomAnimate:(void(^_Nullable)(BOOL finish)) completion;

    /**
     键盘弹出来，调整弹窗位置，子类可重写
     */
    - (void)adjustDialogPosition;
}
