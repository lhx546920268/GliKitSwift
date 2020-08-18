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
private var progressHUDKey: UInt8 = 0

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
                pageLoadView.snp.makeConstraints { (maker) in
                    maker.edges.equalTo(self).inset(self.gkPageLoadingViewInsets)
                    
                    if self is UIScrollView {
                        maker.size.equalTo(self)
                    }
                }
            }
        }
        get{
            objc_getAssociatedObject(self, &pageLoadingViewKey) as? PageLoadingContainer
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

    ///当前hud
    var  gkProgressHUD: ProgressHUDProtocol?{
        set{
            self.gkProgressHUD?.removeFromSuperview()
            objc_setAssociatedObject(self, &progressHUDKey, newValue, .OBJC_ASSOCIATION_RETAIN_NONATOMIC)
        }
        get{
            objc_getAssociatedObject(self, &progressHUDKey) as? ProgressHUDProtocol
        }
    }

    ///显示hud
    func gkShowProgressHUD(text: String? = nil, status: ProgressHUDStatus = .success, delay: Double = 0, in view: UIView? = nil){
        
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
        
        var hud = targetView.gkProgressHUD
        if hud == nil {
            hud = ProgressHUD()
            targetView.gkProgressHUD = hud
            
            hud!.dismissCallback = { [weak targetView] in
                targetView?.gkProgressHUD = nil
            }
            
            targetView.addSubview(hud!)
            
            hud!.snp.makeConstraints { (maker) in
                maker.edges.equalTo(0)
                
                //scrollView 需要确定滑动范围
                if targetView is UIScrollView {
                    maker.size.equalTo(targetView)
                }
            }
        }
        
        hud!.delay = delay
        hud!.text = text
        hud!.status = status
        hud!.show()
    }

    ///隐藏加载中hud
    func gkDismissProgress(in view: UIView? = nil){
        if view != nil {
            view?.gkProgressHUD?.gkDismissProgress()
        }else{
            self.gkProgressHUD?.gkDismissProgress()
        }
    }

    ///隐藏提示信息hud
    func gkDismissText(in view: UIView? = nil){
        if view != nil {
            view?.gkProgressHUD?.gkDismissText()
        }else{
            self.gkProgressHUD?.gkDismissText()
        }
    }
}
