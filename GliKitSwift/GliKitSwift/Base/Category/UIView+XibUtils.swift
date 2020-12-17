//
//  UIView+XibUtils.swift
//  GliKitSwift
//
//  Created by 罗海雄 on 2020/4/27.
//  Copyright © 2020 luohaixiong. All rights reserved.
//

import UIKit

///基础视图xib扩展 可直接在xib上设置 圆角 边框
public extension UIView {

    ///圆角半径
    @IBInspectable
    var cornerRadius: CGFloat{
        set{
            self.layer.cornerRadius = newValue
        }
        get{
            self.layer.cornerRadius
        }
    }

    ///边框
    @IBInspectable
    var borderWidth: CGFloat{
        set{
            self.layer.borderWidth = newValue
        }
        get{
            self.layer.borderWidth
        }
    }

    ///边框颜色
    @IBInspectable
    var borderColor: UIColor{
        set{
            self.layer.borderColor = newValue.cgColor
        }
        get{
            if let cgColor = self.layer.borderColor {
                return UIColor(cgColor: cgColor)
            } else {
                return .black
            }
        }
    }

    ///layer.maskToBounds
    @IBInspectable
    var maskToBounds: Bool{
        set{
            self.layer.masksToBounds = newValue
        }
        get{
            self.layer.masksToBounds
        }
    }

}
