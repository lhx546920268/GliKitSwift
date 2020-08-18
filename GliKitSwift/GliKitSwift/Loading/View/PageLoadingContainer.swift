//
//  GKPageLoadingContainer.swift
//  GliKitSwift
//
//  Created by 罗海雄 on 2020/1/20.
//  Copyright © 2020 luohaixiong. All rights reserved.
//

import UIKit

///状态
public enum PageLoadingStatus{
    
    ///什么都没
    case none
    
    ///加载中
    case loading
    
    ///加载出错了
    case error
}

///页面加载显示容器代理
public protocol PageLoadingContainer: UIView {
    
    ///设置是否是加载中
    var status: PageLoadingStatus { get set }
    
    ///刷新回调
    var refreshCallback: (() -> Void)? { get set }
    
    ///开始动画
    func startAnimating()
    
    ///停止动画
    func stopAnimating()
}

///页面加载显示的容器
open class PageLoadingView: UIView, PageLoadingContainer {
    
    ///错误内容视图
    public private(set) var errorContentView: PageErrorContentView?

    ///loading内容视图
    public private(set) var loadingContentView: PageLoadingContentView?
    
    // MARK: - PageLoadingContainer
    
    ///状态
    public var status: PageLoadingStatus = .loading{
        didSet {
            if oldValue != self.status {
                statusDidChange()
            }
        }
    }
    
    ///刷新回调
    public var refreshCallback: (() -> Void)?
    
    public func startAnimating() {
        loadingContentView?.indicatorView.startAnimating()
    }
    
    public func stopAnimating() {
        loadingContentView?.indicatorView.stopAnimating()
    }
    
    // MARK: - Internal
    
    open override func willMove(toWindow newWindow: UIWindow?) {
        
        if newWindow != nil && status == .none {
            startAnimating()
        } else {
            stopAnimating()
        }
    }

    ///状态改变
    private func statusDidChange(){
        
        switch status {
        case .none :
            
            stopAnimating()
            loadingContentView?.isHidden = true
            errorContentView?.isHidden = true
        case .loading :
            
            createLoadingViewIfNeeded()
            loadingContentView?.isHidden = false
            startAnimating()
            errorContentView?.isHidden = true
        case .error :
            
            createErrorViewIfNeeded()
            stopAnimating()
            loadingContentView?.isHidden = true
            errorContentView?.isHidden = false
        }
    }
    
    ///创建loading内容
    private func createLoadingViewIfNeeded(){
        
        if loadingContentView == nil {
            
            let view = PageLoadingContentView()
            addSubview(view)
            
            view.snp.makeConstraints { maker in
                maker.center.equalTo(0)
            }
            
            loadingContentView = view
        }
    }
    
    ///创建error
    private func createErrorViewIfNeeded(){
        if errorContentView == nil {
            
            let view = PageErrorContentView()
            addSubview(view)
            
            view.snp.makeConstraints { (maker) in
                maker.leading.equalTo(10)
                maker.trailing.equalTo(-10)
                maker.centerY.equalTo(0)
            }
            addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(self.handleRefresh)))
            
            errorContentView = view
        }
    }
    
    // MARK: - Action
    @objc private func handleRefresh() {
        if status == .error {
            refreshCallback?()
        }
    }
}

///页面加载内容视图
open class PageLoadingContentView: UIView {
    
    ///loading
    public let indicatorView = UIActivityIndicatorView(style: .gray)
    
    ///加载出错提示文字
    public let textLabel: UILabel = {
       
        let label = UILabel()
        label.font = .systemFont(ofSize: 14)
        label.text = "加载中..."
        
        return label
    }()
    
    public override init(frame: CGRect) {
        super.init(frame: frame)
        initParams()
    }
    
    public required init?(coder: NSCoder) {
        super.init(coder: coder)
        initParams()
    }
    
    func initParams(){
        
        addSubview(indicatorView)
        indicatorView.snp.makeConstraints { maker in
            maker.leading.equalTo(0)
            maker.top.greaterThanOrEqualTo(0)
            maker.bottom.greaterThanOrEqualTo(0)
        }
        
        addSubview(textLabel)
        textLabel.snp.makeConstraints { maker in
            maker.leading.equalTo(indicatorView.snp.trailing).offset(5)
            maker.trailing.top.bottom.equalTo(0)
        }
    }
}

///页面加载错误视图
open class PageErrorContentView: UIView {
    
    ///图标
    public let imageView = UIImageView(image: UIImage(named: "network_error_icon"))
    
    ///加载出错提示文字
    public let textLabel: UILabel = {
       
        let label = UILabel()
        label.font = .systemFont(ofSize: 14)
        label.text = "加载失败\n轻触屏幕刷新."
        label.numberOfLines = 0
        label.textAlignment = .center
        label.textColor = UIColor.gkColorFromHex("aeaeae")
        
        return label
    }()
    
    public override init(frame: CGRect) {
        super.init(frame: frame)
        initParams()
    }
    
    public required init?(coder: NSCoder) {
        super.init(coder: coder)
        initParams()
    }
    
    func initParams(){
        
        addSubview(imageView)
        imageView.snp.makeConstraints { maker in
            maker.centerX.top.equalTo(0)
        }
        
        addSubview(textLabel)
        textLabel.snp.makeConstraints { maker in
            maker.leading.trailing.bottom.equalTo(0)
            maker.top.equalTo(imageView.snp.bottom).offset(25)
        }
    }
}
