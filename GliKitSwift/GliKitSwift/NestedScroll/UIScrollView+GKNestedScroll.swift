//
//  UIScrollView+GKNestedScroll.swift
//  GliKitSwift
//
//  Created by 罗海雄 on 2020/10/23.
//  Copyright © 2020 luohaixiong. All rights reserved.
//

import UIKit

private var nestedScrollEnableKey: Int8 = 0
private var nestedParentKey: Int8 = 0
private var childDidScrollToParentKey: Int8 = 0
private var nestedParentScrollViewKey: Int8 = 0
private var nestedChildScrollViewKey: Int8 = 0
private var nestedScrollHelperKey: Int8 = 0

///找到嵌套滑动容器
private func findNestedParentScrollView(from child: UIView?) -> UIScrollView?{
    if child?.superview == nil {
        return nil
    }
    
    let scrollView = child?.superview as? UIScrollView
    if scrollView != nil && scrollView!.gkNestedParent {
        return scrollView
    }else{
        return findNestedParentScrollView(from: scrollView)
    }
}

///嵌套滚动扩展
public extension UIScrollView {
    
    ///是否可以嵌套滑动 需要手动设置 child和parent都要设置这个
    var gkNestedScrollEnable: Bool {
        set{
            objc_setAssociatedObject(self, &nestedScrollEnableKey, newValue, .OBJC_ASSOCIATION_RETAIN_NONATOMIC)
            gkNestedScrollSwizzle()
        }
        get{
            objc_getAssociatedObject(self, &nestedScrollEnableKey) as? Bool ?? false
        }
    }

    ///是否是嵌套滑动容器 需要手动设置
    var gkNestedParent: Bool {
        set{
            objc_setAssociatedObject(self, &nestedParentKey, newValue, .OBJC_ASSOCIATION_RETAIN_NONATOMIC)
        }
        get{
            objc_getAssociatedObject(self, &nestedParentKey) as? Bool ?? false
        }
    }

    ///滑动到父容器了 在父容器设置
    var gkChildDidScrollToParent: VoidCallback? {
        set{
            objc_setAssociatedObject(self, &childDidScrollToParentKey, newValue, .OBJC_ASSOCIATION_COPY_NONATOMIC)
        }
        get{
           objc_getAssociatedObject(self, &childDidScrollToParentKey) as? VoidCallback
        }
    }

    ///当前嵌套滑动容器，如果没设置，会自动寻找
    var gkNestedParentScrollView: UIScrollView? {
        set{
            let container: WeakObjectContainer? = newValue != nil ? WeakObjectContainer(weakObject: newValue!) : nil
            objc_setAssociatedObject(self, &nestedParentScrollViewKey, container, .OBJC_ASSOCIATION_RETAIN_NONATOMIC)
        }
        get{
            let container = objc_getAssociatedObject(self, &nestedParentScrollViewKey) as? WeakObjectContainer
            var scrollView = container?.weakObject as? UIScrollView
            
            if scrollView == nil {
                scrollView = findNestedParentScrollView(from: self)
                if scrollView != nil {
                    objc_setAssociatedObject(self, &nestedParentScrollViewKey, WeakObjectContainer(weakObject: scrollView!), .OBJC_ASSOCIATION_RETAIN_NONATOMIC)
                }
            }
            
            return scrollView
        }
    }

    ///当前嵌套滑动的子视图 需要手动设置，有多个时要动态设置 可通过 `self.scrollView.gkNestedParentScrollView.gkNestedChildScrollView = self.scrollView` 来设置
    var gkNestedChildScrollView: UIScrollView? {
        set{
            let container: WeakObjectContainer? = newValue != nil ? WeakObjectContainer(weakObject: newValue!) : nil
            objc_setAssociatedObject(self, &nestedChildScrollViewKey, container, .OBJC_ASSOCIATION_RETAIN_NONATOMIC)
        }
        get{
            let container = objc_getAssociatedObject(self, &nestedChildScrollViewKey) as? WeakObjectContainer
            return container?.weakObject as? UIScrollView
        }
    }

    ///内部用，嵌套滑动帮助类 只有嵌套滑动容器才有这个
    internal var gkNestedScrollHelper: NestedScrollHelper? {
        var helper: NestedScrollHelper?
        var parent: UIScrollView?
        let isParent = gkNestedParent
        if isParent {
            helper = objc_getAssociatedObject(self, &nestedScrollHelperKey) as? NestedScrollHelper
        }else{
            parent = gkNestedParentScrollView
            if parent != nil {
                helper = objc_getAssociatedObject(parent!, &nestedScrollHelperKey) as? NestedScrollHelper
            }
        }
        if helper == nil {
            helper = NestedScrollHelper()
            if isParent {
                helper?.parentScrollView = self
                objc_setAssociatedObject(self, &nestedScrollHelperKey, helper, .OBJC_ASSOCIATION_RETAIN_NONATOMIC)
            }else{
                if parent != nil {
                    helper?.parentScrollView = parent
                    objc_setAssociatedObject(parent!, &nestedScrollHelperKey, helper, .OBJC_ASSOCIATION_RETAIN_NONATOMIC)
                }
            }
        }
        
        return helper;
    }

    
    // MARK: - Swizzle
    
    ///方法交换
    private func gkNestedScrollSwizzle() {
        if let delegate = self.delegate as? NSObject, gkNestedScrollEnable {
            NestedScrollHelper.replaceImplementations(#selector(UIScrollViewDelegate.scrollViewDidScroll(_:)), owner: delegate, implementer: self)
            NestedScrollHelper.replaceImplementations(#selector(UIScrollViewDelegate.scrollViewWillEndDragging(_:withVelocity:targetContentOffset:)), owner: delegate, implementer: self)
        }
    }
    
    internal static func swizzleNestedScrollMethod() {
        swizzling(selector1: #selector(gkNestedScrollSetDelegate(_:)), selector2: #selector(setter: delegate), cls1: self)
        swizzling(selector1: #selector(gkNestedScrollTouchesShouldBegin(_:with:in:)), selector2: #selector(touchesShouldBegin(_:with:in:)), cls1: self)
    }
    
    @objc private func gkNestedScrollSetDelegate(_ delegate: UIScrollViewDelegate?) {
        gkNestedScrollSetDelegate(delegate)
        gkNestedScrollSwizzle()
    }
    
    @objc private func gkNestedScrollTouchesShouldBegin(_ touches: Set<UITouch>, with event: UIEvent?, in view: UIView) -> Bool {
        if gkNestedScrollEnable && gkNestedScrollHelper?.isAutoScrolling ?? false {
            gkOnTouchScrollView()
            return false
        }
        
        return gkNestedScrollTouchesShouldBegin(touches, with: event, in: view)
    }

    ///触摸了
    private func gkOnTouchScrollView(){
        if gkNestedScrollEnable {
            gkNestedScrollHelper?.onTouchScreen()
        }
    }
    
    // MARK: - UIScrollViewDelegate
    
    @objc private func gkNestedScrollAdd_scrollViewDidScroll(_ scrollView: UIScrollView) {
        if scrollView.gkNestedScrollEnable {
            scrollView.gkNestedScrollHelper?.scrollViewDidScroll(scrollView)
        }
    }
    
    @objc private func gkNestedScroll_scrollViewDidScroll(_ scrollView: UIScrollView) {
        if scrollView.gkNestedScrollEnable {
            scrollView.gkNestedScrollHelper?.scrollViewDidScroll(scrollView)
        }
        
        gkNestedScroll_scrollViewDidScroll(scrollView)
    }
    
    @objc private func gkNestedScrollAdd_scrollViewWillEndDragging(_ scrollView: UIScrollView, withVelocity velocity: CGPoint, targetContentOffset: UnsafeMutablePointer<CGPoint>) {
        if scrollView.gkNestedScrollEnable && scrollView.gkNestedParent {
            scrollView.gkNestedScrollHelper?.scrollViewWillEndDragging(scrollView, withVelocity: velocity, targetContentOffset: targetContentOffset)
        }
    }

    @objc private func gkNestedScroll_scrollViewWillEndDragging(_ scrollView: UIScrollView, withVelocity velocity: CGPoint, targetContentOffset: UnsafeMutablePointer<CGPoint>) {
        if scrollView.gkNestedScrollEnable && scrollView.gkNestedParent {
            scrollView.gkNestedScrollHelper?.scrollViewWillEndDragging(scrollView, withVelocity: velocity, targetContentOffset: targetContentOffset)
        }
        
        gkNestedScroll_scrollViewWillEndDragging(scrollView, withVelocity: velocity, targetContentOffset: targetContentOffset)
    }
}

extension UIScrollView: UIGestureRecognizerDelegate {
 
    ///允许手势冲突
    public func gestureRecognizer(_ gestureRecognizer: UIGestureRecognizer, shouldRecognizeSimultaneouslyWith otherGestureRecognizer: UIGestureRecognizer) -> Bool {
        //只有平移手势才允许手势冲突
        if gestureRecognizer == panGestureRecognizer && gkNestedParent {
            return otherGestureRecognizer == gkNestedChildScrollView?.panGestureRecognizer
        }
        return false
    }
}
