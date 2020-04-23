//
//  ScrollViewController.swift
//  GliKitSwift
//
//  Created by 罗海雄 on 2020/4/1.
//  Copyright © 2020 luohaixiong. All rights reserved.
//

import UIKit

///滚动视图控制器，具有加载更多和下拉刷新，键盘弹出时设置contentInset功能，防止键盘挡住输入框
open class ScrollViewController: BaseViewController, UIScrollViewDelegate {
    
    ///滚动视图
    public var scrollView: UIScrollView?{
        didSet{
            if #available(iOS 11, *) {
                self.scrollView?.contentInsetAdjustmentBehavior = .never
            }
        }
    }
    
    override open var viewModel: ScrollViewModel?{
        get{
            super.viewModel as? ScrollViewModel
        }
    }

    ///滑动时是否隐藏键盘
    public var shouldDismissKeyboardWhileScroll = true

    ///键盘弹出是否需要调整contentInsets
    public var shouldAdjustContentInsetsForKeyboard = true

    ///scroll view 原始的contentInsets
    public var contentInsets: UIEdgeInsets = .zero

    ///加载更多和下拉刷是否可以共存
    public var coexistRefreshAndLoadMore = false

    ///是否已初始化
    public var isInit: Bool{
        get{
            self.scrollView?.superview != nil
        }
    }

    ///初始化视图 默认不做任何事 ，子类按需实现该方法
    open func initViews(){
        
    }

    ///刷新列表数据 子类重写
    open func reloadListData(){
        
    }

    //MARK: - Refresh

    ///是否可以下拉刷新数据
    public var refreshEnable = false{
        didSet{
            if oldValue != self.refreshEnable {
                assert(self.scrollView != nil, "\(self.gkNameOfClass) 设置下拉刷新 scrollView 不能为nil");

                if self.refreshEnable {
                    self.scrollView?.gkAddRefresh(callback: { [weak self] in
                        self?.willRefresh()
                    })
                } else {
                    self.scrollView?.gkRemoveRefresh()
                }
            }
        }
    }
    
    ///是否正在刷新数据
    public fileprivate(set) var refreshing = false

    //MARK: - Load More

    ///是否可以加载更多数据
    public var loadMoreEnable = false

    ///当前第几页
    public var curPage: Int = 1

    ///是否还有更多
    public var hasMore = false

    ///是否正在加载更多
    public private(set) var loadingMore = false


    override open func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
    }
    
    // MARK: - UIScrollViewDelegate
    
    public func scrollViewDidScroll(_ scrollView: UIScrollView) {
        
    }
    
    public func scrollViewWillBeginDragging(_ scrollView: UIScrollView) {
        
    }
    
    public func scrollViewWillEndDragging(_ scrollView: UIScrollView, withVelocity velocity: CGPoint, targetContentOffset: UnsafeMutablePointer<CGPoint>) {
        
    }
    // TODO: Page
//    - (void)scrollViewDidScroll:(UIScrollView *)scrollView
//    {
//
//    }
//
//    - (void)scrollViewWillBeginDragging:(UIScrollView *)scrollView
//    {
//        if(self.shouldDismissKeyboardWhileScroll){
//            [[UIApplication sharedApplication].keyWindow endEditing:YES];
//        }
//        if(scrollView == self.scrollView){
//            ///防止左右滑动时触发上下滑动
//            if([self.parentViewController isKindOfClass:[GKPageViewController class]]){
//                GKPageViewController *page = (GKPageViewController*)self.parentViewController;
//                page.scrollView.scrollEnabled = NO;
//            }
//        }
//    }
//
//    - (void)scrollViewWillEndDragging:(UIScrollView *)scrollView withVelocity:(CGPoint)velocity targetContentOffset:(inout CGPoint *)targetContentOffset
//    {
//        if(scrollView == self.scrollView){
//            [self.loadMoreControl scrollViewWillEndDragging:scrollView withVelocity:velocity targetContentOffset:targetContentOffset];
//            if([self.parentViewController isKindOfClass:[GKPageViewController class]]){
//                GKPageViewController *page = (GKPageViewController*)self.parentViewController;
//                page.scrollView.scrollEnabled = YES;
//            }
//        }
//    }
}

///下拉刷新
public extension ScrollViewController{
    
    ///下拉刷新视图
    var refreshControl: RefreshControl?{
        get{
            self.scrollView?.gkRefreshControl
        }
    }

    ///手动调用下拉刷新，会有下拉动画
    func startRefresh(){

        refreshControl?.startLoading()
    }
    
    ///将要触发下拉刷新
    fileprivate func willRefresh(){
        
        if loadingMore && !coexistRefreshAndLoadMore {
            stopLoadMore(hasMore: true)
            if curPage > GKHttpFirstPage {
                curPage -= 1
            }
            onLoadMoreCancel()
        }
        refreshing = true
        onRefesh()
    }

    ///触发下拉刷新
    @objc func onRefesh(){
        
    }

    ///结束下拉刷新
    func stopRefresh(success: Bool = true){
        
        refreshing = false
        refreshControl?.stopLoading()
    }

    ///下拉刷新取消
    @objc func onRefeshCancel(){
        
        viewModel?.onRefeshCancel()
    }
}

///加载更多
public extension ScrollViewController{
    
    ///加载更多时的指示视图
    var loadMoreControl: LoadMoreControl?{
        get{
            self.scrollView?.gkLoadMoreControl
        }
    }
    
    ///手动加载更多，会有上拉动画
    func startLoadMore(){
        
        loadMoreControl?.startLoading()
    }

    ///将要触发加载更多
    func willLoadMore(){
        
        if refreshing && !coexistRefreshAndLoadMore {
            stopRefresh()
            onRefeshCancel()
        }
        
        loadingMore = true
        onLoadMore()
    }
    
    ///触发加载更多
    @objc func onLoadMore(){
        
    }

    ///结束加载更多
    func stopLoadMore(hasMore: Bool){
        
        loadingMore = false
        if hasMore {
            loadMoreControl?.stopLoading()
        } else {
            loadMoreControl?.noMoreInfo()
        }
    }
    
    ///加载更多失败
    func stopLoadMoreWithFail(){
        
        loadingMore = false
        loadMoreControl?.loadFail()
    }

    ///加载更多取消
    @objc func onLoadMoreCancel(){
        
        viewModel?.onLoadMoreCancel()
    }
}

///键盘
public extension ScrollViewController{
    
    override func keyboardWillChangeFrame(_ notification: Notification) {
        super.keyboardWillChangeFrame(notification)
        
        if shouldAdjustContentInsetsForKeyboard {
            var insets = contentInsets
            if keyboardHidden {
                insets.bottom += keyboardFrame.size.height
                if bottomView != nil{
                    insets.bottom -= bottomView!.gkHeight
                }
                
                if insets.bottom < 0 {
                    insets.bottom = 0
                }
            }
            
            UIView.animate(withDuration: 0.25) {
                self.scrollView?.contentInset = insets
            }
        }
    }
}
