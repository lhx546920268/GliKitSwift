//
//  UITableView+Skeleton.swift
//  GliKitSwift
//
//  Created by 罗海雄 on 2020/10/21.
//  Copyright © 2020 luohaixiong. All rights reserved.
//

import UIKit

///列表骨架
public extension UITableView {
    
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
    
    internal static func swizzleUITableViewSkeleton() {
        swizzling(selector1: #selector(gkSkeletonSetDelegate(_:)), selector2: #selector(setter: delegate), cls1: self)
        swizzling(selector1: #selector(gkSkeletonSetDataSource(_:)), selector2: #selector(setter: dataSource), cls1: self)
    }

    @objc private func gkSkeletonSetDelegate(_ delegate: UITableViewDelegate?) {
        if let delegate = delegate as? NSObject {
            SkeletonHelper.replaceImplementations(selector: #selector(UITableViewDelegate.tableView(_:didSelectRowAt:)), owner: delegate, implementer: self)
            SkeletonHelper.replaceImplementations(selector: #selector(UITableViewDelegate.tableView(_:viewForHeaderInSection:)), owner: delegate, implementer: self)
            SkeletonHelper.replaceImplementations(selector: #selector(UITableViewDelegate.tableView(_:viewForFooterInSection:)), owner: delegate, implementer: self)
            SkeletonHelper.replaceImplementations(selector: #selector(UITableViewDelegate.tableView(_:shouldHighlightRowAt:)), owner: delegate, implementer: self)
        }
        
        gkSkeletonSetDelegate(delegate)
    }
    
    @objc private func gkSkeletonSetDataSource(_ dataSource: UITableViewDataSource?) {
        
        if let dataSource = dataSource as? NSObject {
            SkeletonHelper.replaceImplementations(selector: #selector(UITableViewDataSource.tableView(_:cellForRowAt:)), owner: dataSource, implementer: self)
        }
        gkSkeletonSetDataSource(dataSource)
    }

    // MARK: - UITableViewDelegate
    
    @objc private func gkSkeletonAdd_tableView(_ tableView: UITableView, shouldHighlightRowAtIndexPath indexPath: IndexPath) -> Bool {
        //这是添加的方法
        return tableView.gkSkeletonStatus == .none
    }

    @objc private func gkSkeleton_tableView(_ tableView: UITableView, shouldHighlightRowAtIndexPath indexPath: IndexPath) -> Bool {
        if tableView.gkSkeletonStatus != .none {
            return false
        }
        return gkSkeleton_tableView(tableView, shouldHighlightRowAtIndexPath: indexPath)
    }
    
    @objc private func gkSkeleton_tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        let view = gkSkeleton_tableView(tableView, viewForHeaderInSection: section)
        gkSkeletonProcessView(view, in: tableView)
        
        return view
    }

    @objc private func gkSkeleton_tableView(_ tableView: UITableView, viewForFooterInSection section: Int) -> UIView? {
        let view = gkSkeleton_tableView(tableView, viewForFooterInSection: section)
        gkSkeletonProcessView(view, in: tableView)
        
        return view
    }

    @objc private func gkSkeleton_tableView(_ tableView: UITableView, cellForRowAtIndexPath indexPath: IndexPath) -> UITableViewCell {
        let cell = gkSkeleton_tableView(tableView, cellForRowAtIndexPath: indexPath)
        gkSkeletonProcessView(cell.contentView, in: tableView)
        
        return cell
    }

    @objc private func gkSkeleton_tableView(_ tableView: UITableView, didSelectRowAtIndexPath indexPath: IndexPath) {
        if tableView.gkSkeletonStatus != .none {
            tableView.deselectRow(at: indexPath, animated: false)
        }
        gkSkeleton_tableView(tableView, didSelectRowAtIndexPath: indexPath)
    }
}
