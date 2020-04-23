//
//  UIView+EmptyView.swift
//  GliKitSwift
//
//  Created by 罗海雄 on 2020/4/21.
//  Copyright © 2020 luohaixiong. All rights reserved.
//

import UIKit

///空视图key
private var emptyViewKey: UInt8 = 0

///代理
private var emptyViewDelegateKey: UInt8 = 0

///显示空视图
private var showEmptyViewKey: UInt8 = 0

///旧的视图大小
private var oldSizeKey: UInt8 = 0

///空视图扩展
public extension UIView {

    ///空视图 不要直接设置这个 使用 gkShowEmptyView
    var gkEmptyView: EmptyView?{
        set{
            let emptyView = self.gkEmptyView
            if newValue != emptyView {
                emptyView?.removeFromSuperview()
                objc_setAssociatedObject(self, &emptyViewKey, newValue, .OBJC_ASSOCIATION_RETAIN_NONATOMIC)
            }
        }
        get{
            objc_getAssociatedObject(self, &emptyViewKey) as? EmptyView
        }
    }

    ///设置显示空视图
    var gkShowEmptyView: Bool{
        set{
            objc_setAssociatedObject(self, &showEmptyViewKey, newValue, .OBJC_ASSOCIATION_RETAIN_NONATOMIC);
            if newValue {
                
                let emptyView = self.gkEmptyView
                if emptyView == nil {
                    self.gkEmptyView = EmptyView()
                }
                layoutEmtpyView()
            }else{
                self.gkEmptyView = nil;
            }
        }
        get{
            objc_getAssociatedObject(self, &showEmptyViewKey) as? Bool ?? false
        }
    }

    ///空视图代理
    var gkEmptyViewDelegate: EmptyViewDelegate?{
        set{
            var container = objc_getAssociatedObject(self, &emptyViewDelegateKey) as? WeakObjectContainer
            if newValue != nil && container == nil {
                container = WeakObjectContainer()
            }
            container?.weakObject = newValue
            objc_setAssociatedObject(self, &emptyViewDelegateKey, container, .OBJC_ASSOCIATION_RETAIN_NONATOMIC)
        }
        get{
            let container = objc_getAssociatedObject(self, &emptyViewDelegateKey) as? WeakObjectContainer
            return container?.weakObject as? EmptyViewDelegate
        }
    }

    ///旧的视图大小，防止 layoutSubviews 时重复计算
    var gkOldSize: CGSize{
        set{
            objc_setAssociatedObject(self, &oldSizeKey, newValue, .OBJC_ASSOCIATION_RETAIN_NONATOMIC)
        }
        get{
            objc_getAssociatedObject(self, &oldSizeKey) as? CGSize ?? .zero
        }
    }

    ///调整emptyView
    @objc func layoutEmtpyView(){
        if gkShowEmptyView {
            
            if let emptyView = gkEmptyView, emptyView.superview == nil {
                gkEmptyViewDelegate?.emptyViewWillAppear?(emptyView)
                addSubview(emptyView)
                emptyView.snp.makeConstraints { (make) in
                    make.edges.equalTo(self)
                }
            }
        }
    }
}
