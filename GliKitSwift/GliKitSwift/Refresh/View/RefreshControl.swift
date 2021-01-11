//
//  RefreshControl.swift
//  GliKitSwift
//
//  Created by 罗海雄 on 2020/3/30.
//  Copyright © 2020 luohaixiong. All rights reserved.
//

import UIKit

///下拉刷新控制视图
open class RefreshControl: DataControl {
    
    ///下拉刷新的类
    public static var refreshControlClass: AnyClass = DefaultRefreshControl.self

    ///加载完成的提示信息
    public var finishText = "刷新成功"
        
    open override func initViews() {
        super.initViews()
        criticalPoint = 60
        setTitle("下拉刷新", for: .normal)
        setTitle("加载中...", for: .loading)
        setTitle("松开即可刷新", for: .reachCirticalPoint)
    }
    
    open override func layoutSubviews() {
        super.layoutSubviews()
        
        if let scrollView = self.scrollView {
            var frame = self.bounds
            frame.size.height = max(criticalPoint, -scrollView.contentOffset.y + originalContentInset.top)
            frame.origin.y = -frame.size.height
            self.frame = frame
        }
    }

    // MARK: - kvo

    open override func observeValue(forKeyPath keyPath: String?, of object: Any?, change: [NSKeyValueChangeKey : Any]?, context: UnsafeMutableRawPointer?) {
        
        if let scrollView = self.scrollView {
            let y = scrollView.contentOffset.y
            if y <= 0  && keyPath == dataControlOffset {
                if state == .loading {
                    if !animating {
                        if scrollView.isDragging {
                            if y == 0.0 {
                                state = .normal
                            }else if y > -realCriticalPoint {
                                state = .pulling
                            }else{
                                state = .reachCirticalPoint
                            }
                        }else if y <= -realCriticalPoint || state == .reachCirticalPoint {
                            startLoading()
                        }
                    }
                }
                
                if !animating {
                    setNeedsLayout()
                }
            }
        }
    }

    open override var realCriticalPoint: CGFloat {
        var point = super.realCriticalPoint
        if #available(iOS 11, *) {
            point += scrollView?.adjustedContentInset.top ?? 0
        }
        return point
    }
    
    // MARK: - super method

    open override func startLoading() {
        
        if !animating {
            animating = true
            UIView.animate(withDuration: 0.25, animations: {
                var inset = self.originalContentInset
                inset.top = self.criticalPoint
                self.scrollView?.contentInset = inset
                self.scrollView?.contentOffset = CGPoint(x: 0, y: -self.criticalPoint)
            }) { (finish) in
                self.state = .loading
                self.animating = false
            }
        }
    }

    open override func onStateChange(_ state: DataControlState) {
        
        super.onStateChange(state)
        switch state {
        case .loading :
            if loadingDelay > 0 {
                perform(#selector(onStartLoading), with: nil, afterDelay: loadingDelay)
            } else {
                onStartLoading()
            }
        default:
            break
        }
    }
}
