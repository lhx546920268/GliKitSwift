//
//  UICollectionView+EmptyView.swift
//  GliKitSwift
//
//  Created by 罗海雄 on 2020/4/24.
//  Copyright © 2020 luohaixiong. All rights reserved.
//

import UIKit

private var shouldIgnoreSectionHeaderKey: UInt8 = 0
private var shouldIgnoreSectionFooterKey: UInt8 = 0

///用于collectionView 的空视图
public extension UICollectionView {
    
    // MARK: - Super Method
    
    override func layoutEmtpyView() {
        super.layoutEmtpyView()
        
        if let emptyView = self.gkEmptyView, emptyView.superview != nil, !emptyView.isHidden {
            
            var frame = emptyView.frame
            var y = frame.minY
            
            let numberOfSections = self.dataSource?.numberOfSections?(in: self) ?? 1
            
            if let layout = self.collectionViewLayout as? UICollectionViewFlowLayout, let delegate = self.delegate as? UICollectionViewDelegateFlowLayout {
                //获取sectionHeader 高度
                if self.gkShouldIgnoreSectionHeader {
                    if delegate.responds(to: #selector(UICollectionViewDelegateFlowLayout.collectionView(_:layout:referenceSizeForHeaderInSection:))) {
                        for i in 0 ..< numberOfSections {
                            y += delegate.collectionView!(self, layout: layout, referenceSizeForHeaderInSection: i).height
                        }
                    } else {
                        y += CGFloat(numberOfSections) * layout.headerReferenceSize.height
                    }
                }
                
                //获取section footer 高度
                if self.gkShouldIgnoreSectionFooter {
                    if delegate.responds(to: #selector(UICollectionViewDelegateFlowLayout.collectionView(_:layout:referenceSizeForFooterInSection:))) {
                        for i in 0 ..< numberOfSections {
                            y += delegate.collectionView!(self, layout: layout, referenceSizeForFooterInSection: i).height
                        }
                    } else {
                        y += CGFloat(numberOfSections) * layout.footerReferenceSize.height
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
        if empty, let dataSource = self.dataSource {
            //会触发 reloadData
            //NSInteger section = self.numberOfSections;
            
            let section = dataSource.numberOfSections?(in: self) ?? 1
            if dataSource.responds(to: #selector(UICollectionViewDataSource.collectionView(_:numberOfItemsInSection:))) {
                for i in 0 ..< section {
                    if dataSource.collectionView(self, numberOfItemsInSection: i) > 0 {
                        empty = false
                        break
                    }
                }
            }
            
            //item为0，section 大于0时，可能存在sectionHeader
            if empty, section > 0, let layout = self.collectionViewLayout as? UICollectionViewFlowLayout, let delegate = self.delegate as? UICollectionViewDelegateFlowLayout {
                
                if !self.gkShouldIgnoreSectionHeader {
                    
                    if delegate.responds(to: #selector(UICollectionViewDelegateFlowLayout.collectionView(_:layout:referenceSizeForHeaderInSection:))) {
                        for i in 0 ..< section {
                            if delegate.collectionView!(self, layout: layout, referenceSizeForHeaderInSection: i).height > 0 {
                                empty = false
                                break
                            }
                        }
                    } else {
                        empty = layout.headerReferenceSize.height == 0
                    }
                }
                
                if empty && !self.gkShouldIgnoreSectionFooter {
                    
                    if delegate.responds(to: #selector(UICollectionViewDelegateFlowLayout.collectionView(_:layout:referenceSizeForFooterInSection:))) {
                        for i in 0 ..< section {
                            if delegate.collectionView!(self, layout: layout, referenceSizeForFooterInSection: i).height > 0 {
                                empty = false
                                break
                            }
                        }
                    } else {
                        empty = layout.footerReferenceSize.height == 0
                    }
                }
            }
        }
        
        return empty
    }
    
    // MARK: - Property
    
    ///存在 sectionHeader 时，是否显示空视图 default is 'NO'
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
    
    // MARK: - Swizzle
    
    static func swizzleTableViewEmptyView(){
        
        let selectors: [Selector] = [
            #selector(reloadData),
            #selector(reloadSections(_:)),
            #selector(insertItems(at:)),
            #selector(insertSections(_:)),
            #selector(deleteItems(at:)),
            #selector(deleteSections(_:)),
        ]
        
        for selector in selectors {
            swizzling(selector1: selector, selector2: Selector("gkEmpty_\(NSStringFromSelector(selector))"), cls1: self)
        }
    }
    
    @objc private func gkEmpty_reloadData(){
        gkEmpty_reloadData()
        layoutEmtpyView()
    }
    
    @objc private func gkEmpty_reloadSections(_ sections: IndexSet){
        gkEmpty_reloadSections(sections)
        layoutEmtpyView()
    }
    
    @objc private func gkEmpty_insertItems(at indexPaths: [IndexPath]){
        gkEmpty_insertItems(at: indexPaths)
        layoutEmtpyView()
    }
    
    @objc private func gkEmpty_insertSections(_ sections: IndexSet){
        gkEmpty_insertSections(sections)
        layoutEmtpyView()
    }
    
    @objc private func gkEmpty_deleteItems(at indexPaths: [IndexPath]){
        gkEmpty_deleteItems(at: indexPaths)
        layoutEmtpyView()
    }
    
    @objc private func gkEmpty_deleteSections(_ sections: IndexSet){
        gkEmpty_deleteSections(sections)
        layoutEmtpyView()
    }
}
