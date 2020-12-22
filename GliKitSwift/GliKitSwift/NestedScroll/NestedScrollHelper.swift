//
//  NestedScrollHelper.swift
//  GliKitSwift
//
//  Created by 罗海雄 on 2020/10/23.
//  Copyright © 2020 luohaixiong. All rights reserved.
//

import UIKit

///嵌套滑动帮助类
internal class NestedScrollHelper: NSObject, UIScrollViewDelegate {
    
    ///父scrollView 是否可以滑动
    public var parentScrollEnable: Bool = true

    ///子scrollView 是否可以滑动
    public var childScrollEnable: Bool = true

    ///父容器
    public weak var parentScrollView: UIScrollView?

    ///是否正在模拟系统自动滑动
    public var isAutoScrolling: Bool {
        displayLink != nil
    }
    
    ///监听屏幕刷新
    private var displayLink: CADisplayLink?

    ///当前滑动状态
    private var status: Status = .none

    ///父容器最大滑动位置
    private var parentMaxOffset: CGFloat = 0

    ///每帧 毫秒数
    private var timePerFrame: CGFloat = 0

    ///当前速度
    private var currentSpeed: CGFloat = 0

    ///帧数
    private var frames: CGFloat = 0

    ///用户触摸屏幕了
    public func onTouchScreen() {
        stopDisplayLink()
    }

    /**
     替换某个方法的实现 新增的方法要加一个前缀gkNestedScroll
     
     @param selector 要替换的方法
     @param owner 方法的拥有者
     @param implementer 新方法的实现者
     */
    public static func replaceImplementations(_ selector: Selector, owner: NSObject, implementer: NSObject) {
        let ownerCls = owner.classForCoder as! NSObject.Type
        if owner.responds(to: selector) {
            let method1 = class_getInstanceMethod(ownerCls, selector)!
            let selector2 = Selector("gkNestedScroll_\(NSStringFromSelector(selector))")
            
            //给代理 添加一个 方法名为 gkNestedScroll_ 前缀的，但是实现还是 代理的实现的方法
            if class_addMethod(ownerCls, selector2, method_getImplementation(method1), method_getTypeEncoding(method1)) {
                //替换代理中的方法为 gkNestedScroll_ 前缀的方法
                let method2 = class_getInstanceMethod(implementer.classForCoder, selector2)!
                class_replaceMethod(ownerCls, selector, method_getImplementation(method2), method_getTypeEncoding(method2))
            }
        } else {
            let selector2 = Selector("gkNestedScrollAdd_\(NSStringFromSelector(selector))")
            let method = class_getInstanceMethod(implementer.classForCoder, selector2)!
            class_addMethod(ownerCls, selector, method_getImplementation(method), method_getTypeEncoding(method))
        }
    }
    
    // MARK: - Display Link

    ///开始监听屏幕刷新
    private func startDisplayLink() {
        stopDisplayLink()
        
        displayLink = CADisplayLink(target: WeakProxy(target: self), selector: #selector(handleLink))
        //60FPS
        timePerFrame = 17
        displayLink?.add(to: .main, forMode: .common)
    }
    
    ///停止监听
    private func stopDisplayLink() {
        displayLink?.invalidate()
        displayLink = nil
    }
    
    ///处理屏幕刷新
    @objc private func handleLink() {
        if let parentScrollView = self.parentScrollView {
            //每帧 毫秒数
            frames += 1
            if frames * timePerFrame >= 100 {
                //每100毫秒衰减一次
                frames = 0
                currentSpeed *= NestedScrollHelper.nestedScrollSlowDampingRaito
            }
            
            //速度低于这个值就停止了
            if currentSpeed <= 0.01 {
                stopDisplayLink()
                return;
            }
            
            //父容器滑动到最大值后就滑动child
            if parentScrollView.contentOffset.y >= parentMaxOffset {
                if let scrollView = parentScrollView.gkNestedChildScrollView {
                    var y = scrollView.contentOffset.y + currentSpeed * timePerFrame
                    var contentOffset = scrollView.contentOffset;
                    if y + scrollView.gkHeight >= scrollView.contentSize.height {
                        y = scrollView.contentSize.height - scrollView.gkHeight
                        stopDisplayLink()
                    }
                    contentOffset.y = y
                    scrollView.contentOffset = contentOffset
                }
            }else{
                let y = parentScrollView.contentOffset.y + currentSpeed * timePerFrame
                var contentOffset = parentScrollView.contentOffset
                contentOffset.y = min(parentMaxOffset, y)
                parentScrollView.contentOffset = contentOffset
            }
        }
    }
    
    deinit {
        stopDisplayLink()
    }

    // MARK: - UIScrollViewDelegate

    public func scrollViewDidScroll(_ scrollView: UIScrollView) {
        if let parentScrollView = self.parentScrollView {
            let maxOffsetY = floor(parentScrollView.contentSize.height - parentScrollView.gkHeight)
            guard let child = parentScrollView.gkNestedChildScrollView, maxOffsetY > 0, child.contentSize.height > 0 else {
                return
            }
            
            let isParent = scrollView == parentScrollView
            let contentOffset = scrollView.contentOffset
            if isParent {
            
                let childRefreshEnable = child.gkRefreshControl != nil
                
                //下拉刷新中
                if child.contentOffset.y < 0 && childRefreshEnable {
                    scrollView.contentOffset = .zero
                    return
                }
                
                let offset = contentOffset.y - maxOffsetY
                
                //已经滑出顶部范围了，让子容器滑动
                if offset >= 0 {
                    scrollView.contentOffset = CGPoint(0, maxOffsetY)
                    if parentScrollEnable {
                        parentScrollEnable = false
                        childScrollEnable = true
                    }
                }else{
                    //不能让父容器继续滑动了
                    if !parentScrollEnable {
                        scrollView.contentOffset = CGPoint(0, maxOffsetY)
                    }
                }
                
                //到顶部了，应该要下拉刷新了
                if scrollView.contentOffset.y <= 0 {
            
                    if childRefreshEnable {
                        childScrollEnable = true
                        scrollView.contentOffset = .zero
                    }
                }
                
            }else{
                
                let enable = scrollView.gkRefreshControl != nil ? parentScrollView.contentOffset.y > 0 : true
                //滚动容器还在滑动中
                if !childScrollEnable || (enable && parentScrollView.contentOffset.y < maxOffsetY) {
                    scrollView.contentOffset = .zero
                    return
                }
                
                //滑到滚动容器了滚动容器
                if contentOffset.y <= 0 && parentScrollView.contentOffset.y > 0 {
                    scrollView.contentOffset = .zero
                    childScrollEnable = false
                    parentScrollEnable = true
                    parentScrollView.gkChildDidScrollToParent?()
                }
            }
        }
    }

    public func scrollViewWillEndDragging(_ scrollView: UIScrollView, withVelocity velocity: CGPoint, targetContentOffset: UnsafeMutablePointer<CGPoint>) {
        //主要是为了 滑动父容器时 可以促使child滑动 只有向下滑动时才需要
        let maxOffsetY = floor(scrollView.contentSize.height - scrollView.gkHeight)
        if velocity.y <= 0 || scrollView.contentOffset.y >= maxOffsetY {
            return
        }
        
        var i: CGFloat = 0
        var speed = velocity.y
        while speed > 0.01 {
            
            speed *= NestedScrollHelper.nestedScrollSlowDampingRaito
            i += 1
        }
        
        //估算滑动距离超过容器可滑动距离的最大值时，模拟系统的滑动
        //解决当快速滑动的时候 两个ScrollView 不连贯的问题
        if floor(i * 100.0 * velocity.y + scrollView.contentOffset.y) > maxOffsetY {
            //模拟系统的滑动减速衰减
            parentMaxOffset = maxOffsetY
            status = .began
            frames = 0
            currentSpeed = velocity.y
            targetContentOffset.pointee = scrollView.contentOffset
            
            startDisplayLink()
        }
    }
}

extension NestedScrollHelper {
    
    ///减速衰减比例
    private static let nestedScrollSlowDampingRaito: CGFloat = 0.81
    
    ///手动设置contentOffset状态
    private enum Status {
        
        ///什么都没
        case none
        
        ///开始自动设置contentOffset
        case began
        
        ///offset的范围已经超出contentSize了， 慢慢向前进，达到一定值回弹
        case bounceForward
        
        ///回弹了
        case bounceBack
    }
}
