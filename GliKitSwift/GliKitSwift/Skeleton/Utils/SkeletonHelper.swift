//
//  SkeletonHelper.swift
//  GliKitSwift
//
//  Created by 罗海雄 on 2020/10/21.
//  Copyright © 2020 luohaixiong. All rights reserved.
//

import UIKit

///骨架帮助类
class SkeletonHelper {
    
    /**
     是否需要成为骨架视图

     @param view 视图
     @return 是否成为骨架图层
     */
    static func shouldBecomeSkeleton(_ view: UIView) -> Bool {
        if view.isHidden || view.alpha < 0.01 {
            return false
        }
        
        if view.isMember(of: UIView.self) && (view.backgroundColor == nil || view.backgroundColor!.isEqualToColor(.clear)) {
            return false
        }
        
        return view is UILabel || view is UIImageView || view is UIButton
    }
    
    /**
     创建骨架图层

     @param layers 骨架图层数组
     @param view 要成为骨架图层的视图
     @param rootView 根视图
     */
    static func createLayers(_ layers: NSMutableArray, fromView: UIView, rootView: UIView) {
        let subviews = fromView.subviews
        
        if subviews.count > 0 {
            for subview in subviews {
                createLayers(layers, fromView: subview, rootView: rootView)
            }
        }else if fromView != rootView {
            
            if !fromView.gkShouldBecomeSkeleton {
                return
            }
            
            var rect: CGRect
            if fromView.superview == rootView {
                rect = fromView.frame
            }else{
                rect = fromView.superview!.convert(fromView.frame, to: rootView)
            }
            
            let layer = SkeletonSubLayer()
            layer.frame = rect
            layer.copyProperties(from: fromView.layer)
            layers.add(layer)
        }
    }
 
    /**
     替换某个方法的实现 新增的方法要加一个前缀gkSkeleton_

     @param selector 要替换的方法
     @param owner 方法的拥有者
     @param implementer 新方法的实现者
     */
    static func replaceImplementations(selector: Selector, owner: NSObject, implementer: NSObject) {
        
        let ownerCls = owner.classForCoder as! NSObject.Type
        let str = NSStringFromSelector(selector)
        
        if owner.responds(to: selector) {
            let method1 = class_getInstanceMethod(ownerCls, selector)!
            let selector2 = Selector("gkSkeleton_\(str)")
            
            //给代理 添加一个 方法名为 gkSkeleton_ 前缀的，但是实现还是 代理的实现的方法
            if class_addMethod(ownerCls, selector2, method_getImplementation(method1), method_getTypeEncoding(method1)) {
                //替换代理中的方法为 gkSkeleton_ 前缀的方法
                let method2 = class_getInstanceMethod(implementer.classForCoder, selector2)!
                class_replaceMethod(ownerCls, selector, method_getImplementation(method2), method_getTypeEncoding(method2))
            }
        } else {
            //让UITableView UICollectionView 在显示骨架过程中不能点击 cell
            if selector == #selector(UITableViewDelegate.tableView(_:shouldHighlightRowAt:))
                || selector == #selector(UICollectionViewDelegate.collectionView(_:shouldHighlightItemAt:)) {
                
                let selector2 = Selector("gkSkeletonAdd_\(str)")
                let method = class_getInstanceMethod(implementer.classForCoder, selector2)!
                
                class_addMethod(ownerCls, selector, method_getImplementation(method), method_getTypeEncoding(method))
            }
        }
    }
}
