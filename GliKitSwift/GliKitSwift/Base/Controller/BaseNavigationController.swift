//
//  BaseNavigationController.swift
//  GliKitSwift
//
//  Created by 罗海雄 on 2020/3/20.
//  Copyright © 2020 luohaixiong. All rights reserved.
//

import UIKit

///基础导航控制视图
public class BaseNavigationController: UINavigationController, UINavigationControllerDelegate, UIGestureRecognizerDelegate {
    
    ///是否是手势交互返回
    public private(set) var isInteractivePop: Bool = false

    ///pop 或者 push 完成回调，执行后会 变成nil
    public var transitionCompletion: (() -> Void)?
    
    ///其他代理
    public weak var otherDelegate: UINavigationControllerDelegate?
    
    public override init(rootViewController: UIViewController) {
        
        super.init(navigationBarClass: SystemNavigationBar.self, toolbarClass: nil)
        self.viewControllers = [rootViewController]
        initParams()
    }
    
    public override init(nibName nibNameOrNil: String?, bundle nibBundleOrNil: Bundle?) {
        
        super.init(navigationBarClass: SystemNavigationBar.self, toolbarClass: nil)
        initParams()
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private func initParams(){
        
        self.modalPresentationStyle = .fullScreen
        if #available(iOS 13, *) {
            self.overrideUserInterfaceStyle = .light
        }
    }

    public override func viewDidLoad() {
        
        super.viewDidLoad()
        self.interactivePopGestureRecognizer?.delegate = self
        self.interactivePopGestureRecognizer?.addTarget(self, action: #selector(handleInteractivePop))
        self.delegate = self;
    }

    // MARK: - Action

    ///滑动返回
    @objc private func handleInteractivePop(_ sender: UIScreenEdgePanGestureRecognizer){
        
        switch sender.state {
        case .cancelled, .ended :
            self.isInteractivePop = false
        default:
            break
        }
    }

    // MARK: - Push
    
    public override func pushViewController(_ viewController: UIViewController, animated: Bool) {
        
        if animated {
            self.interactivePopGestureRecognizer?.isEnabled = false
        }
        super.pushViewController(viewController, animated: animated)
    }
    
    public override func popToRootViewController(animated: Bool) -> [UIViewController]? {
        
        if animated {
            self.interactivePopGestureRecognizer?.isEnabled = false
        }
        super.popToRootViewController(animated: animated)
    }
    
    public override func popToViewController(_ viewController: UIViewController, animated: Bool) -> [UIViewController]? {
        
        self.interactivePopGestureRecognizer?.isEnabled = false
        return super.popToViewController(viewController, animated: animated)
    }

    // MARK: - UINavigationControllerDelegate
    
    public func navigationController(_ navigationController: UINavigationController, willShow viewController: UIViewController, animated: Bool) {
        
        if let delegate = self.otherDelegate, delegate.responds(to: #selector(navigationController(_:willShow:animated:))) {
            delegate.navigationController?(navigationController, willShow: viewController, animated: animated)
        }
    }
    
    public func navigationController(_ navigationController: UINavigationController, didShow viewController: UIViewController, animated: Bool) {
        
        self.interactivePopGestureRecognizer?.isEnabled = viewController.gkInteractivePopEnable
        if let delegate = self.otherDelegate, delegate.responds(to: #selector(navigationController(_:didShow:animated:))) {
            delegate.navigationController?(navigationController, didShow: viewController, animated: animated)
        }
        
        self.transitionCompletion?()
        self.transitionCompletion = nil
    }

    // MARK: - UIGestureRecognizerDelegate
    
    public func gestureRecognizerShouldBegin(_ gestureRecognizer: UIGestureRecognizer) -> Bool {
        
        if gestureRecognizer == self.interactivePopGestureRecognizer {
            if self.viewControllers.count < 2 || self.visibleViewController == self.viewControllers.first {
                return false
            } else {
                UIApplication.shared.keyWindow?.endEditing(true)
            }
            
            self.isInteractivePop = true
            return true
        }
    }

    // MARK: - UIStatusBar
    
    public override var preferredStatusBarStyle: UIStatusBarStyle{
        get{
            return UIApplication.gkStatusBarStyle
        }
    }
    
    public override var childForStatusBarStyle: UIViewController?{
        get{
            return self.topViewController
        }
    }
}
