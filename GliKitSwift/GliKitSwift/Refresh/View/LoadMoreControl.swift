//
//  LoadMoreControl.swift
//  GliKitSwift
//
//  Created by 罗海雄 on 2020/3/27.
//  Copyright © 2020 luohaixiong. All rights reserved.
//

import UIKit

///UIScrollView 的内容大小
let dataControlContentSize = "contentSize"

///上拉加载视图，如果contentSize.height 小于frame.size.height 将无法上拉加载
open class LoadMoreControl: DataControl {
    
    ///加载更多的类
    public static var loadMoreControlClass: AnyClass = DefaultRefreshControl.self

    ///到达底部时是否自动加载更多
    public var autoLoadMore = true

    ///当 contentSize 为0时是否可以加载更多
    public var loadMoreEnableWhileZeroContent = false

    ///当没有数据时 是否停留在原地
    public var shouldStayWhileNoData = false

    ///是否是水平滑动 默认是垂直
    public var isHorizontal = false
    
    ///是否需要动画
    private var shouldAnimate = false
    
    
    open override func initViews() {
        super.initViews()
        
        state = .noData
        criticalPoint = 45
        addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(handleTap)))
        
        setTitle("加载更多", for: .normal)
        setTitle("加载中...", for: .loading)
        setTitle("松开即可加载", for: .reachCirticalPoint)
        setTitle("已到底部", for: .noData)
        setTitle("加载失败，点击重新加载", for: .fail)
    }
    
    open override func willMove(toSuperview newSuperview: UIView?) {
        super.willMove(toSuperview: newSuperview)
        newSuperview?.addObserver(self, forKeyPath: dataControlContentSize, options: .new, context: nil)
    }
    
    open override func removeFromSuperview() {
        superview?.removeObserver(self, forKeyPath: dataControlContentSize)
        super.removeFromSuperview()
    }

    open override func layoutSubviews() {
        super.layoutSubviews()
        
        //调整内容
        if let scrollView = self.scrollView {
            if self.isHorizontal {
                let minWidth = self.criticalPoint
                
                var frame = self.frame
                frame.size.height = scrollView.gkHeight
                frame.size.width = max(minWidth, scrollView.contentOffset.x + scrollView.gkWidth - scrollView.contentSize.width)
                frame.origin.x = scrollView.contentSize.width
                
                self.frame = frame
            }else{
                let minHeight = self.criticalPoint
                
                var frame = self.frame
                frame.size.width = scrollView.gkWidth
                frame.size.height = max(minHeight, scrollView.contentOffset.y + scrollView.gkHeight - scrollView.contentSize.height)
                frame.origin.y = scrollView.contentSize.height
                
                self.frame = frame
            }
        }
    }

    // MARK: - KVO

    open override func observeValue(forKeyPath keyPath: String?, of object: Any?, change: [NSKeyValueChangeKey : Any]?, context: UnsafeMutableRawPointer?) {
        
        if keyPath == dataControlOffset {
            
            onContentOffsetChange()
        } else if keyPath == dataControlContentSize {
            
            setNeedsLayout()
        }
    }
    
    ///contentOffset改变
    open func onContentOffsetChange(){
        
        if isHidden {
            return
        }
        
        switch state {
        case .noData, .fail, .loading :
            return
        default:
            break
        }
        
        if let scrollView = self.scrollView {
            if !loadMoreEnableWhileZeroContent && scrollView.contentSize == CGSize.zero {
                return
            }
            
            let contentSize = isHorizontal ? scrollView.contentSize.width : scrollView.contentSize.height
            let offset = isHorizontal ? scrollView.contentOffset.x : scrollView.contentOffset.y
            let size = isHorizontal ? scrollView.gkWidth : scrollView.gkHeight
            
            if contentSize == 0 || offset < contentSize - size || contentSize < size {
                return
            }
            
            if autoLoadMore {
                
                if offset >= contentSize - size - self.criticalPoint {
                    
                    beginLoadMore(false)
                }
            } else {
                
                if offset >= contentSize - size {
                    
                    if scrollView.isDragging {
                        if offset == contentSize - size {
                            state = .normal
                        } else if offset < contentSize - size + criticalPoint {
                            state = .pulling
                        } else {
                            state = .reachCirticalPoint
                        }
                    } else if offset >= contentSize - size + criticalPoint {
                        
                        beginLoadMore(true)
                    }
                }
            }
            
            if !animating {
                setNeedsLayout()
            }
        }
    }

    // MARK: - Super Method

    open override func scrollViewWillEndDragging(_ scrollView: UIScrollView, withVelocity velocity: CGPoint, targetContentOffset: UnsafeMutablePointer<CGPoint>) {
        onContentOffsetChange()
    }
    
    open override func startLoading() {
        super.startLoading()
        animating = false
        classForCoder.cancelPreviousPerformRequests(withTarget: self)
        beginLoadMore(false)
        setNeedsLayout()
    }

    open override func stopLoading() {
        scrollView?.contentInset = originalContentInset
        state = .normal
        scrollView?.isUserInteractionEnabled = true
    }

    ///开始加载更多
    private func beginLoadMore(_ animated: Bool){
        
        if animating {
            return
        }
        
        if animated {
            animating = true
            UIView.animate(withDuration: 0.25, animations: {
                var inset = self.originalContentInset
                if self.isHorizontal {
                    inset.right += self.criticalPoint
                } else {
                    inset.bottom += self.criticalPoint
                }
                self.scrollView?.contentInset = inset
            }) { (finish) in
                self.state = .loading
                self.animating = false
            }
            
        } else {
            
            state = .loading
            var inset = self.originalContentInset
            if self.isHorizontal {
                inset.right += self.criticalPoint
            } else {
                inset.bottom += self.criticalPoint
            }
            self.scrollView?.contentInset = inset
            
            self.scrollView?.contentInset = inset
            animating = false
        }
    }

    open override func onStateChange(_ state: DataControlState) {
        
        super.onStateChange(state)
        
        if let scrollView = self.scrollView {
            switch state {
            case .loading :
                if autoLoadMore || loadingDelay <= 0 {
                    onStartLoading()
                }else{
                    perform(#selector(onStartLoading), with: nil, afterDelay: loadingDelay)
                }
                
            case .noData :
                var inset = originalContentInset
                if isHorizontal {
                    inset.left = scrollView.contentInset.left
                    if shouldStayWhileNoData {
                        inset.right = criticalPoint
                    }
                } else {
                    inset.top = scrollView.contentInset.top
                    if shouldStayWhileNoData {
                        inset.bottom = criticalPoint
                    }
                }
                if shouldAnimate {
                    UIView.animate(withDuration: 0.25) {
                        scrollView.contentInset = inset
                    }
                }else{
                    scrollView.contentInset = inset
                }
                
            case .fail :
                var inset = originalContentInset
                if isHorizontal {
                    inset.left = scrollView.contentInset.left
                    inset.right = criticalPoint
                } else {
                    inset.top = scrollView.contentInset.top
                    inset.bottom = criticalPoint
                }
                if shouldAnimate {
                    UIView.animate(withDuration: 0.25) {
                        scrollView.contentInset = inset
                    }
                } else {
                    scrollView.contentInset = inset
                }
                
            default:
                break
            }
        }
    }

    ///已经没有更多信息可以加载
    open func noMoreInfo(){
        
        stopRefreshWithNoInfo()
    }

    ///加载失败
    open func loadFail(){
        
        scrollView?.isUserInteractionEnabled = true
        state = .fail
    }
    
    private func stopRefreshWithNoInfo(){
        
        scrollView?.isUserInteractionEnabled = true
        state = .noData
    }

    // MARK: - Action

    @objc private func handleTap(){
        
        if state != .loading && state != .noData {
            state = .loading
        }
    }
}
