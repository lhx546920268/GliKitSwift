//
//  UIView+AutoLayout.swift
//  GliKitSwift
//
//  Created by 罗海雄 on 2020/4/3.
//  Copyright © 2020 luohaixiong. All rights reserved.
//

import UIKit
import SnapKit

///autoLayout 计算大小方式
public enum AutoLayoutCalcType{
    
    ///计算宽度 需要给定高度
    case width
    
    ///计算高度 需要给定宽度
    case height
    
    ///计算大小，可给最大宽度和高度
    case size
};

///自动布局扩展
public extension UIView {
    
    ///判断是否存在约束
    var gkExistConstraints: Bool{
        if self.constraints.count > 0{
            return true
        }
        
        if let contraints = self.superview?.constraints {
            
            if contraints.count > 0 {
                for constraint in contraints {
                    if constraint.firstItem === self || constraint.secondItem === self {
                        return true
                    }
                }
            }
        }
        
        return false
    }
    
    ///清空约束
    func gkRemoveAllContraints(){
        
        removeConstraints(self.constraints)
        
        if let contraints = self.superview?.constraints {
            
            if contraints.count > 0 {
                var toClearContraints = [NSLayoutConstraint]()
                for constraint in contraints {
                    if constraint.firstItem === self || constraint.secondItem === self {
                        toClearContraints.append(constraint)
                    }
                }
                self.superview?.removeConstraints(toClearContraints)
            }
        }
    }
    
    // MARK: - 获取约束 constraint
    
    /**
     @warning 根据 item1.attribute1 = multiplier × item2.attribute2 + constant
     以下约束只根据 item1 和 attribute1 来获取
     */
    
    ///获取高度约束 返回当前优先级最高的
    var gkHeightLayoutConstraint: NSLayoutConstraint?{
        gkLayoutConstraint(forAttribute: .height)
    }
    
    ///获取宽度约束 返回当前优先级最高的
    var gkWidthLayoutConstraint: NSLayoutConstraint?{
        return gkLayoutConstraint(forAttribute: .width)
    }
    
    ///获取左边距约束 返回当前优先级最高的
    var gkLeftLayoutConstraint: NSLayoutConstraint?{
        if let constraint = gkLayoutConstraint(forAttribute: .leading) {
            return constraint
        } else {
            return gkLayoutConstraint(forAttribute: .left)
        }
    }
    
    ///获取右边距约束 返回当前优先级最高的
    var gkRightLayoutConstraint: NSLayoutConstraint?{
        if let constraint = gkLayoutConstraint(forAttribute: .trailing) {
            return constraint
        } else {
            return gkLayoutConstraint(forAttribute: .right)
        }
    }
    
    ///获取顶部距约束 返回当前优先级最高的
    var gkTopLayoutConstraint: NSLayoutConstraint?{
        gkLayoutConstraint(forAttribute: .top)
    }
    
    ///获取底部距约束 返回当前优先级最高的
    var gkBottomLayoutConstraint: NSLayoutConstraint?{
        return gkLayoutConstraint(forAttribute: .bottom)
    }
    
    ///获取水平居中约束 返回当前优先级最高的
    var gkCenterXLayoutConstraint: NSLayoutConstraint?{
        return gkLayoutConstraint(forAttribute: .centerX)
    }
    
    ///获取垂直居中约束 返回当前优先级最高的
    var gkCenterYLayoutConstraint: NSLayoutConstraint?{
        return gkLayoutConstraint(forAttribute: .centerY)
    }
    
    ///获取对应约束
    func gkLayoutConstraint(forAttribute attribute: NSLayoutConstraint.Attribute, secondItem: AnyObject? = nil) -> NSLayoutConstraint?{
        
        //符合条件的，可能有多个，取最高优先级的 忽略其子类
        var matchs = [NSLayoutConstraint]()
        
        switch attribute {
        case .width, .height :
            
            //宽高约束主要有 固定值，纵横比，等于某个item的宽高
            for constraint in self.constraints {
                //固定值，纵横比 放在本身
                if gkConformToConstraint(constraint) {
                    if constraint.firstAttribute == attribute && constraint.firstItem === self && constraint.secondAttribute == .notAnAttribute {
                        //忽略纵横比
                        matchs.append(constraint)
                    }
                }
            }
            
            if matchs.count == 0 {
                //等于某个item的宽高 放在父视图
                if let constraints = self.superview?.constraints {
                    for constraint in constraints {
                        if gkConformToConstraint(constraint) {
                            if (constraint.firstAttribute == attribute && constraint.firstItem === self) || (constraint.secondAttribute == attribute && constraint.secondItem === self) {
                                //忽略纵横比
                                matchs.append(constraint)
                            }
                        }
                    }
                }
                
            }
            
        case .left, .leading, .top :
            
            //左上 约束 必定在父视图
            //item1.attribute1 = item2.attribute2 + constant
            //item2.attribute2 = item1.attribute1 - constant
            if let constraints = self.superview?.constraints {
                for constraint in constraints {
                    if gkConformToConstraint(constraint) {
                        if constraint.firstItem === self && constraint.firstAttribute == attribute {
                            matchs.append(constraint)
                        } else if constraint.secondItem === self && constraint.secondAttribute == attribute {
                            matchs.append(constraint)
                        }
                    }
                }
            }
            
        case .right, .trailing, .bottom :
            
            //右下约束 必定在父视图
            //item1.attribute1 = item2.attribute2 - constant
            //item2.attribute2 = item1.attribute1 + constant
            if let constraints = self.superview?.constraints {
                for constraint in constraints {
                    if gkConformToConstraint(constraint) {
                        if constraint.firstItem === self && constraint.firstAttribute == attribute {
                            matchs.append(constraint)
                        } else if constraint.secondItem === self && constraint.secondAttribute == attribute {
                            matchs.append(constraint)
                        }
                    }
                }
            }
            
        case .centerX, .centerY :
            
            //居中约束 必定在父视图
            if let constraints = self.superview?.constraints {
                for constraint in constraints {
                    if gkConformToConstraint(constraint) {
                        if constraint.firstItem === self && constraint.firstAttribute == attribute {
                            matchs.append(constraint)
                        }
                    }
                }
            }
        default:
            break;
        }
        
        var layoutConstraint = matchs.first
        //符合的约束太多，拿优先级最高的
        for i in 1 ..< matchs.count {
            let constraint = matchs[i]
            if secondItem != nil {
                if constraint.secondItem !== secondItem && constraint.firstItem !== secondItem {
                    continue
                }
            }
            
            if layoutConstraint!.priority < constraint.priority {
                layoutConstraint = constraint
            }
        }
        
        return layoutConstraint
    }
    
    ///判断是否是自己设定的约束
    private func gkConformToConstraint(_ constraint: NSLayoutConstraint) -> Bool{
        
        return constraint.isMember(of: NSLayoutConstraint.self) || constraint.isMember(of: LayoutConstraint.self)
    }
    
    // MARK: - AutoLayout 计算大小
    
    /**
     *根据给定的 size 计算当前view的大小，要使用auto layout
     
     *@param fitsSize 大小范围 0 则不限制范围
     *@param type 计算方式
     *@return view 大小
     */
    func gkSizeThatFits(_ fitsSize: CGSize, type: AutoLayoutCalcType) -> CGSize{
        
        var size = CGSize.zero
        if type != .size {
            //添加临时约束
            let constraint = NSLayoutConstraint(item: self, attribute: type == .height ? .width : .height, relatedBy: .equal, toItem: nil, attribute: .notAnAttribute, multiplier: 1, constant: type == .height ? fitsSize.width : fitsSize.height)
            addConstraint(constraint)
            size = systemLayoutSizeFitting(UIView.layoutFittingCompressedSize)
            removeConstraint(constraint)
            
        }else{
            //添加临时约束
            var constraint: NSLayoutConstraint? = nil
            if fitsSize != CGSize.zero {
                constraint = NSLayoutConstraint(item: self, attribute: fitsSize.width != 0 ? .width : .height, relatedBy: .equal, toItem: nil, attribute: .notAnAttribute, multiplier: 1, constant: fitsSize.width != 0 ? fitsSize.width : fitsSize.height)
                addConstraint(constraint!)
            }
            
            size = systemLayoutSizeFitting(UIView.layoutFittingCompressedSize)
            
            if(constraint != nil){
                removeConstraint(constraint!)
            }
        }
        
        return size
    }
}
