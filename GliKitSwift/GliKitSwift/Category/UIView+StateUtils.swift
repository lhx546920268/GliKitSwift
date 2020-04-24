//
//  UIView+StateUtils.swift
//  GliKitSwift
//
//  Created by 罗海雄 on 2020/3/24.
//  Copyright © 2020 luohaixiong. All rights reserved.
//

import UIKit

private var backgroundColorKey: UInt8 = 0
private var tintColorKey: UInt8 = 0

///状态 不支持多个状态并存，disable > highlighted > selected > normal 目前只对 UIButton UILabel UIImageView 有用
public extension UIView{
    
    ///状态背景
    var gkBackgroundColorsForState: NSMutableDictionary?{
        get{
            return objc_getAssociatedObject(self, &backgroundColorKey) as? NSMutableDictionary
        }
    }

    ///状态tintColor
    var gkTintColorsForState: NSMutableDictionary?{
        get{
            return objc_getAssociatedObject(self, &tintColorKey) as? NSMutableDictionary
        }
    }

    ///获取当前背景颜色
    var gkCurrentBackgroundColor: UIColor?{
        get{
            var color = self.gkBackgroundColorsForState?[UIControl.State.normal] as? UIColor
            
            if color == nil {
                color = self.backgroundColor
            }
            return color
        }
    }

    ///获取当前 tintColor
    var gkCurrentTintColor: UIColor{
        get{
            var color = self.gkTintColorsForState?[UIControl.State.normal] as? UIColor
            
            if color == nil {
                color = self.tintColor
            }
            return color!
        }
    }

    ///当前状态
    @objc var gkState: UIControl.State{
        get{
            return .normal
        }
    }
    
    ///状态改变
    fileprivate func gkStateDidChange(){
        self.gkAdjustsBackgroundColor()
        self.gkAdjustsTintColor()
    }
    
    /**
     设置对应状态的背景颜色

     @param backgroundColor 背景颜色，为nil时移除
     @param state 状态，支持  UIControlStateNormal， UIControlStateHighlighted，UIControlStateDisabled，UIControlStateSelected
     */
    @objc func gkSetBackgroundColor(_ backgroundColor: UIColor?, state: UIControl.State){
        
        gkStateSwizzlingIfNeeded()
        
        var dic = self.gkBackgroundColorsForState
        if backgroundColor == nil && dic == nil {
            return
        }
        
        if dic == nil {
            dic = NSMutableDictionary()
            objc_setAssociatedObject(self, &backgroundColorKey, dic, .OBJC_ASSOCIATION_RETAIN_NONATOMIC);
        }
        
        dic![state] = backgroundColor
        
        if self.gkState == state {
            self.gkAdjustsBackgroundColor()
        }
    }
    
    ///调整背景颜色
    func gkAdjustsBackgroundColor(){
        if let dic = self.gkBackgroundColorsForState, dic.count > 0 {
            self.backgroundColor = self.gkCurrentBackgroundColor;
        }
    }

    /**
     设置对应状态的tintColor

     @param tintColor 颜色，为nil时移除
     @param state 状态，支持  UIControlStateNormal， UIControlStateHighlighted，UIControlStateDisabled，UIControlStateSelected
     */
    func gkSetTintColor(_ tintColor: UIColor?, state: UIControl.State){
        
        gkStateSwizzlingIfNeeded()
        
        var dic = self.gkTintColorsForState
         if tintColor == nil && dic == nil {
             return
         }
         
         if dic == nil {
             dic = NSMutableDictionary()
             objc_setAssociatedObject(self, &tintColorKey, dic, .OBJC_ASSOCIATION_RETAIN_NONATOMIC);
         }
         
         dic![state] = backgroundColor
         
         if self.gkState == state {
             self.gkAdjustsTintColor()
         }
    }
    
    ///调整背景颜色
    func gkAdjustsTintColor(){
        if let dic = self.gkTintColorsForState, dic.count > 0 {
            self.tintColor = self.gkCurrentTintColor;
        }
    }
    
    ///方法交换
    @objc func gkStateSwizzlingIfNeeded() {
        
    }
}

public extension UIButton{
    
    override func gkStateSwizzlingIfNeeded() {
        
        DispatchQueue.once(token: "UIButton.GKState") {
            swizzling(selector1: #selector(setter: isHighlighted), cls1: UIButton.self, selector2: #selector(self.gkSetHighlighted(_:)), cls2: UIButton.self)
            swizzling(selector1: #selector(setter: isSelected), cls1: UIButton.self, selector2: #selector(self.gkSetSelected(_:)), cls2: UIButton.self)
            swizzling(selector1: #selector(setter: isEnabled), cls1: UIButton.self, selector2: #selector(self.gkSetEnabled(_:)), cls2: UIButton.self)
        }
    }
    
    // MARK: - 状态

    override var gkState: UIControl.State{
        return self.state
    }

    @objc private func gkSetHighlighted(_ highlighted: Bool){
        gkSetHighlighted(highlighted)
        gkStateDidChange()
    }
    
    @objc private func gkSetSelected(_ selected: Bool){
        gkSetSelected(selected)
        gkStateDidChange()
    }
    
    @objc private func gkSetEnabled(_ enabled: Bool){
        gkSetEnabled(enabled)
        gkStateDidChange()
    }
}

public extension UIImageView{
    
    override func gkStateSwizzlingIfNeeded() {
        
        DispatchQueue.once(token: "UIImageView.GKState") {
            swizzling(selector1: #selector(setter: isHighlighted), cls1: UIButton.self, selector2: #selector(self.gkSetHighlighted(_:)), cls2: UIButton.self)
        }
    }
    
    override func gkSetBackgroundColor(_ backgroundColor: UIColor?, state: UIControl.State) {
        
        if (self.isHighlighted && state == .highlighted) || (!self.isHighlighted && state == .normal) {
            self.backgroundColor = self.gkCurrentBackgroundColor
        }
    }
    
    // MARK: - 状态

    override var gkState: UIControl.State{
        return self.isHighlighted ? .highlighted : .normal
    }

    @objc private func gkSetHighlighted(_ highlighted: Bool){
        gkSetHighlighted(highlighted)
        gkStateDidChange()
    }
}

public extension UILabel{
    
    override func gkStateSwizzlingIfNeeded() {
        
        DispatchQueue.once(token: "UILabel.GKState") {
            swizzling(selector1: #selector(setter: isHighlighted), cls1: UIButton.self, selector2: #selector(self.gkSetHighlighted(_:)), cls2: UIButton.self)
            swizzling(selector1: #selector(setter: isEnabled), cls1: UIButton.self, selector2: #selector(self.gkSetEnabled(_:)), cls2: UIButton.self)
        }
    }
    
    // MARK: - 状态

    override var gkState: UIControl.State{
        if !self.isEnabled {
            return .disabled
        }
        
        if self.isHighlighted {
            return .highlighted
        }
        
        return .normal
    }

    @objc private func gkSetHighlighted(_ highlighted: Bool){
        gkSetHighlighted(highlighted)
        gkStateDidChange()
    }
    
    @objc private func gkSetSelected(_ selected: Bool){
        gkSetSelected(selected)
        gkStateDidChange()
    }
    
    @objc private func gkSetEnabled(_ enabled: Bool){
        gkSetEnabled(enabled)
        gkStateDidChange()
    }
}
