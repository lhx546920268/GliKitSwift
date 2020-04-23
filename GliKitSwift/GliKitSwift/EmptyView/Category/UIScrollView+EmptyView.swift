//
//  UIScrollView+EmptyView.swift
//  GliKitSwift
//
//  Created by 罗海雄 on 2020/4/23.
//  Copyright © 2020 luohaixiong. All rights reserved.
//

import UIKit

///是否显示空视图kkey
private var shouldShowEmptyViewKey: UInt8 = 0

///偏移量
private var emptyViewInsetsKey: UInt8 = 0

///用于UIScrollView的空视图扩展
public extension UIScrollView{

    /**
     是否显示空视图 default is 'false'， 当为YES时，如果是UITableView 或者 UICollectionView，还需要没有数据时才显示
     @warning 如果使用约束，必须在设置父视图后 才设置此值
     */
    var gkShouldShowEmptyView: Bool{
        set{
            if self.gkShouldShowEmptyView != newValue {
                objc_setAssociatedObject(self, &shouldShowEmptyViewKey, newValue, .OBJC_ASSOCIATION_RETAIN_NONATOMIC)
                if newValue {
                    layoutEmtpyView()
                } else {
                    self.gkEmptyView = nil
                }
            }
        }
        get{
            objc_getAssociatedObject(self, &shouldShowEmptyViewKey) as? Bool ?? false
        }
    }

    ///空视图偏移量 default is UIEdgeInsetZero
    var gkEmptyViewInsets: UIEdgeInsets{
        set{
            if self.gkEmptyViewInsets != newValue {
                objc_setAssociatedObject(self, &emptyViewInsetsKey, newValue, .OBJC_ASSOCIATION_RETAIN_NONATOMIC)
                layoutEmtpyView()
            }
        }
        get{
            objc_getAssociatedObject(self, &emptyViewInsetsKey) as? UIEdgeInsets ?? .zero
        }
    }

    ///当前是空数据 UIScrollView 一定是空的，其他的不一定
    @objc func gkIsEmptyData() -> Bool{
        return true
    }
    
    ///调整emptyView
    override func layoutEmtpyView() {
        
        if !self.gkShouldShowEmptyView {
            return
        }
        
        //大小为0时不创建
        if self.frame.size == .zero {
            return
        }
        
        if gkIsEmptyData() {
            
            var emptyView = gkEmptyView
            if emptyView == nil {
                emptyView = EmptyView()
                gkEmptyView = emptyView
            }
            
            let insets = self.gkEmptyViewInsets
            emptyView!.frame = CGRect(insets.left, insets.top, self.gkWidth - insets.left - insets.right, self.gkHeight - insets.top - insets.bottom)
            emptyView!.isHidden = false
            
            if emptyView!.superview == nil {
                gkEmptyViewDelegate?.emptyViewWillAppear?(emptyView!)
 
                if let loadMoreControl = self.gkLoadMoreControl {
                    insertSubview(emptyView!, aboveSubview: loadMoreControl)
                } else {
                    insertSubview(emptyView!, at: 0)
                }
            }
        }
    }
}
