//
//  UITableView+EmptyView.swift
//  GliKitSwift
//
//  Created by 罗海雄 on 2020/4/24.
//  Copyright © 2020 luohaixiong. All rights reserved.
//

import UIKit

private var shouldIgnoreTableHeaderKey: UInt8 = 0
private var shouldIgnoreTableFooterKey: UInt8 = 0
private var shouldIgnoreSectionHeaderKey: UInt8 = 0
private var shouldIgnoreSectionFooterKey: UInt8 = 0

///用于UITableView的空视图扩展
public extension UITableView {
    
    // MARK: - Super Method

    override func layoutEmtpyView() {
        super.layoutEmtpyView()
        
        if let emptyView = self.gkEmptyView, emptyView.superview != nil, !emptyView.isHidden {
            
            var frame = emptyView.frame
            var y = frame.minY
            
            y += self.tableHeaderView?.gkHeight ?? 0
            y += self.tableFooterView?.gkHeight ?? 0
            
            if let delegate = self.delegate {
                let numberOfSections = self.dataSource?.numberOfSections?(in: self) ?? 1
                
                //获取sectionHeader 高度
                if self.gkShouldIgnoreSectionHeader {
                    if delegate.responds(to: #selector(UITableViewDelegate.tableView(_:heightForHeaderInSection:))) {
                        for i in 0 ..< numberOfSections {
                            y += self.delegate!.tableView!(self, heightForHeaderInSection: i)
                        }
                    } else {
                        y += CGFloat(numberOfSections) * self.sectionHeaderHeight
                    }
                }
                
                //获取section footer 高度
                if self.gkShouldIgnoreSectionFooter {
                    if delegate.responds(to: #selector(UITableViewDelegate.tableView(_:heightForFooterInSection:))) {
                        for i in 0 ..< numberOfSections {
                            y += self.delegate!.tableView!(self, heightForFooterInSection: i)
                        }
                    } else {
                        y += CGFloat(numberOfSections) * self.sectionFooterHeight
                    }
                }
            }
            
            frame.origin.y = y
            frame.size.height -= y
            
            if frame.height <= 0 {
                emptyView.removeFromSuperview()
            } else {
                emptyView.frame = frame;
            }
        }
    }
    
    override func gkIsEmptyData() -> Bool {
        
        var empty = true
        if !self.gkShouldIgnoreTableHeader && self.tableHeaderView != nil {
            empty = false
        } else if !self.gkShouldIgnoreTableFooter && self.tableFooterView != nil {
            empty = false
        } else if let dataSource = self.dataSource, let delegate = self.delegate {
            
            let section = dataSource.numberOfSections?(in: self) ?? 1
            if section > 0 {
                for i in 0 ..< section {
                    if dataSource.tableView(self, numberOfRowsInSection: i) > 0 {
                        empty = false
                        break
                    }
                }
                
                //行数为0，section 大于0时，可能存在sectionHeader
                if empty && section > 0 && self.delegate != nil {
                    if !self.gkShouldIgnoreTableHeader && delegate.responds(to: #selector(UITableViewDelegate.tableView(_:viewForHeaderInSection:))) {
                        for i in 0 ..< section {
                            if self.delegate!.tableView!(self, viewForHeaderInSection: i) != nil {
                                empty = false
                                break
                            }
                        }
                    }
                    
                    if empty && !self.gkShouldIgnoreSectionFooter && delegate.responds(to: #selector(UITableViewDelegate.tableView(_:viewForFooterInSection:))) {
                        for i in 0 ..< section {
                            if self.delegate!.tableView!(self, viewForFooterInSection: i) != nil {
                                empty = false
                                break
                            }
                        }
                    }
                }
            }
        }
        
        return empty
    }

    // MARK: - Property

    ///存在 tableHeaderView 时，是否显示空视图
    var gkShouldIgnoreTableHeader: Bool{
        set{
            objc_setAssociatedObject(self, &shouldIgnoreTableHeaderKey, newValue, .OBJC_ASSOCIATION_RETAIN_NONATOMIC)
        }
        get{
            objc_getAssociatedObject(self, &shouldIgnoreTableHeaderKey) as? Bool ?? true
        }
    }

    ///存在 tableFooterView 时，是否显示空视图
    var gkShouldIgnoreTableFooter: Bool{
        set{
            objc_setAssociatedObject(self, &shouldIgnoreTableFooterKey, newValue, .OBJC_ASSOCIATION_RETAIN_NONATOMIC)
        }
        get{
            objc_getAssociatedObject(self, &shouldIgnoreTableFooterKey) as? Bool ?? true
        }
    }

    ///存在 sectionHeader 时，是否显示空视图
    var gkShouldIgnoreSectionHeader: Bool{
        set{
            objc_setAssociatedObject(self, &shouldIgnoreSectionHeaderKey, newValue, .OBJC_ASSOCIATION_RETAIN_NONATOMIC)
        }
        get{
            objc_getAssociatedObject(self, &shouldIgnoreSectionHeaderKey) as? Bool ?? false
        }
    }

    ///存在 sectionFooter 时，是否显示空视图
    var gkShouldIgnoreSectionFooter: Bool{
        set{
            objc_setAssociatedObject(self, &shouldIgnoreSectionFooterKey, newValue, .OBJC_ASSOCIATION_RETAIN_NONATOMIC)
        }
        get{
            objc_getAssociatedObject(self, &shouldIgnoreSectionFooterKey) as? Bool ?? false
        }
    }
}
