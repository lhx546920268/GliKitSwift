//
//  UIScrollView+Refresh.swift
//  GliKitSwift
//
//  Created by 罗海雄 on 2020/3/30.
//  Copyright © 2020 luohaixiong. All rights reserved.
//

import UIKit

private var refreshControlKey: UInt8 = 0
private var loadMoreControlKey: UInt8 = 0

///刷新 扩展
public extension UIScrollView{
    
    // MARK: - Refresh
    
    /**
     添加下拉刷新功能
     *@param callback 刷新回调方法
     */
    @discardableResult
    func gkAddRefresh(callback: @escaping DataControlCallback) -> RefreshControl {
        
        var refreshControl = self.gkRefreshControl
        if refreshControl == nil {
            let cls = RefreshControl.refreshControlClass as? RefreshControl.Type
            assert(cls != nil, "RefreshControl.refreshControlClass 必须是 \(NSStringFromClass(RefreshControl.self)) 或其子类")
            refreshControl = cls!.init(scrollView: self)
            self.gkRefreshControl = refreshControl
            
            if let loadMoreControl = self.gkLoadMoreControl {
                var contentInset = self.contentInset
                let state = loadMoreControl.state
                if state == .loading || (state == .noData && loadMoreControl.shouldStayWhileNoData) {
                    contentInset.bottom -= loadMoreControl.criticalPoint
                    if contentInset.bottom < 0 {
                        contentInset.bottom = 0
                    }
                }
                loadMoreControl.originalContentInset = contentInset
            }
        }
        
        refreshControl?.callback = callback
        return refreshControl!
    }
    
    ///删除下拉刷新功能
    func gkRemoveRefresh(){
        
        if let refreshControl = self.gkRefreshControl {
            self.contentInset = refreshControl.originalContentInset
            self.gkRefreshControl = nil
        }
    }

    ///下拉刷新控制类
    var gkRefreshControl: RefreshControl?{
        set{
            let refreshControl = self.gkRefreshControl
            if newValue !=  refreshControl{
                refreshControl?.removeFromSuperview()
                if newValue != nil {
                    addSubview(newValue!)
                }
                objc_setAssociatedObject(self, &refreshControlKey, newValue, .OBJC_ASSOCIATION_RETAIN_NONATOMIC);
            }
        }
        get{
            objc_getAssociatedObject(self, &refreshControlKey) as? RefreshControl
        }
    }

    ///是否正在下拉刷新
    var gkRefreshing: Bool{
        (self.gkRefreshControl?.state ?? .normal) == .loading
    }
    
    // MARK: - Load More

    /**
     添加加载更多
     *@param callback 加载回调
     */
    @discardableResult
    func gkAddLoadMore(callback: @escaping DataControlCallback) -> LoadMoreControl{
        
        var loadMoreControl = self.gkLoadMoreControl
        if loadMoreControl == nil {
            let cls = LoadMoreControl.loadMoreControlClass as? LoadMoreControl.Type
            assert(cls != nil, "RefreshControl/refreshControlClass 必须是 \(NSStringFromClass(RefreshControl.self)) 或其子类")
            loadMoreControl = cls!.init(scrollView: self)
            self.gkLoadMoreControl = loadMoreControl
            
            if let refreshControl = self.gkRefreshControl {
                var contentInset = self.contentInset
                let state = refreshControl.state
                if state == .loading {
                    contentInset.bottom -= refreshControl.criticalPoint
                    if contentInset.top < 0 {
                        contentInset.top = 0
                    }
                }
                refreshControl.originalContentInset = contentInset
            }
        }
        
        loadMoreControl?.callback = callback
        return loadMoreControl!
    }

    ///删除加载更多功能
    func gkRemoveLoadMore(){
        
        if let loadMoreControl = self.gkLoadMoreControl {
            self.contentInset = loadMoreControl.originalContentInset
            self.gkLoadMoreControl = nil
        }
    }

    /**
     加载更多控制类
     */
    var gkLoadMoreControl: LoadMoreControl?{
        set{
            let loadMoreControl = self.gkLoadMoreControl
            if newValue !=  loadMoreControl{
                loadMoreControl?.removeFromSuperview()
                if newValue != nil {
                    addSubview(newValue!)
                }
                objc_setAssociatedObject(self, &loadMoreControlKey, newValue, .OBJC_ASSOCIATION_RETAIN_NONATOMIC);
            }
        }
        get{
            objc_getAssociatedObject(self, &loadMoreControlKey) as? LoadMoreControl
        }
    }

    ///是否正在加载更多
    var gkLoadingMore: Bool{
        (self.gkLoadMoreControl?.state ?? .normal) == .loading
    }
}
