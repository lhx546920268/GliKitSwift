//
//  UICollectionView+Skeleton.swift
//  GliKitSwift
//
//  Created by 罗海雄 on 2020/10/21.
//  Copyright © 2020 luohaixiong. All rights reserved.
//

import UIKit

///集合视图骨架
public extension UICollectionView {
    
    @objc override func gkShowSkeleton(duration: Double = 0, completion: VoidCallback? = nil) {
        if gkSkeletonStatus == .none {
            gkSkeletonStatus = .showing
            reloadData()
            
            if duration > 0 && completion != nil {
                DispatchQueue.main.asyncAfter(deadline: DispatchTime(floatLiteral: duration), execute: completion!)
            }
        }
    }

    @objc override func gkHideSkeleton(animate: Bool = true, completion: VoidCallback? = nil) {
        if gkSkeletonStatus == .showing {
            gkSkeletonStatus = .willHide
            gkSkeletonHideAnimated = animate
            reloadData()
        }
    }
    
    // MARK: - swizzle
    
    internal static func swizzleUICollectionViewSkeleton() {
        swizzling(selector1: #selector(gkSkeletonSetDelegate(_:)), selector2: #selector(setter: delegate), cls1: self)
        swizzling(selector1: #selector(gkSkeletonSetDataSource(_:)), selector2: #selector(setter: dataSource), cls1: self)
    }

    @objc private func gkSkeletonSetDelegate(_ delegate: UICollectionViewDelegate?) {
        if let delegate = delegate as? NSObject {
            SkeletonHelper.replaceImplementations(selector: #selector(UICollectionViewDelegate.collectionView(_:didSelectItemAt:)), owner: delegate, implementer: self)
            SkeletonHelper.replaceImplementations(selector: #selector(UICollectionViewDelegate.collectionView(_:shouldHighlightItemAt:)), owner: delegate, implementer: self)
        }
        
        gkSkeletonSetDelegate(delegate)
    }
    
    @objc private func gkSkeletonSetDataSource(_ dataSource: UICollectionViewDataSource?) {
        
        if let dataSource = dataSource as? NSObject {
            SkeletonHelper.replaceImplementations(selector: #selector(UICollectionViewDataSource.collectionView(_:cellForItemAt:)), owner: dataSource, implementer: self)
            SkeletonHelper.replaceImplementations(selector: #selector(UICollectionViewDataSource.collectionView(_:viewForSupplementaryElementOfKind:at:)), owner: dataSource, implementer: self)
        }
        gkSkeletonSetDataSource(dataSource)
    }

    // MARK: - UITableViewDelegate
    
    @objc private func gkSkeletonAdd_collectionView(_ collectionView: UICollectionView, shouldHighlightItemAtIndexPath indexPath: IndexPath) -> Bool {
        //这是添加的方法
        return collectionView.gkSkeletonStatus == .none
    }

    @objc private func gkSkeleton_collectionView(_ collectionView: UICollectionView, shouldHighlightItemAtIndexPath indexPath: IndexPath) -> Bool {
        if collectionView.gkSkeletonStatus != .none {
            return false
        }
        return gkSkeleton_collectionView(collectionView, shouldHighlightItemAtIndexPath: indexPath)
    }

    @objc private func gkSkeleton_collectionView(_ collectionView: UICollectionView, viewForSupplementaryElementOfKind kind: String, atIndexPath indexPath: IndexPath) -> UICollectionReusableView {
        let view = gkSkeleton_collectionView(collectionView, viewForSupplementaryElementOfKind: kind, atIndexPath: indexPath)
        gkSkeletonProcessView(view, in: collectionView)
        
        return view
    }

    @objc private func gkSkeleton_collectionView(_ collectionView: UICollectionView, cellForItemAtIndexPath indexPath: IndexPath) -> UICollectionViewCell {
        let cell = gkSkeleton_collectionView(collectionView, cellForItemAtIndexPath: indexPath)
        gkSkeletonProcessView(cell.contentView, in: collectionView)
        
        return cell
    }

    @objc private func gkSkeleton_collectionView(_ collectionView: UICollectionView, didSelectItemAtIndexPath indexPath: IndexPath) {
        if collectionView.gkSkeletonStatus != .none {
            collectionView.deselectItem(at: indexPath, animated: false)
        }
        gkSkeleton_collectionView(collectionView, didSelectItemAtIndexPath: indexPath)
    }
}
