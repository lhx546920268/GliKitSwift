//
//  UIView+Skeleton.swift
//  GliKitSwift
//
//  Created by 罗海雄 on 2020/10/21.
//  Copyright © 2020 luohaixiong. All rights reserved.
//

import UIKit

private var shouldBecomeSkeletonKey: UInt8 = 0
private var skeletonStatusKey: UInt8 = 0
private var skeletonLayerKey: UInt8 = 0
private var skeletonAnimationHelperKey: UInt8 = 0
private var skeletonHideAnimatedKey: UInt8 = 0

//骨架状态
public enum SkeletonStatus{
    
    ///什么都没
    case none
    
    ///准备要显示了
    case willShow
    
    ///正在显示
    case showing
    
    ///将要隐藏了
    case willHide
}

///为视图创建骨架扩展
public extension UIView {
    
    ///是否需要添加为骨架图层 子视图用的
    var gkShouldBecomeSkeleton: Bool {
        set{
            objc_setAssociatedObject(self, &shouldBecomeSkeletonKey, newValue, .OBJC_ASSOCIATION_RETAIN_NONATOMIC)
        }
        get{
            let value = objc_getAssociatedObject(self, &shouldBecomeSkeletonKey) as? Bool
            if value != nil {
                return value!
            }
            
            return SkeletonHelper.shouldBecomeSkeleton(self)
        }
    }
    
    ///骨架显示状态 根视图用 内部使用 不要直接设置这个值
    var gkSkeletonStatus: SkeletonStatus {
        set{
            objc_setAssociatedObject(self, &skeletonStatusKey, newValue, .OBJC_ASSOCIATION_RETAIN_NONATOMIC)
        }
        get{
            objc_getAssociatedObject(self, &skeletonStatusKey) as? SkeletonStatus ?? .none
        }
    }

    ///骨架图层
    var gkSkeletonLayer: SkeletonLayer? {
        set{
            if let layer = gkSkeletonLayer {
                layer.removeFromSuperlayer()
            }
            
            if newValue == nil {
                isUserInteractionEnabled = true
                gkSkeletonStatus = .none
                gkSkeletonAnimationHelper = nil
            }
            
            objc_setAssociatedObject(self, &skeletonLayerKey, newValue, .OBJC_ASSOCIATION_RETAIN_NONATOMIC);
        }
        get{
            objc_getAssociatedObject(self, &skeletonLayerKey) as? SkeletonLayer
        }
    }
    
    ///是否需要添加骨架图层 某些视图会自己处理 默认YES
    var gkShouldAddSkeletonLayer: Bool {
        get{
            //列表 和 集合视图 使用他们的cell header footer 来生成
            if self is UITableView || self is UICollectionView {
                return false
            }
            return true
        }
    }
    
    ///骨架层动画帮助类
    private var gkSkeletonAnimationHelper: SkeletonAnimationHelper? {
        get{
            var helper = objc_getAssociatedObject(self, &skeletonAnimationHelperKey) as? SkeletonAnimationHelper
            if helper == nil {
                helper = SkeletonAnimationHelper()
                objc_setAssociatedObject(self, &skeletonAnimationHelperKey, helper, .OBJC_ASSOCIATION_RETAIN_NONATOMIC)
            }
            return helper
        }
        set{
            objc_setAssociatedObject(self, &skeletonAnimationHelperKey, newValue, .OBJC_ASSOCIATION_RETAIN_NONATOMIC)
        }
    }
    
    // MARK: - Swizzle
    
    ///用于骨架层的方法交换
    internal static func swizzleSkeletonMethod() {
        swizzleUIViewSkeleton()
        UITableView.swizzleUITableViewSkeleton()
        UICollectionView.swizzleUICollectionViewSkeleton()
    }
    
    internal static func swizzleUIViewSkeleton() {
        swizzling(selector1: #selector(gkSkeletonLayoutSubviews), selector2: #selector(layoutSubviews), cls1: self)
    }
    
    @objc private func gkSkeletonLayoutSubviews() {
        gkSkeletonLayoutSubviews()
        if gkSkeletonStatus == .willShow && gkShouldAddSkeletonLayer {
            DispatchQueue.main.async {
                self.gkSkeletonStatus = .showing
                
                let layer = SkeletonLayer()
                let layers = NSMutableArray()
                
                SkeletonHelper.createLayers(layers, fromView: self, rootView: self)
                layer.skeletonSubLayers = layers
                layer.frame = self.bounds
                self.layer.addSublayer(layer)
                self.gkSkeletonLayer = layer
            }
        }
    }

    
    /// 显示骨架层
    /// - Parameters:
    ///   - duration: 显示时长，如果大于0，则在一定时候后回调
    ///   - completion: 回调
    @objc func gkShowSkeleton(duration: Double = 0, completion: VoidCallback? = nil) {
        if gkSkeletonStatus == .none {
            gkSkeletonStatus = .willShow
            if gkShouldAddSkeletonLayer {
                isUserInteractionEnabled = false
                setNeedsLayout()
            }
            if duration > 0 && completion != nil {
                DispatchQueue.main.asyncAfter(deadline: DispatchTime(floatLiteral: duration), execute: completion!)
            }
        }
    }
   
    ///隐藏骨架
    @objc func gkHideSkeleton(animate: Bool = true, completion: VoidCallback? = nil) {
        let status = gkSkeletonStatus
        if status == .showing || status == .willShow {
            if animate {
                gkSkeletonStatus = .willHide
                if let layer = gkSkeletonLayer {
                    gkSkeletonAnimationHelper?.executeOpacityAnimation(for: layer, completion: { [weak self] in
                        self?.gkSkeletonLayer = nil
                        completion?()
                    })
                }
            } else {
                gkSkeletonLayer = nil
                completion?()
            }
        }
    }
    
    ///隐藏骨架是否有动画
    internal var gkSkeletonHideAnimated: Bool {
        set{
            objc_setAssociatedObject(self, &skeletonHideAnimatedKey, newValue, .OBJC_ASSOCIATION_RETAIN_NONATOMIC)
        }
        get{
            objc_getAssociatedObject(self, &skeletonHideAnimatedKey) as? Bool ?? false
        }
    }
    
    ///处理在容器中的骨架
    internal func gkSkeletonProcessView(_ view: UIView?, in container: UIView) {
        if let view = view {
            switch container.gkSkeletonStatus {
            case .showing :
                view.gkShowSkeleton()
            
            case .willHide :
                view.gkHideSkeleton(animate: container.gkSkeletonHideAnimated) { [weak container] in
                    if let container = container, container.gkSkeletonStatus == .willHide {
                        container.gkSkeletonLayer = nil
                    }
                }
                
            case .none :
                view.gkHideSkeleton(animate: false)
            default:
                break
            }
        }
    }
}
