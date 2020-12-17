//
//  PageViewController.swift
//  GliKitSwift
//
//  Created by 罗海雄 on 2020/4/1.
//  Copyright © 2020 luohaixiong. All rights reserved.
//

import UIKit

private var visibleInPageKey: UInt8 = 0
public extension UIViewController {
    
    ///在翻页容器中是否可见
    var visibleInPage: Bool {
        get{
            objc_getAssociatedObject(self, &visibleInPageKey) as? Bool ?? false
        }
        set{
            objc_setAssociatedObject(self, &visibleInPageKey, newValue, .OBJC_ASSOCIATION_RETAIN_NONATOMIC)
        }
    }
}

///翻页容器
open class PageViewController: ScrollViewController, TabMenuBarDelegate {
    
    ///顶部菜单 当 shouldUseMenuBar = NO，return nil
    private var _menuBar: TabMenuBar?
    public var menuBar: TabMenuBar?{
        if !shouldUseMenuBar {
            return nil
        }
        if _menuBar == nil {
            let menuBar = TabMenuBar(titles: nil)
            menuBar.contentInset = UIEdgeInsets(0, menuBar.itemPadding, 0, menuBar.itemPadding)
            menuBar.delegate = self
            _menuBar = menuBar
        }
        
        return _menuBar;
    }
    
    ///是否需要用菜单 menuBar
    public var shouldUseMenuBar = true
    
    ///是否需要设置菜单 为 topView
    public var shouldSetMenuBarTopView = true
    
    ///菜单栏高度
    public var menuBarHeight: CGFloat = 40
    
    ///当前页码
    public private(set) var currentPage = NSNotFound
    
    /**
     显示的viewControllers 调用时会自动创建，需要自己添加 viewController
     这里的Controller 如果是ScrollViewController 或者webViewController， 左右滑动时会关闭上下滑动
     @note 不要调用 removAllObjects 使用 removeAllViewContollers
     */
    public lazy var pageViewControllers: [UIViewController] = {
        return [UIViewController]()
    }()
    
    ///起始滑动位置
    private var beginOffset: CGPoint = .zero
    
    ///是否需要滚动到对应位置
    private var willScrollToPage = NSNotFound
    
    ///当前scrollView 大小
    private var scrollViewSize: CGSize = .zero
    
    override open func initViews() {
        
        if shouldUseMenuBar && shouldSetMenuBarTopView {
            container?.setTopView(menuBar, height: menuBarHeight)
        }
        
        let scrollView = UIScrollView()
        scrollView.isPagingEnabled = true
        scrollView.showsVerticalScrollIndicator = false
        scrollView.showsHorizontalScrollIndicator = false
        scrollView.alwaysBounceVertical = false
        scrollView.scrollsToTop = false
        scrollView.bounces = false
        scrollView.delegate = self
        self.scrollView = scrollView
        self.contentView = scrollView
        
        super.initViews()
        reloadData()
    }
    
    ///移除所有viewController  reloadData 之前调用这个
    public func removeAllViewContollers(){
        for viewController in pageViewControllers {
            viewController.removeFromParent()
            viewController.view.removeFromSuperview()
        }
        pageViewControllers.removeAll()
    }
    
    ///刷新数据
    public func reloadData(){
        layoutPages()
        self.scrollView?.contentOffset = .zero
        currentPage = 0;
        if currentPage < numberOfPage() {
            viewControllerForIndex(currentPage).visibleInPage = true
        }
    }
    
    // MARK: - Subclass impl
    
    /**
     跳转到某一页
     
     @param page 页码
     @param animate 是否动画
     */
    public func setPage(_ page: Int, animated: Bool){
        
        if page >= 0 && page < numberOfPage() {
            currentPage = page
            menuBar?.setSelectedIndex(page, animated: animated)
            if scrollViewSize != .zero {
                scrollView?.setContentOffset(CGPoint(CGFloat(page) * scrollViewSize.width, 0), animated: animated)
            } else {
                willScrollToPage = currentPage
            }
        }
    }
    
    /**
     获取对应下标的controller ，子类要重写
     
     @param index 对应下标
     @return 对应下标的controller
     */
    open func viewControllerForIndex(_ index: Int) -> UIViewController{
        return pageViewControllers[index]
    }
    
    /**
     页数量 默认是返回 menuBar.titles.count，如果 shouldUseMenuBar = NO,需要重写该方法
     
     @return 页数量
     */
    open func numberOfPage() -> Int{
        if shouldUseMenuBar {
            return menuBar?.titles?.count ?? 0
        }else{
            return pageViewControllers.count
        }
    }
    
    private func _onScrollTopPage(_ page: Int, oldPage: Int){
        if oldPage < numberOfPage() {
            viewControllerForIndex(oldPage).visibleInPage = false
        }
        
        viewControllerForIndex(page).visibleInPage = true
        onScrollTopPage(page)
    }
    
    /**
     滑动到某一页，setPage 时不调用
     
     @param page 某一页
     */
    open func onScrollTopPage(_ page: Int){
        
    }
    
    // MARK: - Layout
    
    override open func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        
        if let scrollView = self.scrollView {
            if scrollView.frame.size != .zero && scrollView.frame.size != scrollViewSize {
                
                scrollViewSize = scrollView.frame.size
                layoutPages()
                
                let selectedIndex = (menuBar?.selectedIndex ?? 0)
                if (willScrollToPage > 0 && willScrollToPage < numberOfPage()) || selectedIndex != 0 {
                    
                    let oldPage = currentPage
                    if selectedIndex != 0 {
                        currentPage = selectedIndex
                    }
                    scrollView.setContentOffset(CGPoint(CGFloat(currentPage) * scrollViewSize.width, 0), animated: false)
                    _onScrollTopPage(currentPage, oldPage: oldPage)
                    willScrollToPage = NSNotFound
                } else {
                    if currentPage < numberOfPage() {
                        viewControllerForIndex(currentPage).visibleInPage = true
                    }
                }
            }
        }
    }
    
    
    ///调整子视图
    private func layoutPages(){
        if scrollViewSize != .zero {
            scrollView?.contentSize = CGSize(scrollViewSize.width * CGFloat(numberOfPage()), scrollViewSize.height)
            layoutVisiablePages()
        }
    }
    
    ///调整可见部分的视图
    private func layoutVisiablePages(){
        
        if let scrollView = self.scrollView {
            let index = Int(floor(scrollView.contentOffset.x / scrollViewSize.width))
            layoutPageForIndex(index - 1)
            layoutPageForIndex(index)
            layoutPageForIndex(index + 1)
        }
    }
    
    ///调整viewControlelr
    private func layoutPageForIndex(_ index: Int){
        
        if index >= 0 && index < numberOfPage() {
            let viewController = viewControllerForIndex(index)
            if viewController.view.superview == nil {
                scrollView?.addSubview(viewController.view)
                addChild(viewController)
            }
            viewController.view.frame = CGRect(scrollViewSize.width * CGFloat(index), 0, scrollViewSize.width, scrollViewSize.height)
        }
    }
    
    // MARK: - TabMenuBarDelegate
    
    public func menuBar(_ menuBar: MenuBar, didSelectItemAt index: Int) {
        
        scrollView?.setContentOffset(CGPoint(CGFloat(index) * scrollViewSize.width, 0), animated: false)
        let oldPage = currentPage
        currentPage = index
        _onScrollTopPage(currentPage, oldPage: oldPage)
    }
    
    // MARK: - UIScrollViewDelegate

    override public func scrollViewWillBeginDragging(_ scrollView: UIScrollView) {
        
        beginOffset = scrollView.contentOffset
        setScrollEnabled(false)
        
        super.scrollViewWillBeginDragging(scrollView)
    }
    
    override public func scrollViewDidScroll(_ scrollView: UIScrollView) {
        
        layoutVisiablePages()
        
        if let menuBar = self.menuBar {
            var offset = scrollView.contentOffset.x
            if offset <= 0 || offset >= scrollView.gkWidth * CGFloat((menuBar.titles?.count ?? 0) - 1) {
                return
            }
            
            //是否是向右滑动
            let toRight = scrollView.contentOffset.x >= self.beginOffset.x
            
            let width = scrollView.gkWidth
            let index = Int((toRight ? offset : (offset + width)) / width)
            
            if index != menuBar.selectedIndex {
                return
            }
            
            offset = CGFloat(Int(offset) % Int(width))
            if !toRight {
                offset = width - offset
            }
            let percent = offset / width
            
            //向左还是向右
            let willIndex = toRight ? menuBar.selectedIndex + 1 : menuBar.selectedIndex - 1
            menuBar.setPercent(percent, for: willIndex)
        }
        
        super.scrollViewDidScroll(scrollView)
    }

    func scrollViewDidEndDragging(_ scrollView: UIScrollView, willDecelerate decelerate: Bool) {
        
        if !decelerate {
            scrollToVisibleIndex()
            setScrollEnabled(true)
        }
    }
    
    func scrollViewDidEndDecelerating(_ scrollView: UIScrollView) {
        
        scrollToVisibleIndex()
        setScrollEnabled(true)
    }

    ///滑动到可见位置
    private func scrollToVisibleIndex(){
        
        if let scrollView = self.scrollView {
            let index = Int(floor(scrollView.bounds.origin.x / scrollView.gkWidth))
            
            if index != currentPage {
                let oldPage = currentPage
                currentPage = index;
                if let menuBar = self.menuBar {
                    if index != menuBar.selectedIndex {
                        menuBar.setSelectedIndex(index, animated: true)
                    }
                }
                _onScrollTopPage(currentPage, oldPage: oldPage)
            }
        }
    }

    ///设置是否可以滑动
    private func setScrollEnabled(_ enable: Bool){
        
        for viewController in pageViewControllers {
            if let scrollViewController = viewController as? ScrollViewController {
                scrollViewController.scrollView?.isScrollEnabled = enable
            } else {
                // TODO: Web
            }
        }
    }
}
