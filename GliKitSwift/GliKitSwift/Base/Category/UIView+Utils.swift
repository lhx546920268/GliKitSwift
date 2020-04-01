//
//  UIView+Utils.swift
//  GliKitSwift
//
//  Created by 罗海雄 on 2020/1/22.
//  Copyright © 2020 luohaixiong. All rights reserved.
//

import UIKit

public extension UIView {
    
    ///通过xib加载 xib的名称必须和类的名称一致
    static func loadFromNib<T: UIView>() -> T?{
        
        return Bundle.main.loadNibNamed(self.gkNameOfClass, owner: nil, options: nil)?.last as? T
    }
    
    ///删除所有子视图
    func gkRemoveAllSubviews() {
        for view in subviews {
            view.removeFromSuperview()
        }
    }

    ///安全区域 兼容ios 11
    var gkSafeAreaInsets: UIEdgeInsets {
        
        if #available(iOS 11, *) {
            return self.safeAreaInsets
        } else {
            return UIEdgeInsets.zero
        }
    }
    
    /**
    设置部分圆角
    
    @param cornerRadius 圆角
    @param corners 圆角位置
    @param rect 视图大小，如果使用autoLayout
    */
    func gkSetCornerRadius(_ cornerRadius: CGFloat, corners: UIRectCorner, rect: CGRect){
        
        if #available(iOS 11, *) {
            
            var maskedCorners = CACornerMask(rawValue: 0)
            
            if corners.contains(.topLeft) {
                maskedCorners.insert(.layerMinXMinYCorner)
            }

            if corners.contains(.topRight) {
                maskedCorners.insert(.layerMaxXMinYCorner)
            }

            if corners.contains(.bottomLeft) {
                maskedCorners.insert(.layerMinXMaxYCorner)
            }

            if corners.contains(.bottomRight) {
                maskedCorners.insert(.layerMaxXMaxYCorner)
            }
            
            layer.cornerRadius = cornerRadius
            layer.maskedCorners = [CACornerMask.layerMaxXMaxYCorner]
            layer.masksToBounds = true
        } else {
            
            var shapeLayer = layer.mask as? CAShapeLayer
            if shapeLayer == nil {
                shapeLayer = CAShapeLayer()
            }
            shapeLayer?.path = UIBezierPath(roundedRect: rect, byRoundingCorners: corners, cornerRadii: CGSize(width: cornerRadius, height: cornerRadius)).cgPath
            layer.mask = shapeLayer
        }
    }
}
