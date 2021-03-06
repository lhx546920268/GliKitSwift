//
//  UIViewController+Utils.swift
//  GliKitSwift
//
//  Created by 罗海雄 on 2020/1/22.
//  Copyright © 2020 luohaixiong. All rights reserved.
//

import UIKit

///是否可以活动返回
private var interactivePopEnableKey: UInt8 = 0

///是否显示返回按钮
private var showBackItemKey: UInt8 = 0

///导航栏按钮tintColor
private var tintColorKey: UInt8 = 0

// MARK: - Fetch

public extension UIViewController {
    
    ///隐藏导航栏阴影
    var gkHideNavigationBarShadowImage: Bool{
        set{
            if let nav = self.navigationController {
                let view = gkFindShadowImageView(nav.navigationBar)
                view?.isHidden = newValue
            }
        }
        get{
            if let nav = self.navigationController {
                
                if let view = gkFindShadowImageView(nav.navigationBar) {
                    return view.isHidden
                }
            }
            return false
        }
    }
    
    ///获取导航栏阴影视图
    func gkFindShadowImageView(_ view: UIView) -> UIImageView? {
        if view.isKind(of: UIImageView.classForCoder()) && view.bounds.size.height <= 1.0 {
            return view as? UIImageView
        }
        
        for subView in view.subviews {
            let imageView = self.gkFindShadowImageView(subView)
            if imageView != nil {
                return imageView
            }
        }
        
        return nil
    }
    
    ///是否可以滑动返回 default 'YES'
    var gkInteractivePopEnable: Bool{
        set{
            objc_setAssociatedObject(self, &interactivePopEnableKey, newValue, .OBJC_ASSOCIATION_RETAIN_NONATOMIC)
        }
        get{
            if let enable = objc_getAssociatedObject(self, &interactivePopEnableKey) as? Bool {
                return enable
            }
            return true
        }
    }
    
    ///状态栏高度
    var gkStatusBarHeight: CGFloat{
        guard let window: UIWindow = UIApplication.shared.delegate?.window ?? nil else {
            return 20
        }
        
        var height: CGFloat = window.gkSafeAreaInsets.top;
        //iOS 14 iPhone 12 mini的导航栏和状态栏有间距
        if #available(iOS 13.0, *) {
            if let statusBarManager = window.windowScene?.statusBarManager {
                height = statusBarManager.statusBarFrame.size.height
            }
        } else {
            height = UIApplication.shared.statusBarFrame.size.height
        }
        
        if height == 0 {
            if (window.gkSafeAreaInsets.bottom) > 0 {
                height = 44;
            }else{
                height = 20;
            }
        }
        
        return height;
    }
    
    ///导航栏高度
    var gkNavigationBarHeight: CGFloat{
        self.navigationController?.navigationBar.frame.size.height ?? 0
    }
    
    ///获取兼容的状态栏高度 比如有连接个人热点的时候状态栏的高度是不一样的 viewDidLayoutSubviews 获取
    var gkCompatiableStatusHeight: CGFloat{
        var statusHeight = self.gkStatusBarHeight;
        var safeAreaTop: CGFloat
        
        if #available(iOS 11, *) {
            safeAreaTop = self.view.gkSafeAreaInsets.top
        } else {
            safeAreaTop = self.topLayoutGuide.length
        }
        
        if let nav = self.navigationController {
            if !nav.isNavigationBarHidden && nav.navigationBar.isTranslucent {
                if safeAreaTop > self.gkNavigationBarHeight {
                    safeAreaTop -= self.gkNavigationBarHeight
                }
            }
        }
        
        if statusHeight != safeAreaTop {
            statusHeight = 0
        }
        
        return statusHeight;
    }
    
    ///选项卡高度
    var gkTabBarHeight: CGFloat{
        if let tabBarController = self.tabBarController {
            return tabBarController.tabBar.bounds.size.height;
        }else{
            return 49 + (UIApplication.shared.delegate?.window??.gkSafeAreaInsets.bottom ?? 0);
        }
    }
    
    ///工具条高度
    var gkToolBarHeight: CGFloat{
        if let tooBar = self.navigationController?.toolbar {
            return tooBar.bounds.size.height;
        }else{
            return 44 + (UIApplication.shared.delegate?.window??.gkSafeAreaInsets.bottom ?? 0);
        }
    }
    
    ///获取最上层的 presentedViewController
    var gkTopestPresentedViewController: UIViewController{
        if self.presentedViewController != nil {
            return self.presentedViewController!.gkTopestPresentedViewController
        }else{
            return self
        }
    }
    
    ///获取最底层的 presentingViewController
    var gkRootPresentingViewController: UIViewController{
        if self.presentingViewController != nil {
            return self.presentingViewController!.gkRootPresentingViewController
        }else{
            return self
        }
    }
    
    ///创建导航栏并返回
    var gkCreateWithNavigationController: UINavigationController{
        if let nav = self.navigationController {
            return nav
        }else{
            return BaseNavigationController(rootViewController: self);
        }
    }
}

public extension UIViewController{
    
    ///显示返回按钮
    var gkShowBackItem: Bool{
        set{
            if newValue != self.gkShowBackItem {
                if newValue {
                    let image = UIImage.gkNavigationBarBackIcon;
                    self.gkSetNavigationBarItem(self.gkBarItem(image: image, target: self, action: #selector(self.gkGoBack)), position: .left)
                }else{
                    self.navigationItem.leftBarButtonItem = nil;
                    self.navigationItem.leftBarButtonItems = nil;
                    self.navigationItem.hidesBackButton = true;
                }
                objc_setAssociatedObject(self, &showBackItemKey, newValue, .OBJC_ASSOCIATION_RETAIN_NONATOMIC)
            }
        }
        get{
            if let show = objc_getAssociatedObject(self, &showBackItemKey) as? Bool {
                return show
            }
            return false
        }
    }
    
    ///返回按钮
    var gkBackBarButtonItem: UIBarButtonItem?{
        self.navigationItem.leftBarButtonItem
    }
    
    ///返回
    @objc private func gkGoBack(){
        gkBack(animated: true)
    }
    
    ///返回 是否动画 返回完成回调
    func gkBack(animated: Bool = true, completion: (() -> Void)? = nil){
        
        self.gkBeforeBack()
        
        if let nav = self.navigationController {
            if nav.viewControllers.count <= 1 {
                if self.presentingViewController != nil {
                    self.dismiss(animated: animated, completion: completion)
                } else {
                    completion?()
                }
                
            } else {
                self.gkSetTransitionCompletion(completion)
                nav.popViewController(animated: animated)
            }
        }
    }
    
    ///返回最前面
    func gkBackToRootViewController(animated: Bool = true, completion:(() -> Void)? = nil){
        
        self.gkBeforeBack()
        
        //是present出来的
        if self.presentingViewController != nil {
            let root = self.gkRootPresentingViewController
            if let nav = root.navigationController, nav.viewControllers.count > 1 {
                //dismiss 之后还有 pop,所以dismiss无动画
                root.dismiss(animated: false) {
                    self.gkSetTransitionCompletion(completion)
                    root.navigationController?.popToRootViewController(animated: animated)
                }
            } else {
                root.dismiss(animated: animated, completion: completion)
            }
        } else {
            self.gkSetTransitionCompletion(completion)
            self.navigationController?.popToRootViewController(animated: animated)
        }
    }
    
    ///返回之前
    private func gkBeforeBack(){
        UIApplication.shared.gkKeyWindow?.endEditing(true)
        self.classForCoder.cancelPreviousPerformRequests(withTarget: self)
    }
    
    ///设置过渡动画完成回调
    private func gkSetTransitionCompletion(_ completion: (() -> Void)?){
        
        if let nav = self.navigationController {
            if completion != nil && nav.isKind(of: BaseNavigationController.classForCoder()) {
                let baseNav = nav as! BaseNavigationController
                baseNav.transitionCompletion = completion
            }
        }
    }
}

///导航栏按钮位置
public enum NavigationItemPosition {
    
    case left
    case right
}

public extension UIViewController{
    
    ///导航栏按钮tintColor，默认是 导航栏上的tintColor
    var gkTintColor: UIColor{
        set{
            objc_setAssociatedObject(self, &tintColorKey, newValue, .OBJC_ASSOCIATION_RETAIN_NONATOMIC)
            self.gkTintColorDidChange()
        }
        get{
            var tintColor = objc_getAssociatedObject(self, &tintColorKey) as? UIColor
            if tintColor == nil {
                tintColor = self.navigationController?.navigationBar.tintColor
            }
            
            if tintColor == nil {
                tintColor = UIColor.gkNavigationBarTintColor
            }
            
            return tintColor!
        }
    }
    
    ///tintColor改变
    private func gkTintColorDidChange(){
        self.gkSetTintColor(item: self.navigationItem.leftBarButtonItem)
        self.gkSetTintColor(item: self.navigationItem.rightBarButtonItem)
    }
    
    ///设置item tintColor
    func gkSetTintColor(item: UIBarButtonItem?){
        
        if let barItem = item {
            let tintColor = self.gkTintColor
            if let btn = barItem.customView as? UIButton {
                
                if btn.image(for: .normal) != nil {
                    
                    btn.gkSetTintColor(tintColor, state: .normal)
                    btn.gkSetTintColor(tintColor.gkColor(withAlpha: 0.3), state: .highlighted)
                } else {
                    
                    btn.setTitleColor(tintColor, for: .normal)
                    btn.setTitleColor(tintColor.gkColor(withAlpha: 0.3), for: .highlighted)
                }
            }else{
                barItem.customView?.tintColor = tintColor
            }
        }
    }
    
    
    /**
     设置导航栏按钮
     
     @param item 按钮
     @param position 位置
     */
    func gkSetNavigationBarItem(_ item: UIBarButtonItem, position: NavigationItemPosition){
        
        self.gkSetTintColor(item: item)
        item.customView?.gkWidth += UIApplication.gkNavigationBarMargin * 2
        switch position {
        case .left :
            self.navigationItem.leftBarButtonItem = item
        case .right:
            self.navigationItem.rightBarButtonItem = item
        }
    }
    
    /**
     设置导航栏左边按钮
     
     @param title 按钮标题
     @param action 点击方法
     @return 按钮
     */
    @discardableResult
    func gkSetLeftItem(title: String, action: Selector?) -> UIBarButtonItem{
        
        let item = self.gkBarItem(title: title, target: self, action: action)
        self.gkSetNavigationBarItem(item, position: .left)
        
        return item
    }
    
    /**
     设置导航栏左边按钮
     
     @param image 按钮图标
     @param action 点击方法
     @return 按钮
     */
    @discardableResult
    func gkSetLeftItem(image: UIImage, action: Selector?) -> UIBarButtonItem{
        
        let item = self.gkBarItem(image: image, target: self, action: action)
        self.gkSetNavigationBarItem(item, position: .left)
        
        return item
    }
    
    /**
     设置导航栏左边按钮
     
     @param systemItem 系统按钮图标
     @param action 点击方法
     @return 按钮
     */
    @discardableResult
    func gkSetLeftItem(systemItem: UIBarButtonItem.SystemItem, action: Selector?) -> UIBarButtonItem{
        
        let item = self.gkBarItem(systemItem: systemItem, target: self, action: action)
        self.gkSetNavigationBarItem(item, position: .left)
        
        return item
    }
    
    /**
     设置导航栏左边按钮
     
     @param customView 自定义视图
     @return 按钮
     */
    @discardableResult
    func gkSetLeftItem(customView: UIView) -> UIBarButtonItem{
        
        let item = self.gkBarItem(customView: customView)
        self.gkSetNavigationBarItem(item, position: .left)
        
        return item
    }
    
    /**
     设置导航栏右边按钮
     
     @param title 按钮标题
     @param action 点击方法
     @return 按钮
     */
    @discardableResult
    func gkSetRightItem(title: String, action: Selector?) -> UIBarButtonItem{
        
        let item = self.gkBarItem(title: title, target: self, action: action)
        self.gkSetNavigationBarItem(item, position: .right)
        
        return item
    }
    
    /**
     设置导航栏右边按钮
     
     @param image 按钮图标
     @param action 点击方法
     @return 按钮
     */
    @discardableResult
    func gkSetRightItem(image: UIImage, action: Selector?) -> UIBarButtonItem{
        
        let item = self.gkBarItem(image: image, target: self, action: action)
        self.gkSetNavigationBarItem(item, position: .right)
        
        return item
    }
    
    /**
     设置导航栏右边按钮
     
     @param systemItem 系统按钮图标
     @param action 点击方法
     @return 按钮
     */
    @discardableResult
    func gkSetRightItem(systemItem: UIBarButtonItem.SystemItem, action: Selector?) -> UIBarButtonItem{
        
        let item = self.gkBarItem(systemItem: systemItem, target: self, action: action)
        self.gkSetNavigationBarItem(item, position: .right)
        
        return item
    }
    
    /**
     设置导航栏右边按钮
     
     @param customView 自定义视图
     @return 按钮
     */
    @discardableResult
    func gkSetRightItem(customView: UIView) -> UIBarButtonItem{
        
        let item = self.gkBarItem(customView: customView)
        self.gkSetNavigationBarItem(item, position: .right)
        
        return item
    }
    
    @discardableResult
    func gkBarItem(image: UIImage, target: Any?, action: Selector?) -> UIBarButtonItem{
        
        var img = image
        if image.renderingMode != .alwaysTemplate {
            
            img = image.withRenderingMode(.alwaysTemplate)
        }
        
        let btn = UIButton(type: .custom)
        btn.setImage(img, for: .normal)
        if action != nil {
            btn.addTarget(target, action: action!, for: .touchUpInside)
        }
        btn.gkSetTintColor(.gray, state: .disabled)
        btn.frame = CGRect(x: 0, y: 0, width: image.size.width, height: 44)
        
        return UIBarButtonItem(customView: btn)
    }
    
    @discardableResult
    func gkBarItem(title: String, target: Any?, action: Selector?) -> UIBarButtonItem{
        
        let btn = UIButton(type: .custom)
        btn.setTitle(title, for: .normal)
        btn.titleLabel?.font = UIFont.gkNavigationBarItemFont
        btn.setTitleColor(.gray, for: .disabled)
        if action != nil {
            btn.addTarget(target, action: action!, for: .touchUpInside)
        }
        
        let size = title.gkStringSize(font: UIFont.gkNavigationBarItemFont)
        btn.frame = CGRect(x: 0, y: 0, width: size.width, height: 44)
        
        return UIBarButtonItem(customView: btn)
    }
    
    @discardableResult
    func gkBarItem(customView: UIView) -> UIBarButtonItem{
        return UIBarButtonItem(customView: customView)
    }
    
    @discardableResult
    func gkBarItem(systemItem: UIBarButtonItem.SystemItem, target: Any?, action: Selector?) -> UIBarButtonItem{
        return UIBarButtonItem(barButtonSystemItem: systemItem, target: target, action: action)
    }
}

// MARK: - All

public extension NSObject {
    
    ///获取当前显示的UIViewController
    static var gkCurrentViewController: UIViewController{
        //刚开始启动 不一定是tabBar
        let rootViewController = UIApplication.shared.delegate!.window!!.rootViewController!
        
        if !(rootViewController is UITabBarController) {
            
            if rootViewController is UINavigationController {
                let nav = rootViewController as! UINavigationController
                
                return nav.viewControllers.last ?? nav
            } else {
                return rootViewController
            }
        } else {
            
            let tab = rootViewController as! UITabBarController
            var parentedViewControlelr = tab.gkTopestPresentedViewController
            if parentedViewControlelr.isEqual(tab) {
                parentedViewControlelr = tab.selectedViewController!
            }
            
            if parentedViewControlelr is UINavigationController {
                let nav = parentedViewControlelr as! UINavigationController
                return nav.viewControllers.last ?? nav
            } else {
                return parentedViewControlelr
            }
        }
    }
    
    var gkCurrentNavigationController: UINavigationController?{
        NSObject.gkCurrentNavigationController
    }
    
    ///获取当前显示的 UINavigationController 如果是部分present出来的，则忽略
    static var gkCurrentNavigationController: UINavigationController?{
        //刚开始启动 不一定是tabBar
        let rootViewController = UIApplication.shared.delegate!.window!!.rootViewController!
        
        if !(rootViewController is UITabBarController) {
            
            if rootViewController is UINavigationController {
                return rootViewController as? UINavigationController
            } else {
                return rootViewController.navigationController
            }
        } else {
            
            let tab = rootViewController as! UITabBarController
            var parentedViewControlelr = tab.gkTopestPresentedViewController
            
            if parentedViewControlelr.gkTransitioningDelegate?.isKind(of: PartialPresentTransitionDelegate.classForCoder()) ?? false {
                parentedViewControlelr = parentedViewControlelr.presentingViewController!
            }
            
            if parentedViewControlelr.isEqual(tab) {
                parentedViewControlelr = tab.selectedViewController!
            }
            
            if parentedViewControlelr is UINavigationController {
                return parentedViewControlelr as? UINavigationController
            } else {
                return parentedViewControlelr.navigationController
            }
        }
    }
    
    var gkCurrentViewController: UIViewController{
        NSObject.gkCurrentViewController
    }
    
    // MARK: - push
    
    /// 打开一个viewController ，如果有存在navigationController, 则使用系统的push，没有则使用自定义的push
    /// - Parameters:
    ///   - viewController: 要push 的视图控制器
    ///   - toReplacedViewControlelrs: 要替换掉的controller
    static func gkPushViewController(_ viewController: UIViewController, replace toReplacedViewControlelrs: [UIViewController]?){
        
        if let nav = self.gkCurrentNavigationController {
            if toReplacedViewControlelrs?.count ?? 0 > 0{
                var viewControllers = nav.viewControllers
                viewControllers.removeAll { vc -> Bool in
                    toReplacedViewControlelrs!.contains(vc)
                }
                viewControllers.append(viewController)
                
                nav.setViewControllers(viewControllers, animated: true)
            }else{
                nav.pushViewController(viewController, animated: true)
            }
        }else{
            print("There is no navigationController")
        }
    }
    
    func gkPush(with viewController: UIViewController, replace toReplacedViewControlelrs: [UIViewController]?){
        NSObject.gkPushViewController(viewController, replace: toReplacedViewControlelrs)
    }
    
    /// 替换当前 页面，如果有存在navigationController, 则替换成功
    /// - Parameter viewController: 要push 的视图控制器
    static func gkReplace(with viewController: UIViewController){
        
        if let nav = self.gkCurrentNavigationController {
            var viewControllers = nav.viewControllers
            viewControllers.removeLast()
            viewControllers.append(viewController)
            
            nav.setViewControllers(viewControllers, animated: true)
            
        }else{
            print("There is no navigationController")
        }
    }
}

private var hasTabBarKey: UInt8 = 0

///自定义tabBar扩展
public extension UIViewController {
    
    ///当前tabBarController
    var gkTabBarController: TabBarController? {
        get{
            if let vc = UIApplication.shared.delegate?.window??.rootViewController as? TabBarController {
                return vc
            }
            
            if let vc = gkRootPresentingViewController as? TabBarController {
                return vc
            }
            
            return nil
        }
    }

    ///是否有tabBar
    var gkHasTabBar: Bool {
        get{
            if let nav = parent as? UINavigationController, nav.viewControllers.first == self {
                return nav.gkHasTabBar
            }
            return objc_getAssociatedObject(self, &hasTabBarKey) as? Bool ?? false
        }
        set{
            objc_setAssociatedObject(self, &hasTabBarKey, newValue, .OBJC_ASSOCIATION_RETAIN_NONATOMIC)
        }
    }
}
