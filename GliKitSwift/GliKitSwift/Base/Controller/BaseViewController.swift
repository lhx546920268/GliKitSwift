//
//  BaseViewController.swift
//  GliKitSwift
//
//  Created by 罗海雄 on 2020/1/16.
//  Copyright © 2020 luohaixiong. All rights reserved.
//

import UIKit

///控制视图的基类
open class BaseViewController: UIViewController {
    
    open override func viewWillAppear(_ animated: Bool) {
        
    }
    open override func viewDidAppear(_ animated: Bool) {
        
    }
    open override func viewWillDisappear(_ animated: Bool) {
        
    }
    open override func viewDidDisappear(_ animated: Bool) {
        
    }
    
    
    ///关联的viewModel 如果有关联 调用viewModel对应方法
    open var viewModel: BaseViewModel?

    ///是否已计算出frame，使用约束时用到
    public private(set) var isViewDidLayoutSubviews = false

    ///状态栏颜色
    public var statusBarStyle = UIStatusBarStyle.default

    ///界面是否显示
    public private(set) var isDisplaying = false

    ///是否是第一次显示
    public private(set) var isFisrtDisplay = false
    
    ///界面显示次数
    private var displayTimes = 0

    ///第一次显示回调
    open func viewDidFirstAppear(_ animated: Bool){
        
    }
    
    ///用来在delloc之前 要取消的请求
    @property(nonatomic, strong) NSMutableSet<GKWeakObjectContainer*> *currentTasks;

    ///点击回收键盘手势
    @property(nonatomic, strong) UITapGestureRecognizer *;

    
    
    // MARK: - 内容视图

    ///视图容器 self.view xib 不要用，如果 showAsDialog = YES，self.view将不再是 container 且 要自己设置container的约束
    public private(set) var container: BaseContainer?

    // MARK: - 导航栏

    ///导航栏
    public private(set) var navigatonBar: NavigationBar?

    ///item帮助类
    public private(set) lazy var navigationItemHelper: NavigationItemHelper = {
        
        return NavigationItemHelper(viewController: self)
    }()

    ///系统导航栏
    public var systemNavigationBar: SystemNavigationBar?{
        get{
            if let bar = self.navigationController?.navigationBar as? SystemNavigationBar {
                return bar
            }
            
            return nil;
        }
    }

    ///是否要创建自定义导航栏
    open var shouldCreateNavigationBar = true

    ///自定义导航栏类
    open var navigationBarClass: AnyClass{
        get{
            return NavigationBar.self
        }
    }

    ///设置导航栏隐藏
    open func setNavigatonBarHidden(_ hidden: Bool, animated: Bool = false){
        
    }

    open override func viewDidLoad() {
        super.viewDidLoad()
    }

    // MARK: - 键盘
    
    ///设置点击self.view 回收键盘
    public var shouldDismissKeyboardWhileTap = false{
        didSet{
            let value = self.shouldDismissKeyboardWhileTap
            if oldValue != value {
                self.dismissKeyboardGestureRecognizer.isEnabled = value
            }
        }
    }
    
    ///回收键盘手势
    public private(set) lazy var dismissKeyboardGestureRecognizer: UITapGestureRecognizer = {
        
        let tap = UITapGestureRecognizer(target: self, action: #selector(self.handleDismissKeyboard))
        tap.delegate = self
        self.view .addGestureRecognizer(tap)
    }()
    
    ///回收键盘
    @objc private func handleDismissKeyboard(){
        UIApplication.shared.keyWindow?.endEditing(true)
    }
}

///内容视图
public extension BaseViewController{
    
    ///固定在顶部的视图 xib不要用
    var topView: UIView?{
        set{
            self.container?.topView = newValue
        }
        get{
            return self.container?.topView
        }
    }
    
    ///固定在底部的视图 xib不要用
    var bottomView: UIView?{
        set{
            self.container?.bottomView = newValue
        }
        get{
            return self.container?.bottomView
        }
    }
    
    ///内容视图 xib 不要用
    var contentView: UIView?{
        set{
            self.container?.contentView = newValue
        }
        get{
            return self.container?.contentView
        }
    }

    /**
     设置顶部视图
     
     @param topView 顶部视图
     @param height 视图高度，GKWrapContent 为自适应
     */
    func setTopView(_ topView: UIView?, height: CGFloat){
        
        self.container?.setTopView(topView, height: height)
    }

    /**
     设置底部视图
     
     @param bottomView 底部视图
     @param height 视图高度，GKWrapContent 为自适应
     */
    func setBottomView(_ bottomView: UIView?, height: CGFloat){
        
        self.container?.setBottomView(bottomView, height: height)
    }
}

///加载数据
public extension BaseViewController{
    
    /**
     加载页面数据 第一次加载 或者 网络错误重新加载
     */
    override func gkReloadData() {
        self.viewModel?.reloadData()
    }

    /**
     数据加载完成回调 子类重写
     */
    @objc func onLoadData(){
        
    }
}

///任务
public extension BaseViewController{

    /**
     添加需要取消的请求 在dealloc
     
     @param task 请求
     */
    func addCanceledTask(_ task: HttpTask){
        
    }

    /**
     添加需要取消的请求 在dealloc
     
     @param task 请求
     @param cancel 是否取消相同的任务 通过 task.name 来判断
     */
    func addCanceledTask(_ task: HttpTask, cancelTheSame cancel: Bool){
        
    }

    /**
     添加需要取消的请求队列 在 dealloc
     
     @param tasks 请求
     */
    func addCanceledTasks(_ tasks: HttpMultiTasks){
        
    }
}

///路由
public extension BaseViewController{
    
    /**
     设置路由参数，如果参数名和属性名一致，则不需要处理这个
     */
    @objc func setRouterParams(_ params: Dictionary<String, Any>?){
        
    }
}

extension BaseViewController: UIGestureRecognizerDelegate{
    
    public func gestureRecognizer(_ gestureRecognizer: UIGestureRecognizer, shouldReceive touch: UITouch) -> Bool {
        return self.view == touch.view
    }
}
