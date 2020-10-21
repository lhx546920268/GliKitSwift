//
//  AlertUtils.swift
//  GliKitSwift
//
//  Created by 罗海雄 on 2020/10/20.
//  Copyright © 2020 luohaixiong. All rights reserved.
//

import UIKit

///提示弹窗点击回调
public typealias AlertButtonDidClickCallback = (_ index: Int, _ title: String) -> Void

///确认弹窗
public typealias AlertConfirmCallback = () -> Void

public class AlertUtils {
    
    ///显示一个提示弹出
    @discardableResult
    public static func showAlert(
        title: Any? = nil,
        message: Any? = nil,
        icon: UIImage? = nil,
        buttonTitles: [String]? = nil,
        destructiveButtonIndex: Int = NSNotFound,
        callback: AlertButtonDidClickCallback? = nil) -> AlertController {
        
        return showAlertController(
            style: .alert,
            title: title,
            message: message,
            icon: icon,
            buttonTitles: buttonTitles,
            destructiveButtonIndex: destructiveButtonIndex,
            cancelButtonTitle: nil,
            callback: callback)
    }
    
    ///显示一个确认 取消弹窗
    @discardableResult
    public static func showConfirmAlert(
        title: Any? = nil,
        message: Any? = nil,
        icon: UIImage? = nil,
        destructiveButtonIndex: Int = 1,
        callback: AlertConfirmCallback? = nil) -> AlertController {
        
        return showAlert(
            title: title,
            message: message,
            icon: icon,
            buttonTitles: ["取消", "确定"],
            destructiveButtonIndex: destructiveButtonIndex) { (index, _) in
            if index == 1 {
                callback?()
            }
        }
    }
    
    ///显示一个actionSheet
    @discardableResult
    public static func showActionSheet(
        title: Any? = nil,
        message: Any? = nil,
        icon: UIImage? = nil,
        buttonTitles: [String]? = nil,
        cancelButtonTitle: String? = "取消",
        destructiveButtonIndex: Int = NSNotFound,
        callback: AlertButtonDidClickCallback? = nil) -> AlertController {
        
        return showAlertController(
            style: .actionSheet,
            title: title,
            message: message,
            icon: icon,
            buttonTitles: buttonTitles,
            destructiveButtonIndex: destructiveButtonIndex,
            cancelButtonTitle: cancelButtonTitle,
            callback: callback)
    }
    
    private static func showAlertController(
        style: AlertController.Style,
        title: Any? = nil,
        message: Any? = nil,
        icon: UIImage? = nil,
        buttonTitles: [String]? = nil,
        destructiveButtonIndex: Int = NSNotFound,
        cancelButtonTitle: String?,
        callback: AlertButtonDidClickCallback? = nil) -> AlertController{
        
        let alert = AlertController(
            title: title,
            message: message,
            icon: icon,
            style: style,
            cancelButtonTitle: cancelButtonTitle,
            otherButtonTitles: buttonTitles,
            actions: nil)
        alert.destructiveButtonIndex = destructiveButtonIndex
        alert.selectCallback = { (index) in
            let title = (index < (buttonTitles?.count ?? 0) ? buttonTitles![index] : cancelButtonTitle) ?? "取消"
            callback?(index, title)
        }
        alert.show()
        
        return alert
    }
}
