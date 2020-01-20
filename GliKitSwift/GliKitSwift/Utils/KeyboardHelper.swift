//
//  KeyboardHelper.swift
//  GliKitSwift
//
//  Created by 罗海雄 on 2020/1/20.
//  Copyright © 2020 luohaixiong. All rights reserved.
//

import UIKit

///键盘帮助类
public class KeyboardHelper {
    
    ///单例
    public static let share = KeyboardHelper()
    
    ///键盘是否显示
    public private(set) var keyboardShowing = false
    
    init() {
        
        NotificationCenter.default.addObserver(self, selector: #selector(self.keyboardWillShow), name: UIView.keyboardWillShowNotification, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(self.keyboardWillHide), name: UIView.keyboardWillHideNotification, object: nil)
    }
    
    deinit {
        NotificationCenter.default.removeObserver(self)
    }
    
    // MARK: - 通知
    
    ///键盘显示
    @objc private func keyboardWillShow(){
        
        keyboardShowing = true
    }

    ///键盘隐藏
    @objc private func keyboardWillHide(){
        
        keyboardShowing = false
    }
}
