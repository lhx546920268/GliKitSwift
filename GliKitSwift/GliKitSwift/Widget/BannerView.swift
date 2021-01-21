//
//  BannerView.swift
//  GliKitSwift
//
//  Created by 罗海雄 on 2020/7/20.
//  Copyright © 2020 luohaixiong. All rights reserved.
//

import UIKit

///banner 代理
@objc public protocol BannerViewDelegate: NSObjectProtocol {
    
    ///item数量
    func numberOfItems(in bannerView: BannerView) -> Int
    
    ///item 配置
    ///indexPath ios 8.3中 此值 collectionView:cellForItemAtIndexPath： 和dequeueReusableCellWithReuseIdentifier：forIndexPath: 两个必须一致，否则会造成cell消失的问题
    func bannerView(_ bannerView: BannerView, cellForItemAt indexPath: IndexPath, index: Int) -> UICollectionViewCell
    
    ///点击某个item
    @objc optional func bannerView(_ bannerView: BannerView, didSelectItemAt index: Int)
}

///自定义页码
open class PageControl: UIPageControl {
    
    ///点大小
    var pointSize: CGFloat = 10
    
    open override func size(forNumberOfPages pageCount: Int) -> CGSize {
        return CGSize(pointSize, pointSize);
    }
}

///横幅
open class BannerView: UIView, UICollectionViewDataSource, UICollectionViewDelegateFlowLayout {
    
    ///滚动视图
    public private(set) var collectionView: UICollectionView!

    ///滑动方向
    public private(set) var scrollDirection: UICollectionView.ScrollDirection = .horizontal

    ///动画间隔
    public var animatedTimeInterval: TimeInterval = 2.0 {
        didSet {
            if let timer = self.timer {
                let isExcuting = timer.isExcuting
                timer.timeInterval = self.animatedTimeInterval
                if isExcuting {
                    timer.start()
                }
            }
        }
    }

    ///当前可见下标
    private var _visiableIndex: Int = 0
    public var visibleIndex: Int {
        set{
            _visiableIndex = newValue
        }
        get{
            if let indexPath = collectionView.indexPathsForVisibleItems.first {
                return getActualIndex(from: indexPath.item)
            }
            return NSNotFound
        }
    }

    ///是否可以循环滚动  1个时不循环
    public var enableScrollInfinitly: Bool = true {
        didSet {
            if oldValue != self.enableScrollInfinitly {
                reloadData()
            }
        }
    }

    ///是否可以自动滚动
    public var enableAutoScroll: Bool = true {
        didSet {
            if self.enableAutoScroll && !self.isDecelerating && !self.isDragging {
                startAnimating()
            }else{
                stopAnimating()
            }
        }
    }

    ///是否显示页码
    public var showPageControl: Bool = false {
        didSet {
            if self.showPageControl {
                if self.pageControl == nil {
                    self.pageControl = PageControl()
                    self.pageControl!.hidesForSinglePage = true
                    self.pageControl!.addTarget(self, action: #selector(pageDidChange), for: .valueChanged)
                    addSubview(self.pageControl!)
                    
                    self.pageControl!.snp.makeConstraints { (make) in
                        make.centerX.equalTo(self)
                        make.bottom.equalTo(0)
                    }
                }
            }
            self.pageControl?.isHidden = !self.showPageControl;
        }
    }

    ///页码
    public var pageControl: PageControl?

    ///代理
    public weak var delegate: BannerViewDelegate?

    ///是否在拖动
    public var isDragging: Bool{
        self.collectionView.isDragging
    }

    ///是否在减速
    public var isDecelerating: Bool{
        self.collectionView.isDecelerating
    }

    ///数量
    public private(set) var numberOfItems: Int = 0
    
    ///计时器
    private var timer: CountDownTimer?

    ///起始位置
    private var contentOffset: CGPoint = .zero

    ///是否需要循环滚动
    private var shouldScrollInfinitly: Bool = false

    ///是否已经计算了
    private var isLayoutSubviews: Bool = false
    
    public init(scrollDirection: UICollectionView.ScrollDirection) {
        self.scrollDirection = scrollDirection
        super.init(frame: .zero)
        initViews()
    }
    
    public override init(frame: CGRect) {
        super.init(frame: frame)
        initViews()
    }
    
    public required init?(coder: NSCoder) {
        super.init(coder: coder)
        initViews()
    }

    ///初始化
    private func initViews() {
        let layout = UICollectionViewFlowLayout()
        layout.minimumLineSpacing = 0
        layout.minimumInteritemSpacing = 0
        layout.scrollDirection = scrollDirection
        
        collectionView = UICollectionView(frame: .zero, collectionViewLayout: layout)
        collectionView.isPagingEnabled = true
        collectionView.delegate = self
        collectionView.showsHorizontalScrollIndicator = false
        collectionView.showsVerticalScrollIndicator = false
        collectionView.backgroundColor = .clear
        collectionView.dataSource = self;
        collectionView.scrollsToTop = false
        if #available(iOS 11.0, *) {
            collectionView.contentInsetAdjustmentBehavior = .never
        }
        addSubview(collectionView)
    }
    
    open override func willMove(toWindow newWindow: UIWindow?) {
        if isLayoutSubviews {
            if newWindow != nil {
                startAnimating()
            } else {
                stopAnimating()
            }
        }
    }
    
    open override func layoutSubviews() {
        super.layoutSubviews()
        isLayoutSubviews = true
        
        if collectionView.frame.size != self.bounds.size {
            collectionView.frame = self.bounds
            fetchData()
        }
    }

    ///获取数据
    private func fetchData() {
        
        numberOfItems = delegate?.numberOfItems(in: self) ?? 0
        
        pageControl?.numberOfPages = numberOfItems
        pageControl?.currentPage = 0
        
        shouldScrollInfinitly = numberOfItems > 1 && enableScrollInfinitly
        collectionView.reloadData()
        
        if numberOfItems > 0 {
            scrollTo(index: 0, animated: false)
        }
        startAnimating()
    }

    ///重新加载数据
    public func reloadData() {
        if isLayoutSubviews {
            collectionView.reloadData()
        }
    }
    
    // MARK: -  Action

    //点击pageControl
    @objc
    private func pageDidChange() {
        scrollTo(index: pageControl!.currentPage, animated: true)
    }

    //获取实际的内容下标
    private func getActualIndex(from index: Int) -> Int {
        var pageIndex = index
        if shouldScrollInfinitly {
            pageIndex = index - 1
            if pageIndex < 0 {
                pageIndex = numberOfItems - 1
            }
            
            if pageIndex >= numberOfItems {
                pageIndex = 0
            }
        }
        
        return pageIndex
    }
}

/// Scroll
extension BannerView {
    
    ///开始动画
    private func startAnimating() {
        
        if !self.shouldScrollInfinitly || !self.enableAutoScroll {
            stopAnimating()
            return
        }
        
        if self.timer == nil {
            self.timer = CountDownTimer(timeToCountDown: CountDownTimer.countDownInfinite, interval: animatedTimeInterval)
            self.timer!.shouldStartImmediately = false
            self.timer!.onTick = { [weak self] _ in
                self?.scrollAnimated()
            }
        }
        
        if !self.timer!.isExcuting {
            self.timer!.start()
        }
    }

    ///停止动画
    private func stopAnimating(){
        if self.timer != nil && self.timer!.isExcuting {
            self.timer!.stop()
        }
    }
    
    ///滑动到某个位置
    private func scrollTo(index: Int, animated: Bool) {
        
        var index = index
        var count = numberOfItems
        if shouldScrollInfinitly {
            index += 1
            count += 2
        }
        
        if index < count {
            switch scrollDirection {
            case .horizontal :
                collectionView.scrollToItem(at: IndexPath(item: index, section: 0), at: .centeredHorizontally, animated: animated)
            case .vertical :
                collectionView.scrollToItem(at: IndexPath(item: index, section: 0), at: .centeredVertically, animated: animated)
            @unknown default:
                fatalError()
            }
        }
    }
    
    ///滚动动画
    private func pageChange(animated: Bool) {
        
        let page = visibleIndex
        if page < numberOfItems {
            scrollTo(index: page + 1, animated: animated)
        }
    }

    ///计时器滚动
    private func scrollAnimated() {
        if numberOfItems > 0 {
            pageChange(animated: true)
        }
    }
}

/// Cell
extension BannerView {
    
    ///注册cell
    public func registerNib(_ cls: AnyClass) {
        collectionView.registerNib(cls)
    }
    
    public func registerClass(_ cls: AnyClass) {
        collectionView.registerClass(cls)
    }

    ///复用cell
    public func dequeueReusableCell(withClass cls: AnyClass, for indexPath: IndexPath) -> UICollectionViewCell {
        dequeueReusableCell(withReuseidentifier: String(describing: cls), for: indexPath)
    }
    
    public func dequeueReusableCell(withReuseidentifier identifier: String, for indexPath: IndexPath) -> UICollectionViewCell {
        return collectionView.dequeueReusableCell(withReuseIdentifier: identifier, for: indexPath)
    }
    
    ///通过下标获取 cell 如果cell是在可见范围内
    public func cellForItem(at index: Int) -> UICollectionViewCell? {
        
        var index = index
        var count = numberOfItems
        if shouldScrollInfinitly {
            index += 1
            count += 2
        }
        if index < count {
            return collectionView.cellForItem(at: IndexPath(item: index, section: 0))
        }

        return nil
    }
}

/// UICollectionViewDelegate
extension BannerView {
    public func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        var count = numberOfItems
        if shouldScrollInfinitly {
            count += 2
        }
        return count
    }

    public func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        return collectionView.bounds.size
    }

    public func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        return delegate!.bannerView(self, cellForItemAt: indexPath, index: getActualIndex(from: indexPath.item))
    }
    
    public func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        collectionView.deselectItem(at: indexPath, animated: true)
        delegate?.bannerView?(self, didSelectItemAt: getActualIndex(from: indexPath.item))
    }
}

/// UIScrollViewDelegate
extension BannerView {
    
    public func scrollViewWillBeginDragging(_ scrollView: UIScrollView) {
        stopAnimating()
        contentOffset = scrollView.contentOffset
    }
    
    public func scrollViewDidEndDragging(_ scrollView: UIScrollView, willDecelerate decelerate: Bool) {
        
        if !decelerate {
            startAnimating()
            contentOffset = .zero
        }
    }
   
    public func scrollViewDidEndDecelerating(_ scrollView: UIScrollView) {
        
        if !scrollView.isDragging {
            startAnimating()
            contentOffset = .zero
        }
    }
    
    public func scrollViewDidScroll(_ scrollView: UIScrollView) {
        
        switch scrollDirection {
        case .horizontal :
            let pageWidth = scrollView.gkWidth
            let page = Int(floor(scrollView.contentOffset.x / pageWidth))
            
            if shouldScrollInfinitly {
                if page == 0 {
                    if contentOffset.x > scrollView.contentOffset.x {
                        collectionView .scrollRectToVisible(CGRect(pageWidth * (numberOfItems + 1).cgFloatValue, 0, pageWidth, scrollView.gkHeight), animated: false) // 最后+1,循环到第1页
                        contentOffset = CGPoint(pageWidth * (numberOfItems + 1).cgFloatValue, 0)
                        pageControl?.currentPage = numberOfItems - 1
                    }
                } else if page >= (numberOfItems + 1) {
                    if contentOffset.x < scrollView.contentOffset.x {
                        collectionView.scrollRectToVisible(CGRect(pageWidth, 0, pageWidth, scrollView.gkHeight), animated: false) // 最后+1,循环第1页
                        pageControl?.currentPage = 0
                    }
                } else {
                    pageControl?.currentPage = getActualIndex(from: page)
                }
            } else {
                pageControl?.currentPage = page
            }
            
        case .vertical :
            let pageHeight = scrollView.gkHeight
            let page = Int(floor(scrollView.contentOffset.y / pageHeight))
            
            if shouldScrollInfinitly {
                if page == 0 {
                    if contentOffset.y > scrollView.contentOffset.y {
                        collectionView.scrollRectToVisible(CGRect(0, pageHeight * (numberOfItems + 1).cgFloatValue, scrollView.gkWidth, pageHeight), animated: false) // 最后+1,循环到第1页
                        contentOffset = CGPoint(0, pageHeight * (numberOfItems + 1).cgFloatValue)
                        pageControl?.currentPage = numberOfItems - 1
                    }
                } else if page >= (numberOfItems + 1) {
                    if contentOffset.y < scrollView.contentOffset.y {
                        collectionView.scrollRectToVisible(CGRect(0, pageHeight, scrollView.gkWidth, pageHeight), animated: false) // 最后+1,循环第1页
                        pageControl?.currentPage = 0
                    }
                } else {
                    pageControl?.currentPage = getActualIndex(from: page)
                }
            } else {
                pageControl?.currentPage = page
            }
        @unknown default:
            fatalError()
        }
    }
}
