//
//  UIViewController+Utils.swift
//  GliKitSwift
//
//  Created by 罗海雄 on 2020/1/22.
//  Copyright © 2020 luohaixiong. All rights reserved.
//

import UIKit

// MARK: - Fetch

public extension UIViewController {
    
    ///获取最上层的 presentedViewController
    var gkTopestPresentedViewController: UIViewController{
        get{
            if self.presentedViewController != nil {
                return self.presentingViewController!.gkTopestPresentedViewController
            }else{
                return self
            }
        }
    }

    ///获取最底层的 presentingViewController
    var gkRootPresentingViewController: UIViewController{
        get{
            if self.presentingViewController != nil {
                return self.presentingViewController!.gkRootPresentingViewController
            }else{
                return self
            }
        }
    }
}

// MARK: - All

public extension NSObject {
    
    ///获取当前显示的UIViewController
    static var gkCurrentViewController: UIViewController{
        get{
            
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
    }
    
    var gkCurrentNavigationController: UINavigationController?{
        get{
            NSObject.gkCurrentNavigationController
        }
    }
    
    ///获取当前显示的 UINavigationController 如果是部分present出来的，则忽略
    static var gkCurrentNavigationController: UINavigationController?{
        get{
            
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
    }
    
    var gkCurrentViewController: UIViewController{
        get{
            NSObject.gkCurrentViewController
        }
    }
    
    // MARK: - push
    
    /// 打开一个viewController ，如果有存在navigationController, 则使用系统的push，没有则使用自定义的push
    /// - Parameters:
    ///   - viewControlelr: 要push 的视图控制器
    ///   - toReplacedViewControlelrs: 要替换掉的controller
    static func gkPushViewController(_ viewControlelr: UIViewController, replace toReplacedViewControlelrs: [UIViewController]?){
        
        let parentViewControlelr = self.gkCurrentViewController
        
        var nav = parentViewControlelr.navigationController
        if parentViewControlelr is UINavigationController {
            nav = parentViewControlelr as? UINavigationController
        }
        if nav != nil {
            if toReplacedViewControlelrs?.count ?? 0 > 0{
                var viewControllers = nav!.viewControllers
                viewControllers.removeAll { vc -> Bool in
                    toReplacedViewControlelrs!.contains(vc)
                }
                viewControllers.append(viewControlelr)
                
                nav!.setViewControllers(viewControllers, animated: true)
            }else{
                nav!.pushViewController(viewControlelr, animated: true)
            }
            
        }else{
            // TODO:
        }
    }
}
