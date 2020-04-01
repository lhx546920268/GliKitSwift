//
//  GKBaseViewModel.swift
//  GliKitSwift
//
//  Created by 罗海雄 on 2020/3/20.
//  Copyright © 2020 luohaixiong. All rights reserved.
//

import UIKit

///基础视图逻辑处理
open class BaseViewModel: UIScrollView {
    
    ///绑定的viewController
    open weak var viewController: UIScrollViewDelegate?
    
    ///加载数据是否需要显示 pageLoading default is 'YES'
    public var shouldShowPageLoading = true

    /**
     构造方法

     @param viewController 绑定的视图控制器
     @return 一个 GKBaseViewModel或其子类 实例
     */
    init(viewController: BaseViewController?) {
        self.viewController = viewController
    }
   
    ///关联的viewController会调用这里
    open func viewWillAppear(_ animated: Bool) {
        
    }
    open func viewDidAppear(_ animated: Bool) {
        
    }
    open func viewWillDisappear(_ animated: Bool) {
        
    }
    open func viewDidDisappear(_ animated: Bool) {
        
    }

    /**
     添加需要取消的请求 在dealloc
     
     @param task 请求
     */
    open func addCanceledTask(_ task: HttpTask){
        viewController?.addCanceledTask(task)
    }

    /**
     添加需要取消的请求 在dealloc
     
     @param task 请求
     @param cancel 是否取消相同的任务 通过 task.name 来判断
     */
    open func addCanceledTask(_ task: HttpTask, cancelTheSame cancel: Bool){
        viewController?.addCanceledTask(task, cancelTheSame: cancel)
    }
   
    /**
     添加需要取消的请求队列 在 dealloc
     
     @param tasks 请求
     */
    open func addCanceledTasks(_ tasks: HttpMultiTasks){
        viewController?.addCanceledTasks(tasks)
    }

    /**
     重新加载页面数据
     */
    open func reloadData(){
        if shouldShowPageLoading {
            viewController?.gkShowPageLoading = true
        }
    }

    /**
     数据加载完成回调
     */
    open func onLoadData(){
        if shouldShowPageLoading {
            viewController?.gkShowPageLoading = false
        }
        viewController?.onLoadData()
    }
}
