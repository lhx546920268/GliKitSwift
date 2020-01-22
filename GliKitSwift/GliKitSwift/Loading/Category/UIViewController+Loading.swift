//
//  UIViewController+Loading.swift
//  GliKitSwift
//
//  Created by 罗海雄 on 2020/1/21.
//  Copyright © 2020 luohaixiong. All rights reserved.
//

import UIKit

///loading相关扩展
public extension UIViewController {
    
    ///获取当前内容视图
    private var gkContentView: UIView{
        get{
            // TODU: self.isShowAsDialog ? self.dialog : self.view;
            self.view
        }
    }
    
    ///页面第一次加载显示
    var gkShowPageLoading: Bool{
        set{
            self.gkContentView.gkShowPageLoading = newValue
        }
        get{
            self.gkContentView.gkShowPageLoading
        }
    }
    
    ///刷新数据
    func gkReloadData(){
        
    }

    ///页面第一次加载视图
    var gkPageLoadingView: PageLoadingContainer?{
        set{
            self.gkContentView.gkPageLoadingView = newValue
        }
        get{
            self.gkContentView.gkPageLoadingView
        }
    }
    
    ///页面加载偏移量 default is UIEdgeInsetZero
    var gkPageLoadingViewInsets: UIEdgeInsets{
        set{
            self.gkContentView.gkPageLoadingViewInsets = newValue
        }
        get{
            self.gkContentView.gkPageLoadingViewInsets
        }
    }

    ///显示加载失败页面
    var gkShowFailPage: Bool{
        set{
            self.gkContentView.gkShowFailPage = newValue
            if newValue {
                self.gkContentView.gkReloadCallback = { [weak self] in
                    self?.gkReloadData()
                }
            }
        }
        get{
            let view = self.gkPageLoadingView
            return view != nil && view!.status == .error
        }
    }

    ///显示hud
    func gkShowProgressHUD(text: String, status: ProgressHUDStatus = .success, delay: Double = 0, in view: UIView? = nil){
        
        self.gkContentView.gkShowProgressHUD(text: text, status: status, delay: delay, in: view)
    }

    ///隐藏加载中hud
    func gkDismissProgress(in view: UIView? = nil){
        self.gkContentView.gkDismissProgress(in: view)
    }

    ///隐藏提示信息hud
    func gkDismissText(in view: UIView? = nil){
        self.gkContentView.gkDismissText(in: view)
    }
}
