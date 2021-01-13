//
//  UIView+Loading.swift
//  GliKitSwift
//
//  Created by 罗海雄 on 2020/1/20.
//  Copyright © 2020 luohaixiong. All rights reserved.
//

import UIKit

private var pageLoadingViewKey: UInt8 = 0
private var pageLoadingViewInsetsKey: UInt8 = 0
private var reloadCallbackKey: UInt8 = 0
private var toastKey: UInt8 = 0

///loading相关扩展
public extension UIView {
    
    ///页面第一次加载显示
    var gkShowPageLoading: Bool{
        set{
            let loading = self.gkShowPageLoading
            if newValue != loading {
                
                if(newValue){
                    var view = self.gkPageLoadingView
                    if view == nil {
                        view = initPageLoadingView()
                    }
                    
                    view!.backgroundColor = backgroundColor
                    view!.status = .loading
                    view!.isHidden = false
                    self.bringSubviewToFront(view!)
                }else{
                    self.gkPageLoadingView = nil
                }
            }else if(loading){
                //如果原来已经显示 可能动画是停止的
                self.gkPageLoadingView?.status = .loading
            }
        }
        get{
            let view = self.gkPageLoadingView
            return view != nil && view!.status == .loading
        }
    }
    
    ///创建pageloading
    private func initPageLoadingView() -> PageLoadingContainer{
        
        let view = PageLoadingView()
        view.refreshCallback = { [weak self] in
            self?.gkHandleTapFailPage()
        }
        
        self.gkPageLoadingView = view;
        return view;
    }
    
    ///点击失败视图
    func gkHandleTapFailPage(){
        
        self.gkReloadCallback?()
    }

    ///页面第一次加载视图
    var gkPageLoadingView: PageLoadingContainer?{
        set{
            self.gkPageLoadingView?.removeFromSuperview()
            objc_setAssociatedObject(self, &pageLoadingViewKey, newValue, .OBJC_ASSOCIATION_RETAIN_NONATOMIC)
            
            if let pageLoadView = newValue {
                
                addSubview(pageLoadView)
                layoutPageLoadingView()
            }
        }
        get{
            objc_getAssociatedObject(self, &pageLoadingViewKey) as? PageLoadingContainer
        }
    }
    
    @objc func layoutPageLoadingView() {
        gkPageLoadingView?.snp.makeConstraints { (maker) in
            maker.edges.equalTo(self).inset(self.gkPageLoadingViewInsets)
            
            if self is UIScrollView {
                maker.size.equalTo(self)
            }
        }
    }
    
    ///页面加载偏移量 default is UIEdgeInsetZero
    var gkPageLoadingViewInsets: UIEdgeInsets{
        set{
            objc_setAssociatedObject(self, &pageLoadingViewInsetsKey, newValue, .OBJC_ASSOCIATION_RETAIN_NONATOMIC)
        }
        get{
            objc_getAssociatedObject(self, &pageLoadingViewInsetsKey) as? UIEdgeInsets ?? UIEdgeInsets.zero
        }
    }

    ///显示加载失败页面
    var gkShowFailPage: Bool{
        set{
            if newValue != self.gkShowFailPage {
                if newValue{
                    var view = self.gkPageLoadingView
                    if view == nil {
                        view = initPageLoadingView()
                    }
                    
                    view!.status = .error
                    view!.isHidden = false
                    self.bringSubviewToFront(view!)
                }else{
                    self.gkPageLoadingView = nil;
                }
            }
        }
        get{
            let view = self.gkPageLoadingView
            return view != nil && view!.status == .error
        }
    }

    ///点击失败页面回调
    var gkReloadCallback: (() -> Void)?{
        set{
            objc_setAssociatedObject(self, &reloadCallbackKey, newValue, .OBJC_ASSOCIATION_COPY_NONATOMIC)
        }
        get{
            objc_getAssociatedObject(self, &reloadCallbackKey) as? () -> Void
        }
    }

    ///当前toast
    var  gkToast: ToastProtocol?{
        set{
            self.gkToast?.removeFromSuperview()
            objc_setAssociatedObject(self, &toastKey, newValue, .OBJC_ASSOCIATION_RETAIN_NONATOMIC)
        }
        get{
            objc_getAssociatedObject(self, &toastKey) as? ToastProtocol
        }
    }
    
    func gkShowSuccessText(_ text: String, duration: TimeInterval = 2) {
        gkShowToast(text: text, status: .success, delay: duration)
    }
    
    func gkShowErrorText(_ text: String, duration: TimeInterval = 2) {
        gkShowToast(text: text, status: .error, delay: duration)
    }
    
    func gkShowWarningText(_ text: String, duration: TimeInterval = 2) {
        gkShowToast(text: text, status: .warning, delay: duration)
    }
    
    func gkShowLoadingToast(text: String? = nil, delay: TimeInterval = 0) {
        gkShowToast(text: text, status: .loading, delay: delay)
    }

    ///显示toast
    private func gkShowToast(text: String?, status: ToastStatus, delay: TimeInterval, in view: UIView? = nil){
        
        let keyboardWindow = UIApplication.shared.windows.last
        var targetView = view ?? self
        
        //键盘正在显示，要在键盘所在的window显示，否则可能会被键盘挡住
        if KeyboardHelper.share.keyboardShowing {
            targetView = keyboardWindow!
        }
        
        //隐藏window上的弹窗 防止出现2个
        if targetView != UIApplication.shared.delegate?.window {
            
            UIApplication.shared.delegate?.window??.gkDismissText()
        }else if targetView != keyboardWindow {
            
            keyboardWindow?.gkDismissText()
        }
        
        var toast = targetView.gkToast
        if toast == nil {
            toast = Toast()
            targetView.gkToast = toast
            
            toast!.dismissCallback = { [weak targetView] in
                targetView?.gkToast = nil
            }
            
            targetView.addSubview(toast!)
            
            toast!.snp.makeConstraints { (maker) in
                maker.edges.equalTo(0)
                
                //scrollView 需要确定滑动范围
                if targetView is UIScrollView {
                    maker.size.equalTo(targetView)
                }
            }
        }
        
        toast!.delay = delay
        toast!.text = text
        toast!.status = status
        toast!.show()
    }

    ///隐藏加载中
    func gkDismissLoadingToast(in view: UIView? = nil){
        if view != nil {
            view?.gkToast?.gkDismissLoadingToast()
        }else{
            self.gkToast?.gkDismissLoadingToast()
        }
    }

    ///隐藏提示信息
    func gkDismissText(in view: UIView? = nil){
        if view != nil {
            view?.gkToast?.gkDismissText()
        }else{
            self.gkToast?.gkDismissText()
        }
    }
}
