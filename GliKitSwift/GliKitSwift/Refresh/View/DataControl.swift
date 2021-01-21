//
//  DataControl.swift
//  GliKitSwift
//
//  Created by 罗海雄 on 2020/3/27.
//  Copyright © 2020 luohaixiong. All rights reserved.
//

import UIKit

///刷新回调
public typealias DataControlCallback = () -> Void

///UIScrollView 的滚动位置
public let dataControlOffset = "contentOffset"

///滑动状态
public enum DataControlState{
    
    ///正在滑动
    case pulling
    
    ///状态正常，用户没有滑动
    case normal
    
    ///正在加载
    case loading
    
    ///到达临界点
    case reachCirticalPoint
    
    ///没有数据了
    case noData
    
    ///加载失败
    case fail
}

///下拉刷新和上拉加载的基类
open class DataControl: UIView {
    
    // MARK: - 变量

    ///关联的 scrollView
    public private(set) weak var scrollView: UIScrollView?

    ///触发的临界点 default is 下拉刷新 60，上拉加载 45
    public var criticalPoint: CGFloat = 0
    
    ///适配安全区域
    open var realCriticalPoint: CGFloat {
        criticalPoint
    }
    
    ///原来的内容 缩进
    public var originalContentInset = UIEdgeInsets.zero
    
    ///刷新回调 子类不需要调用这个
    public var callback: DataControlCallback?

    ///加载延迟
    public var loadingDelay: TimeInterval = 0.4
    
    ///停止延迟
    public var stopDelay: TimeInterval = 0.25

    ///下拉状态，很少需要主动设置该值
    public var state: DataControlState = .normal{
        didSet{
            if oldValue != self.state {
                onStateChange(self.state)
                if self.state == .loading && self.shouldDisableScrollViewWhenLoading {
                    self.scrollView?.isUserInteractionEnabled = false
                }
            }
        }
    }

    ///是否正在动画
    public var animating = false
    
    ///是否需要scrollView 停止响应点击事件 当加载中
    public var shouldDisableScrollViewWhenLoading = false
    
    ///标题
    private var titles = [DataControlState: String]()
        
    // MARK: - 初始化
    
    /**
    构造方法
    *@param scrollView x
    *@return 一个实例，frame和 scrollView的frame一样
    */
    required public init(scrollView: UIScrollView){
        
        super.init(frame: CGRect(x: 0, y: 0, width: scrollView.gkWidth, height: 0))
        self.scrollView = scrollView
        self.originalContentInset = scrollView.contentInset
        self.backgroundColor = scrollView.backgroundColor
        
        initViews()
    }
    
    ///初始化
    open func initViews(){
        
        self.autoresizingMask = .flexibleWidth;
    }
    
    required public init!(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    deinit {
        self.classForCoder.cancelPreviousPerformRequests(withTarget: self)
    }
    
    open override func willMove(toSuperview newSuperview: UIView?) {
        super.willMove(toSuperview: newSuperview)
        
        //添加 滚动位置更新监听
        newSuperview?.addObserver(self, forKeyPath: dataControlOffset, options: .new, context: nil)
    }
    
    open override func removeFromSuperview() {
        self.superview?.removeObserver(self, forKeyPath: dataControlOffset)
        super.removeFromSuperview()
    }
    
    // MARK: - 启动
    
    ///开始加载
    open func startLoading(){
        
    }
    
    ///停止加载 外部调用 默认延迟刷新UI
    open func stopLoading(){
        
        if stopDelay > 0 {
            perform(#selector(onStopLoading), with: nil, afterDelay: self.stopDelay)
        } else {
            onStopLoading()
        }
    }
    
    // MARK: - 回调

    ///已经开始加载 默认调用回调
    @objc open func onStartLoading(){
        
        callback?()
    }

    ///已经停止加载 默认 恢复 insets动画
    @objc open func onStopLoading(){
        
        UIView.animate(withDuration: 0.25, animations: {
            self.scrollView?.contentInset = self.originalContentInset
        }, completion: { (finish) in
            self.state = .normal
            self.scrollView?.isUserInteractionEnabled = true
        })
    }

    ///刷新状态改变 子类可通过这个改变UI
    open func onStateChange(_ state: DataControlState){
        
    }
    
    // MARK: - 标题

    ///获取对应状态的标题 没有则返回normal的标题
    public func titleForState(_ state: DataControlState) -> String?{
        
        var title = titles[state]
        if title == nil {
            title = titles[.normal]
        }
        return title
    }

    ///设置对应状态的标题
    public func setTitle(_ title: String?, for state: DataControlState){
        
        titles[state] = title
        if state == self.state {
            onStateChange(state)
        }
    }
    
    ///UIScrollView 代理，主要用于当刚好到到达临界点时 松开手时获取contentOffset无法满足临界点
    open func scrollViewWillEndDragging(_ scrollView: UIScrollView, withVelocity velocity: CGPoint, targetContentOffset: UnsafeMutablePointer<CGPoint>) {
        
    }
}
