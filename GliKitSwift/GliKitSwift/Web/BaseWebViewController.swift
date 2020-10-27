//
//  BaseWebViewController.swift
//  GliKitSwift
//
//  Created by 罗海雄 on 2020/10/26.
//  Copyright © 2020 luohaixiong. All rights reserved.
//

import UIKit
import WebKit

public extension String {
    
    ///适配屏幕的html字符串，把它加在html的前面
    static var gkAdjustScreenHtmlString: String {
        "<style>img {width:100%;}</style><meta name=\"viewport\" content=\"width=device-width, initial-scale=1\"/>"
    }
}

///当前系统默认的 userAgent
private var systemUserAgent: String?

///使用单例 防止 存储信息不一致
private let sharedProcessPool = WKProcessPool()

///基础Web 视图控制器
open class BaseWebViewController: BaseViewController {
    
    ///网页视图
    public private(set) lazy var webView: WKWebView = {
        let webView = WKWebView(frame: .zero, configuration: configuration)
        webView.allowsLinkPreview = false
        if #available(iOS 11.0, *) {
            webView.scrollView.contentInsetAdjustmentBehavior = .never
        }
        
        webView.navigationDelegate = self
        webView.isOpaque = false
        webView.uiDelegate = self
        webView.scrollView.delegate = self
        webView.scrollView.backgroundColor = .clear
        titleObservation = webView.observe(\.title, options: .new) { [weak self] (view, _) in
            self?.navigationItem.title = view.title
        }
        progressObservation = webView.observe(\.estimatedProgress, options: .new, changeHandler: { [weak self] (view, _) in
            self?.onProgressChange(view.estimatedProgress.cgFloatValue)
        })
        
        return webView
    }()
    
    ///监听标题和加载进度
    private var titleObservation: NSKeyValueObservation?
    private var progressObservation: NSKeyValueObservation?
    
    ///加载进度条
    private lazy var progressView: ProgressView = {
        let view = ProgressView(style: .straightLine)
        view.progressColor = UIColor(red: 0, green: 0.4784314, blue: 1.0, alpha: 1.0)
        view.trackColor = .clear
        
        return view
    }()

    ///获取userAgent的 webView，因为 在iOS 12中，在调用 navigatior.userAgent 后，设置customUserAgent会不生效
    private var userAgentWebView: WKWebView?
    
    ///网页配置
    private lazy var configuration: WKWebViewConfiguration = {
       
        let controller = WKUserContentController()
        let js = javascript
        if shouldCloseSystemLongPressGesture || !String.isEmpty(js) {
            let script = NSMutableString()
            if shouldCloseSystemLongPressGesture {
                //禁止长按弹出 UIMenuController 相关
                //禁止选择 css 配置相关
                //css 选中样式取消
                let css = "('body{-webkit-user-select:none;-webkit-user-drag:none;}')"
                script.append("var style = document.createElement('style');")
                script.append("style.type = 'text/css';")
                script.append("var cssContent = document.createTextNode\(css);")
                script.append("style.appendChild(cssContent);")
                script.append("document.body.appendChild(style);")
                script.append("document.documentElement.style.webkitUserSelect='none';")//禁止选择
                script.append("document.documentElement.style.webkitTouchCallout='none';")//禁止长按
            }
            
            if !String.isEmpty(js) {
                script.append(js!)
            }
            
            controller.addUserScript(WKUserScript(source: String(script), injectionTime: .atDocumentEnd, forMainFrameOnly: true))
        }
    
        let config = WKWebViewConfiguration()
        config.userContentController = controller
        config.processPool = sharedProcessPool
        
        return config
    }()

    // MARK: - Web Config

    ///是否关闭系统的长按手势
    public var shouldCloseSystemLongPressGesture: Bool = false

    ///是否使用 web里面的标题，使用会self.navigationItem.title 替换成web的标题
    public var useWebTitle: Bool = true

    ///载入htmlString 是否根据屏幕适配
    public var adjustScreenWhenLoadHtmlString: Bool = false

    ///是否需要显示进度条
    public var shouldDisplayProgress: Bool = true {
        didSet {
            if oldValue != shouldDisplayProgress {
                progressView.isHidden = !shouldDisplayProgress || progressView.progress == 0
            }
        }
    }

    ///返回需要注入的js
    public var javascript: String? {
        nil
    }

    ///返回需要设置的自定义 userAgent 会拼在系统的userAgent后面
    public var customUserAgent: String? {
        nil
    }

    // MARK: - 内容

    ///当前链接
    public var currentUrl: URL? {
        webView.url
    }

    ///第一个链接
    public private(set) var originalUrl: URL?

    ///将要打开的链接
    public var url: URL? {
        didSet{
            if let url = url{
                //补全url
                if var components = URLComponents(url: url, resolvingAgainstBaseURL: false) {
                    if String.isEmpty(components.scheme) {
                        components.scheme = "http://"
                    }
                    
                    let host = components.host
                    if !String.isEmpty(host) && host!.components(separatedBy: ".").count < 3 {
                        components.host = "www." + host!
                    }
                    self.url = components.url
                }
                
                if originalUrl == nil {
                    originalUrl = self.url
                }
            }
        }
    }

    ///将要打开的html
    public var htmlString: String?
    private var displayHtmlString: String? {
        if adjustScreenWhenLoadHtmlString && htmlString != nil {
            return String.gkAdjustScreenHtmlString + htmlString!
        }
        return htmlString
    }
    
    open override func viewDidLoad() {
        super.viewDidLoad()
        willInitWebView()
        initWebView()
        loadWebContent()
    }

    ///将要创建webView
    open func willInitWebView() {
        
    }
    
    ///初始化webView
    private func initWebView() {
        
        let contentView = UIView()
        contentView.addSubview(progressView)
        progressView.snp.makeConstraints { (make) in
            make.leading.trailing.equalTo(0)
            make.height.equalTo(2.5)
            make.top.equalTo(gkSafeAreaLayoutGuideTop)
        }
        
        contentView.addSubview(webView)
        webView.snp.makeConstraints { (make) in
            make.edges.equalTo(0)
        }
        self.contentView = contentView
    }

    // MARK: - Web Control

    ///是否可以倒退
    public var canGoBack: Bool {
        webView.canGoBack
    }

    ///是否可以前进
    public var canGoForward: Bool {
        webView.canGoForward
    }

    ///后退
    public func goBack() {
        webView.goBack()
    }

    ///前进
    public func goForward() {
        webView.goForward()
    }

    ///刷新
    public func reload() {
        var url = currentUrl
        if url == nil {
            url = self.url
            if url != nil {
                webView.load(URLRequest(url: url!))
            } else if htmlString != nil {
                webView.loadHTMLString(displayHtmlString!, baseURL: nil)
            }
        } else {
            webView.reload()
        }
    }

    ///加载网页
    public func loadWebContent() {
        var enable = true
        
        //判断需不需要设置 自定义ua，没有获取的系统的ua 先获取
        if systemUserAgent == nil {
            if customUserAgent != nil {
                if url != nil || htmlString != nil {
                    onProgressChange(0.1)
                }
                enable = false
                loadUserAgent { [weak self] in
                    self?.loadWebContent()
                }
            }
        } else {
            if let userAgent = customUserAgent, String.isEmpty(webView.customUserAgent) {
                webView.customUserAgent = systemUserAgent! + userAgent
            }
        }
     
        if enable {
            if url != nil {
                
                webView.load(URLRequest(url: url!))
            }else if htmlString != nil {
                webView.loadHTMLString(displayHtmlString!, baseURL: nil)
            }
        }
    }
    
    ///获取userAgent
    private func loadUserAgent(completion: VoidCallback?){
        if userAgentWebView == nil {
            userAgentWebView = WKWebView()
            userAgentWebView?.evaluateJavaScript("navigator.userAgent") { [weak self] (result, error) in
                let userAgent = result as? String ?? ""
                systemUserAgent = userAgent
                self?.userAgentWebView = nil
                completion?()
            }
        }
    }

    // MARK: - 回调

    ///是否应该打开某个链接
    open func shouldOpen(url: URL?, action: WKNavigationAction) -> Bool {
        
        return true
    }
    
    ///进度条改变
    open func onProgressChange(_ progress: CGFloat) {
        progressView.progress = shouldDisplayProgress ? progress : 0
    }
}

extension BaseWebViewController: WKUIDelegate {
    
    public func webView(_ webView: WKWebView, shouldPreviewElement elementInfo: WKPreviewElementInfo) -> Bool {
        //是否可以打开预览
        return false
    }
}

extension BaseWebViewController: WKNavigationDelegate {
    
    public func webView(_ webView: WKWebView, decidePolicyFor navigationAction: WKNavigationAction, decisionHandler: @escaping (WKNavigationActionPolicy) -> Void) {
        if shouldOpen(url: navigationAction.request.url, action: navigationAction) {
            decisionHandler(.allow)
        } else {
            decisionHandler(.cancel)
        }
    }
    
    public func webViewWebContentProcessDidTerminate(_ webView: WKWebView) {
        //WkWebView的进程不知啥原因 停止了，刷新当前页面，防止白屏
        webView.reload()
    }
}

extension BaseWebViewController: UIScrollViewDelegate {
    
    public func scrollViewWillBeginDragging(_ scrollView: UIScrollView) {
        //防止左右滑动时触发上下滑动
        if let page = parent as? PageViewController {
            page.scrollView?.isScrollEnabled = false
        }
    }
    
    public func scrollViewWillEndDragging(_ scrollView: UIScrollView, withVelocity velocity: CGPoint, targetContentOffset: UnsafeMutablePointer<CGPoint>) {
        if let page = parent as? PageViewController {
            page.scrollView?.isScrollEnabled = true
        }
    }
}
