//
//  UIImage+Theme.swift
//  GliKitSwift
//
//  Created by 罗海雄 on 2020/1/19.
//  Copyright © 2020 luohaixiong. All rights reserved.
//

import UIKit

public extension UIImage {

    ///导航栏返回图标
    static var gkNavigationBarBackIcon: UIImage{
        set{
            _gkNavigationBarBackIcon = newValue
        }
        get{
            if _gkNavigationBarBackIcon == nil {
                
                var image = UIImage(named: "back_icon")
                if image == nil {
                    
                    let size = CGSize(width: 12, height: 20)
                    let lineWidth: CGFloat = 2.0
                    
                    UIGraphicsBeginImageContextWithOptions(size, false, UIScreen.main.scale)
                    
                    if let context = UIGraphicsGetCurrentContext() {
                        
                        context.setLineWidth(lineWidth)
                        context.setStrokeColor(UIColor.gkNavigationBarTintColor.cgColor)
                        
                        context.move(to: CGPoint(x: size.width, y: 0))
                        context.addLine(to: CGPoint(x: lineWidth / 2.0, y: size.height / 2.0))
                        context.addLine(to: CGPoint(x: size.width, y: size.height))
                        
                        context.strokePath()
                        image = UIGraphicsGetImageFromCurrentImageContext()
                    }

                    UIGraphicsEndImageContext()
                }
                
                //Template
                if image?.renderingMode != .alwaysTemplate {
                    image = image?.withRenderingMode(.alwaysTemplate)
                }
                _gkNavigationBarBackIcon = image
            }
            
            return _gkNavigationBarBackIcon!
        }
    }
    
    private static var _gkNavigationBarBackIcon: UIImage?
}
