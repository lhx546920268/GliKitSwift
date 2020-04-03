//
//  ScrollViewModel.swift
//  GliKitSwift
//
//  Created by 罗海雄 on 2020/4/1.
//  Copyright © 2020 luohaixiong. All rights reserved.
//

import UIKit

///带有下拉划线的基础视图逻辑处理
open class ScrollViewModel: BaseViewModel {
    
    override open var viewController: ScrollViewController?{
        get{
            super.viewController as? ScrollViewController
        }
    }
    
    //MARK: - Refresh
    
    ///是否正在刷新数据
    public var refreshing: Bool{
        get{
            self.viewController?.refreshing ?? false
        }
    }
    
    ///手动调用下拉刷新，会有下拉动画
    func startRefresh(){

        self.viewController?.stopRefresh()
    }

    ///触发下拉刷新
    @objc func onRefesh(){
 
    }

    ///结束下拉刷新
    func stopRefresh(success: Bool = true){
        
        self.viewController?.stopRefresh(success: success)
    }

    ///下拉刷新取消
    @objc func onRefeshCancel(){
        
    }
    
    // MARK: - LoadMore
    
    ///当前第几页
    public var curPage: Int{
        set{
            self.viewController?.curPage = newValue
        }
        get{
            self.viewController?.curPage ?? 0
        }
    }

    ///是否还有更多
    public var hasMore: Bool{
        set{
            self.viewController?.hasMore = newValue
        }
        get{
            self.viewController?.hasMore ?? false
        }
    }

    ///是否正在加载更多
    public var loadingMore: Bool{
        get{
            return self.viewController?.loadingMore ?? false
        }
    }
    
    ///手动加载更多，会有上拉动画
    func startLoadMore(){
        
        self.viewController?.startLoadMore()
    }

    ///触发加载更多
    @objc func onLoadMore(){
        
    }

    ///结束加载更多
    func stopLoadMore(hasMore: Bool){
        
        self.viewController?.stopLoadMore(hasMore: hasMore)
    }
    
    ///加载更多失败
    func stopLoadMoreWithFail(){
        
        self.viewController?.stopLoadMoreWithFail()
    }

    ///加载更多取消
    @objc func onLoadMoreCancel(){
        
    }
}
