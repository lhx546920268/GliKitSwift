//
//  PageView.swift
//  GliKitSwift
//
//  Created by 罗海雄 on 2020/8/26.
//  Copyright © 2020 luohaixiong. All rights reserved.
//

import UIKit

private var reusableIdentifierKey: UInt8 = 0
private var pageIndexKey: UInt8 = 0

///主要用于翻页视图 子视图重用
fileprivate extension UIView {
    
    ///复用标识
    var gkReusableIdentifier: String? {
        set{
            objc_setAssociatedObject(self, &reusableIdentifierKey, newValue, .OBJC_ASSOCIATION_COPY)
        }
        get{
            objc_getAssociatedObject(self, &reusableIdentifierKey) as? String
        }
    }
    
    //下标
    var gkPageIndex: Int? {
        set{
            objc_setAssociatedObject(self, &pageIndexKey, newValue, .OBJC_ASSOCIATION_COPY)
        }
        get{
            objc_getAssociatedObject(self, &pageIndexKey) as? Int
        }
    }
}

///主要是为了重写hitTest
fileprivate class PageScrollView: UIScrollView {
    
    override func hitTest(_ point: CGPoint, with event: UIEvent?) -> UIView? {
        //让超出UIScrollView范围的 响应点击事件
        let view = super.hitTest(point, with: event)
        if view == nil {
            let subviews = self.subviews
            for subview in subviews.reversed() {
                if !subview.isHidden
                    && subview.alpha > 0.01
                    && subview.isUserInteractionEnabled
                    && subview.frame.contains(point) {
                    return subview
                }
            }
        }
        return view
    }
}

///翻页视图代理
@objc public protocol PageViewDelegate: NSObjectProtocol {
    
    ///Item数量
    func numberOfItems(in pageView: PageView) -> Int
    
    ///获取index对应的item
    func pageView(_ pageView: PageView, cellForItemAt index: Int) -> UIView
    
    ///点击某个item了
    @objc optional func pageView(_ pageView: PageView, didSelectItemAt index: Int)
    
    ///某个item居中了
    @objc optional func pageView(_ pageView: PageView, didMiddleItemAt index: Int)
}

///翻页视图
open class PageView: UIView, UIScrollViewDelegate {
    
    ///内部的ScrollView
    public private(set) lazy var scrollView: UIScrollView = {
        let scrollView = UIScrollView(frame: bounds)
        scrollView.delegate = self
        scrollView.showsVerticalScrollIndicator = false
        scrollView.showsHorizontalScrollIndicator = false
        scrollView.scrollsToTop = false
        scrollView.clipsToBounds = false
        scrollView.isPagingEnabled = true
        
        if #available(iOS 11.0, *) {
            scrollView.contentInsetAdjustmentBehavior = .never
        }
        addSubview(scrollView)
        return scrollView
    }()
    
    ///item占比，值必须在 `0.1 ~ 1.0`
    @RangeWrapper(value: 1.0, min: 0.1, max: 1.0)
    public var ratio: CGFloat
    
    ///item间隔
    public var spacing: CGFloat = 0
    
    ///次要的item 缩放比例 值必须在 `0.1 ~ 1.0`
    @RangeWrapper(value: 1.0, min: 0.1, max: 1.0)
    public var scale: CGFloat
    
    ///是否可以循环滚动  1个cell时不循环
    public var scrollInfinitely: Bool = true
    
    ///当前位置
    public private(set) var currentPage: Int = NSNotFound
    
    ///点击边缘item时是否先居中，如果YES
    ///pageView:(GKPageView*) pageView didSelectItemAtIndex:(NSInteger) index将不会回调
    public var shouldMiddleItem: Bool = true
    
    ///播放间隔
    @RangeWrapper(value: 5.0, min: 1.0, max: TimeInterval.infinity)
    public var playTimeInterval: TimeInterval
    
    ///是否自动播放
    public var autoPlay: Bool = true
    
    ///代理
    public weak var delegate: PageViewDelegate?
    
    ///item总数
    private var numberOfItems: Int = 0
    
    ///当前可见的cell
    private lazy var visibleCells: [Int: UIView] = {
        return [Int : UIView]()
    }()
    private lazy var visibleSet: Set<UIView> = {
        return Set<UIView>()
    }()
    
    ///可重用的cell
    private lazy var reusableCells: [String: Set<UIView>] = {
        return [String: Set<UIView>]()
    }()
    
    ///注册的cell
    private lazy var registerCells: [String: Any] = {
        return [String: Any]()
    }()
    
    ///旧的大小
    private var oldSize: CGSize = .zero
    
    ///滑动方向
    private var scrollDirection: ScrollDirection!
    
    ///是否需要循环滚动
    private var shouldScrollInfinitely: Bool = false
    
    ///起始位置
    private var contentOffset: CGPoint = .zero
    
    ///获取页面大小
    private var pageSize: CGFloat {
        switch scrollDirection {
            
        case .horizontal :
            return floor(ratio * gkWidth)
        case .vertical :
            return floor(ratio * gkHeight)
        case .none :
            return 0
        }
    }
    
    ///当前要显示的item数量
    private var numberOfNeededItems: Int {
        var count = numberOfItems
        if(shouldScrollInfinitely){
            count += 4
        }
        return count
    }
    
    ///计时器
    private var timer: CountDownTimer?
    
    ///创建一个实例
    public override init(frame: CGRect) {
        super.init(frame: frame)
        scrollDirection = .horizontal
        initParams()
    }
    
    public required init?(coder: NSCoder) {
        super.init(coder: coder)
        scrollDirection = .horizontal
        initParams()
    }
    
    public init(scrollDirection: ScrollDirection) {
        super.init(frame: .zero)
        self.scrollDirection = scrollDirection
        initParams()
    }
    
    func initParams(){
        clipsToBounds = true
    }
    
    ///注册cell
    public func registerNib(_ cls: AnyClass) {
        let name = String(describing: cls)
        registerCells[name] = UINib(nibName: name, bundle: nil)
    }
    
    public func registerClass(_ cls: AnyClass) {
        registerCells[String(describing: cls)] = cls
    }
    
    ///复用cell
    public func dequeueCell(withClass cls: AnyClass, for index: Int) -> UIView {
        return dequeueCell(withIdentifier: String(describing: cls), for: index)
    }
    
    
    ///重新加载数据
    public func reloadData() {
        
        visibleSet.removeAll()
        visibleCells.removeAll()
        reusableCells.removeAll()
        gkRemoveAllSubviews()
        
        layoutIfEnabled()
    }
    
    ///滚动到指定的cell
    public func scrollTo(_ index: Int, animated: Bool) {
        
        var index = index
        var count = numberOfItems
        let originIndex = index
        if shouldScrollInfinitely {
            index += 2
            count += 4
        }
        
        if index >= 0 && index < count {
            contentOffset = scrollView.contentOffset
            //如果当前是第一个或者最后一个item，反向滑动
            if currentPage == 0 && originIndex == numberOfItems - 1 {
                index = 1
            }else if currentPage == numberOfItems - 1 && originIndex == numberOfItems - 2 {
                index = 0
            }
            
            let value = offset(for: index)
            
            switch scrollDirection {
            case .horizontal :
                scrollView.setContentOffset(CGPoint(value, 0), animated: animated)
                
            case .vertical :
                scrollView.setContentOffset(CGPoint(0, value), animated: animated)
                
            case .none :
                break
            }
            
            if !animated {
                adjustItemPosition()
            }
        }
    }
    
    ///通过下标获取 cell 如果cell是在可见范围内
    public func cellForIndex(_ index: Int) -> UIView?{
        var index = index
        if shouldScrollInfinitely {
            index += 2
        }
        return cellForIndex(index, shouldInit: false)
    }
    
    // MARK: - layout
    open override func layoutSubviews() {
        super.layoutSubviews()
        
        if !bounds.size.equalTo(oldSize) {
            oldSize = bounds.size
            layoutIfEnabled()
        }
    }
    
    ///准备布局
    private func prelayout() {
        numberOfItems = delegate?.numberOfItems(in: self) ?? 0
        shouldScrollInfinitely = scrollInfinitely && numberOfItems > 1
        currentPage = numberOfItems > 0 ? 0 : NSNotFound
        
        let count = numberOfNeededItems
        switch scrollDirection {
        case .horizontal :
            let pageWidth = pageSize + spacing
            let margin = (gkWidth - pageWidth) / 2
            scrollView.frame = CGRect(margin, 0, pageWidth, gkHeight)
            scrollView.contentSize = CGSize(count.cgFloatValue * scrollView.gkWidth, scrollView.gkHeight)
            
        case .vertical :
            let pageHeight = pageSize + spacing
            let margin = (gkHeight - pageHeight) / 2
            scrollView.frame = CGRect(0, margin, gkWidth, pageHeight);
            scrollView.contentSize = CGSize(scrollView.gkWidth, count.cgFloatValue * scrollView.gkHeight);
            
        case .none :
            break
        }
    }
    
    private func layoutIfEnabled() {
        if !bounds.size.equalTo(.zero) {
            prelayout()
            if numberOfItems > 0 {
                scrollTo(0, animated: false)
            }
            layoutItems()
            startAnimating()
        }
    }
    
    ///重新布局子视图
    private func layoutItems() {
        if numberOfItems <= 0 {
            return;
        }
        
        switch scrollDirection {
        case .horizontal :
            layoutHorizontalItems()
            
        case .vertical :
            layoutVerticalItems()
            
        case .none :
            break
        }
    }
    
    private func layoutHorizontalItems() {
        let offsetX = scrollView.contentOffset.x
        let pageWidth = pageSize
        let left = spacing / 2
        let count = numberOfNeededItems
        
        let pageIndex = max(floor(offsetX / (pageWidth + spacing)), 0).intValue
        
        //显示当前item
        configureCell(for: pageIndex)
        
        //显示后面的 并且在可见范围内的
        var nextPageIndex = pageIndex + 1
        var x = left + nextPageIndex.cgFloatValue * (pageWidth + spacing)
        while nextPageIndex < count && x < offsetX + scrollView.gkRight {
            configureCell(for: nextPageIndex)
            x += pageWidth + spacing
            nextPageIndex += 1
        }
        
        //显示前面的
        var previousPageIndex = pageIndex - 1
        x = left + previousPageIndex.cgFloatValue * (pageWidth + spacing)
        while previousPageIndex >= 0 && x + pageWidth > offsetX - scrollView.gkLeft {
            configureCell(for: previousPageIndex)
            x -= pageWidth + spacing
            previousPageIndex -= 1
        }
        
        recycleInvisibleCells()
    }
    
    private func layoutVerticalItems() {
        let offsetY = scrollView.contentOffset.y
        let pageHeight = pageSize
        let top = spacing / 2
        let count = numberOfNeededItems
        
        let pageIndex = max(floor(offsetY / (pageHeight + spacing)), 0).intValue
        
        //显示当前item
        configureCell(for: pageIndex)
        
        //显示后面的 并且在可见范围内的
        var nextPageIndex = pageIndex + 1
        var y = top + nextPageIndex.cgFloatValue * (pageHeight + spacing)
        while nextPageIndex < count && y < offsetY + scrollView.gkBottom {
            configureCell(for: nextPageIndex)
            y += pageHeight + spacing
            nextPageIndex += 1
        }
        
        //显示前面的
        var previousPageIndex = pageIndex - 1
        y = top + previousPageIndex.cgFloatValue * (pageHeight + spacing)
        while previousPageIndex >= 0 && y + pageHeight > offsetY - scrollView.gkTop {
            configureCell(for: previousPageIndex)
            y -= pageHeight + spacing
            previousPageIndex -= 1
        }
        
        recycleInvisibleCells()
    }
    
    //配置cell
    private func configureCell(for index: Int) {
        let cell = cellForIndex(index, shouldInit: true)!
        cell.transform = .identity
        let pageSize = self.pageSize
        
        switch scrollDirection {
        case .horizontal :
            cell.frame = CGRect(offset(for: index) + spacing / 2, 0, pageSize, gkHeight)
            if scale < 1.0 {
                let center = scrollView.convert(cell.center, to: self)
                let scale = 1.0 - (1.0 - self.scale) * abs(center.x - scrollView.center.x) / (pageSize + spacing)
                cell.transform = CGAffineTransform(scaleX: scale, y: scale)
            }
            
        case .vertical :
            cell.frame = CGRect(0, offset(for: index) + spacing / 2, gkWidth, pageSize)
            if scale < 1.0 {
                let center = scrollView.convert(cell.center, to: self)
                let scale = 1.0 - (1.0 - self.scale) * abs(center.y - scrollView.center.y) / (pageSize + spacing);
                cell.transform = CGAffineTransform(scaleX: scale, y: scale)
            }
            
        case .none :
            break
        }
        visibleCells[index] = cell
        visibleSet.insert(cell)
    }
    
    ///获取对应下标的偏移量
    private func offset(for index: Int) -> CGFloat {
        return index.cgFloatValue * (pageSize + spacing)
    }
    
    ///获取某个cell，如果shouldInit，可见的cell不存在时会创建一个
    private func cellForIndex(_ index: Int, shouldInit: Bool) -> UIView? {
        var cell = visibleCells[index]
        if cell == nil && shouldInit {
            cell = delegate?.pageView(self, cellForItemAt: getActualIndex(from: index))
        }
        
        return cell
    }
    
    // MARK: - instantitate cell
    
    ///从队列里面获取可重用的cell，如果没有会实例化一个新的
    private func dequeueCell(withIdentifier identifier: String, for index: Int) -> UIView {
        var set = reusableCells[identifier]
        var cell = set?.popFirst()
        if cell == nil {
            cell = instantitateView(forIdentifier: identifier)
        } else {
            reusableCells[identifier] = set
        }
        
        cell!.gkPageIndex = index
        scrollView.addSubview(cell!)
        
        return cell!
    }
    
    ///实例化一个新的cell
    private func instantitateView(forIdentifier identifier: String) -> UIView {
        var cell: UIView?
        let cls = registerCells[identifier]
        assert(cls != nil, "\(NSStringFromClass(classForCoder)) cell for \(identifier) does not register")
        
        if cls is UINib {
            let nib = cls as! UINib
            cell = nib.instantiate(withOwner: nil, options: nil).last as? UIView
        }else{
            let viewCls = cls as? UIView.Type
            cell = viewCls?.init()
        }
        
        assert(cell != nil, "\(NSStringFromClass(classForCoder)) cell for \(identifier) can not init")
        
        cell!.gkReusableIdentifier = identifier;
        cell!.addGestureRecognizer(UIGestureRecognizer(target: self, action: #selector(handleTap(_:))))
        cell!.isUserInteractionEnabled = true
        
        return cell!
    }
    
    ///点击某个item了
    @objc private func handleTap(_ tap: UITapGestureRecognizer) {
        let index = tap.view!.gkPageIndex!
        if shouldMiddleItem && index != currentPage {
            scrollTo(index, animated: true)
            delegate?.pageView?(self, didMiddleItemAt: index)
        } else {
            delegate?.pageView?(self, didSelectItemAt: index)
        }
    }
    
    // MARK: - Recycle
    
    /////回收不可见的
    private func recycleInvisibleCells() {
        let subviews = scrollView.subviews
        for view in subviews {
            if !visibleSet.contains(view) {
                recycleCell(view)
            }
        }
    }
    
    ///回收
    private func recycleCell(_ cell: UIView) {
        var set = reusableCells[cell.gkReusableIdentifier!]
        if set == nil {
            set = Set<UIView>()
        }
        set?.insert(cell)
        reusableCells[cell.gkReusableIdentifier!] = set
        visibleCells.removeValue(forKey: cell.gkPageIndex!)
        visibleSet.remove(cell)
        cell.removeFromSuperview()
    }
    
    // MARK: -  private method
    
    ///获取实际的内容下标
    private func getActualIndex(from index: Int) -> Int {
        var pageIndex = index
        
        if scrollInfinitely {
            pageIndex = index - 2
            if pageIndex < 0 {
                pageIndex += numberOfItems
            }
            
            if pageIndex >= numberOfItems {
                pageIndex -= numberOfItems
            }
        }
        return pageIndex
    }
    
    open override func hitTest(_ point: CGPoint, with event: UIEvent?) -> UIView? {
        //让超出UIScrollView范围的 响应点击事件
        var view = super.hitTest(point, with: event)
        if view == self {
            view = scrollView
        }
        
        return view
    }
    
    // MARK: -  timer
    
    open override func willMove(toWindow newWindow: UIWindow?) {
        if !bounds.size.equalTo(.zero) {
            if newWindow != nil {
                startAnimating()
            }else{
                stopAnimating()
            }
        }
    }
    
    ///开始动画
    private func startAnimating() {
        if !shouldScrollInfinitely || !autoPlay {
            stopAnimating()
            return
        }
        
        if timer == nil {
            timer = CountDownTimer(timeToCountDown: CountDownTimer.countDownInfinite, interval: playTimeInterval)
            timer?.shouldStartImmediately = false
            timer?.onTick = { [weak self] _ in
                self?.scrollAnimated()
            }
        }
        if !timer!.isExcuting {
            timer?.start()
        }
    }
    
    ///结束动画
    private func stopAnimating() {
        if timer != nil && timer!.isExcuting {
            timer?.stop();
        }
    }
    
    //.计时器滚动
    private func scrollAnimated(){
        if numberOfItems == 0 {
            return
        }
        pageChanged(animated: true)
    }
    
    ///滚动动画
    private func pageChanged(animated: Bool) {
        let page = currentPage // 获取当前的page
        if page < numberOfItems {
            scrollTo(page + 1, animated: animated)
        }
    }
    
}

extension PageView {
    
    ///翻页视图滑动方向
    public enum ScrollDirection {
        
        ///水平
        case horizontal
        
        ///垂直
        case vertical
    }
}

extension PageView {
    
    public func scrollViewWillBeginDragging(_ scrollView: UIScrollView) {
        contentOffset = scrollView.contentOffset
        stopAnimating()
    }
    
    public func scrollViewDidEndDragging(_ scrollView: UIScrollView, willDecelerate decelerate: Bool) {
        if !decelerate {
            startAnimating()
            adjustItemPosition()
        }
    }
    
    public func scrollViewDidEndDecelerating(_ scrollView: UIScrollView) {
        if !scrollView.isDragging {
            startAnimating()
            adjustItemPosition()
        }
    }
    
    public func scrollViewDidEndScrollingAnimation(_ scrollView: UIScrollView) {
        adjustItemPosition()
    }
    
    ///调整位置
    private func adjustItemPosition() {
        switch scrollDirection {
        case .horizontal :
            
            let page = max(0, floor(scrollView.contentOffset.x / (pageSize + spacing))).intValue
            
            if shouldScrollInfinitely {
                if page == 0 {
                    if contentOffset.x > scrollView.contentOffset.x {
                        scrollView.contentOffset = CGPoint(offset(for: numberOfItems), 0) // 最后+1,循环到第1页
                        currentPage = 0
                    }
                }else if page >= (numberOfItems + 1) {
                    
                    if contentOffset.x < scrollView.contentOffset.x {
                        scrollView.contentOffset = CGPoint(offset(for: 1), 0) // 最后+1,循环第1页
                        currentPage = numberOfItems - 1
                    }
                }else{
                    currentPage = getActualIndex(from: page)
                }
            }else{
                currentPage = page
            }
            
        case .vertical :
            let page = floor(scrollView.contentOffset.y / (pageSize + spacing)).intValue
            
            if shouldScrollInfinitely {
                if page == 0 {
                    if contentOffset.y > scrollView.contentOffset.y {
                        scrollView.contentOffset = CGPoint(0, offset(for: numberOfItems)) // 最后+1,循环到第1页
                        currentPage = 0
                    }
                }else if page >= (numberOfItems + 1) {
                    if contentOffset.y < scrollView.contentOffset.y {
                        scrollView.contentOffset = CGPoint(0, offset(for: 1)) // 最后+1,循环第1页
                        currentPage = numberOfItems - 1
                    }
                }else{
                    currentPage = getActualIndex(from: page)
                }
            }else{
                currentPage = page
            }
            
        case .none :
            break
        }
        
        layoutItems()
        contentOffset = .zero
    }
}
