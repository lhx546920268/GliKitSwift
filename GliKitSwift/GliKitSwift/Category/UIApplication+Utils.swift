//
//  UIApplication+Utils.swift
//  GliKitSwift
//
//  Created by 罗海雄 on 2020/4/24.
//  Copyright © 2020 luohaixiong. All rights reserved.
//

import UIKit

private var dialogWindowKey: UInt8 = 0

public extension UIApplication {

    ///弹窗 窗口
    var dialogWindow: UIWindow?{
        set{
            objc_setAssociatedObject(self, &dialogWindowKey, newValue, .OBJC_ASSOCIATION_RETAIN_NONATOMIC)
        }
        get{
            objc_getAssociatedObject(self, &dialogWindowKey) as? UIWindow
        }
    }

    ///创建弹窗 如果为空的时候
    func loadDialogWindowIfNeeded(){
        
        if dialogWindow == nil {
            var window: UIWindow? = nil
            if #available(iOS 13, *) {
                var scene: UIWindowScene? = nil
                let scenes = UIApplication.shared.connectedScenes
                for s in scenes {
                    if let windowScene = s as? UIWindowScene, s.activationState == .foregroundActive {
                        scene = windowScene
                        break
                    }
                }
                if scene != nil {
                    window = UIWindow(windowScene: scene!)
                }
            }
            
            if window == nil {
                window = UIWindow()
            }
            window?.frame = UIScreen.main.bounds
            window?.windowLevel = .alert
            window?.backgroundColor = .clear
            self.dialogWindow = window
            window?.makeKeyAndVisible()
        }
    }

    ///当没有弹窗的时候 移除窗口
    func removeDialogWindowIfNeeded(){
        
        if let window = self.dialogWindow {
            if window.rootViewController == nil {
                window.resignKey()
                self.dialogWindow = nil
            }
        }
    }
    
    ///状态栏高度
    var gkStatusBarHeight: CGFloat {
        
        if #available(iOS 13.0, *) {
            if let window = UIApplication.shared.delegate?.window {
                if let statusBarManager = window?.windowScene?.statusBarManager {
                    return statusBarManager.statusBarFrame.size.height
                }
            }
            return 0
        } else {
            return UIApplication.shared.statusBarFrame.size.height
        }
    }
    
    ///keyWindow
    var gkKeyWindow: UIWindow? {
        return keyWindow
    }
}
