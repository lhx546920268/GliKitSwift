//
//  UIViewController+Keyboard.swift
//  GliKitSwift
//
//  Created by 罗海雄 on 2020/3/25.
//  Copyright © 2020 luohaixiong. All rights reserved.
//

import UIKit

private var keyboardHiddenKey: UInt8 = 0
private var keyboardFrameKey: UInt8 = 0
private var keyboardAnimationDurationKey: UInt8 = 0

///键盘相关扩展
public extension UIViewController{
    
    ///键盘是否隐藏
    private(set) var keyboardHidden: Bool{
        set{
            objc_setAssociatedObject(self, &keyboardHiddenKey, newValue, .OBJC_ASSOCIATION_RETAIN_NONATOMIC)
        }
        get{
            if let value = objc_getAssociatedObject(self, &keyboardHiddenKey) as? Bool {
                return value
            }
            return true
        }
    }

    ///键盘大小
    private(set) var keyboardFrame: CGRect{
        set{
            objc_setAssociatedObject(self, &keyboardFrameKey, newValue, .OBJC_ASSOCIATION_RETAIN_NONATOMIC)
        }
        get{
            if let value = objc_getAssociatedObject(self, &keyboardFrameKey) as? CGRect {
                return value
            }
            return CGRect.zero
        }
    }
    
    ///键盘动画时长
    private(set) var keyboardAnimationDuration: TimeInterval{
        set{
            objc_setAssociatedObject(self, &keyboardAnimationDurationKey, newValue, .OBJC_ASSOCIATION_RETAIN_NONATOMIC)
        }
        get{
            if let value = objc_getAssociatedObject(self, &keyboardAnimationDurationKey) as? TimeInterval {
                return value
            }
            return 0.25
        }
    }

    ///添加键盘监听
    func addKeyboardNotification(){
        
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillChangeFrame(_:)), name: UIApplication.keyboardWillChangeFrameNotification, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardDidChangeFrame(_:)), name: UIApplication.keyboardDidChangeFrameNotification, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillHide(_:)), name: UIApplication.keyboardWillHideNotification, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillShow(_:)), name: UIApplication.keyboardWillShowNotification, object: nil)
    }

    ///移除键盘监听
    func removeKeyboardNotification(){
        
        NotificationCenter.default.removeObserver(self, name: UIApplication.keyboardWillChangeFrameNotification, object: nil)
        NotificationCenter.default.removeObserver(self, name: UIApplication.keyboardDidChangeFrameNotification, object: nil)
        NotificationCenter.default.removeObserver(self, name: UIApplication.keyboardWillHideNotification, object: nil)
        NotificationCenter.default.removeObserver(self, name: UIApplication.keyboardWillShowNotification, object: nil)
    }

    ///键盘高度改变
    @objc func keyboardWillChangeFrame(_ notification: Notification){
        
        if let userInfo = notification.userInfo, !self.keyboardHidden {
            self.keyboardFrame = userInfo[UIResponder.keyboardFrameEndUserInfoKey] as? CGRect ?? .zero
            self.keyboardAnimationDuration = userInfo[UIResponder.keyboardAnimationDurationUserInfoKey] as? TimeInterval ?? 0.25
        }else{
            self.keyboardFrame = .zero
            self.keyboardAnimationDuration = 0.25
        }
    }
    
    @objc func keyboardDidChangeFrame(_ notification: Notification){
        
    }

    ///键盘隐藏
    @objc func keyboardWillHide(_ notification: Notification){
        
        self.keyboardHidden = true
        self.keyboardWillChangeFrame(notification)
    }

    ///键盘显示
    @objc func keyboardWillShow(_ notification: Notification){
        
        self.keyboardHidden = false
        self.keyboardWillChangeFrame(notification)
    }
}
