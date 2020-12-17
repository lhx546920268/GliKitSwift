//
//  TextField.swift
//  GliKitSwift
//
//  Created by 罗海雄 on 2020/11/24.
//  Copyright © 2020 luohaixiong. All rights reserved.
//

import UIKit

class TextField: UITextField {
    
    ///禁止的方法列表，如复制，粘贴， 把需要禁止的方法传进来，如禁止粘贴
    var forbiddenActions: [Selector]?

    ///内容间距 default zero
    @IBInspectable
    var contentInsets: UIEdgeInsets = .zero
    
    override func textRect(forBounds bounds: CGRect) -> CGRect {
        var rect = super.textRect(forBounds: bounds)
        rect.origin.x = contentInsets.left
        rect.origin.y = contentInsets.top
        rect.size.width -= contentInsets.width
        rect.size.height -= contentInsets.height
        
        return rect
    }
    
    override func editingRect(forBounds bounds: CGRect) -> CGRect {
        var rect = super.editingRect(forBounds: bounds)
        rect.origin.x = contentInsets.left
        rect.origin.y = contentInsets.top
        rect.size.width -= contentInsets.width
        rect.size.height -= contentInsets.height
        
        return rect
    }
    
    override func placeholderRect(forBounds bounds: CGRect) -> CGRect {
        var rect = super.placeholderRect(forBounds: bounds)
        rect.origin.x = contentInsets.left
        rect.origin.y = contentInsets.top
        rect.size.width -= contentInsets.width
        rect.size.height -= contentInsets.height
        
        return rect
    }
    
    override func canPerformAction(_ action: Selector, withSender sender: Any?) -> Bool {
        if let actions = forbiddenActions, actions.count > 0 {
            if actions.contains(action) {
                return false
            }
        }
        
        return super.canPerformAction(action, withSender: sender)
    }
}
