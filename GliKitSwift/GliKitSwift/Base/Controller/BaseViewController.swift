//
//  BaseViewController.swift
//  GliKitSwift
//
//  Created by 罗海雄 on 2020/1/16.
//  Copyright © 2020 luohaixiong. All rights reserved.
//

import UIKit

///控制视图的基类
open class BaseViewController: UIViewController, UIGestureRecognizerDelegate {
    
    ///关联的viewModel 如果有关联 调用viewModel对应方法
    private var _viewModel: BaseViewModel?
    open var viewModel: BaseViewModel?{
        _viewModel
    }
    
    func setViewModel(_ viewModel: BaseViewModel){
        _viewModel = viewModel
    }

    ///是否已计算出frame，使用约束时用到
    public private(set) var isViewDidLayoutSubviews = false

    ///界面是否显示
    public private(set) var isDisplaying = false

    ///是否是第一次显示
    public private(set) var isFisrtDisplay = false
    
    ///界面显示次数
    private var displayTimes = 0

    ///第一次显示回调
    open func viewDidFirstAppear(_ animated: Bool){

    }
    
    // MARK: - 状态栏
    
    ///状态栏颜色
    public var statusBarStyle = UIStatusBarStyle.default{
        didSet{
            self.setNeedsStatusBarAppearanceUpdate()
        }
    }
    
    open override var preferredStatusBarStyle: UIStatusBarStyle{
        self.statusBarStyle
    }
    
    // MARK: - Task
    
    ///用来在delloc之前 要取消的请求
    private lazy var currentTasks: Set<WeakObjectContainer> = {
      
        return Set()
    }()
    
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
        if let bar = self.navigationController?.navigationBar as? SystemNavigationBar {
            return bar
        }
        
        return nil
    }

    ///是否要创建自定义导航栏
    open var shouldCreateNavigationBar = true

    ///自定义导航栏类
    open var navigationBarClass: AnyClass{
        NavigationBar.self
    }

    ///设置导航栏隐藏
    open func setNavigatonBarHidden(_ hidden: Bool, animated: Bool = false){
        
        if animated {
            if !hidden {
                self.navigatonBar?.isHidden = hidden
                if let systemBar = self.systemNavigationBar {
                    
                    systemBar.enable = !hidden
                    self.navigationItemHelper.hiddenItem = hidden
                }
            }
            
            if self.navigatonBar != nil {
                let height = self.gkStatusBarHeight + self.gkNavigationBarHeight
                let animation = CABasicAnimation(keyPath: "position.y")
                if hidden {
                    animation.fromValue = height / 2.0
                    animation.toValue = -height / 2.0
                } else {
                    animation.fromValue = -height / 2.0
                    animation.toValue = height / 2.0
                }
                animation.duration = TimeInterval(UINavigationController.hideShowBarDuration)
                animation.isRemovedOnCompletion = false
                animation.fillMode = .forwards
                self.navigatonBar!.layer.add(animation, forKey: "position")
            } else {
                
                self.navigatonBar?.isHidden = hidden
                self.navigatonBar?.layer.removeAnimation(forKey: "position")
                if let systemBar = self.systemNavigationBar {
                    
                    systemBar.enable = !hidden
                    self.navigationItemHelper.hiddenItem = hidden
                } else {
                    
                    self.navigationController?.setNavigationBarHidden(hidden, animated: animated)
                }
            }
        }
    }
    
    // MARK: - Init
    
    public override init(nibName nibNameOrNil: String?, bundle nibBundleOrNil: Bundle?) {
        super.init(nibName: nibNameOrNil, bundle: nibBundleOrNil)
        
        initParams()
    }
    
    required public init?(coder: NSCoder) {
        super.init(coder: coder)
        
        initParams()
    }
    
    ///初始化
    func initParams() {
        
        self.hidesBottomBarWhenPushed = true
        self.modalPresentationStyle = .fullScreen
        
        if #available(iOS 13, *) {
            self.overrideUserInterfaceStyle = .light
        }
    }
    
    // MARK: - View Life Cycle

    open override func loadView() {
        
        //如果有 xib 则加载对应的xib
        if Bundle.main.path(forResource: self.gkNameOfClass, ofType: "nib") != nil {
            
            self.view = Bundle.main.loadNibNamed(self.gkNameOfClass, owner: self, options: nil)?.last as? UIView
        } else {
            
            self.container = BaseContainer(viewController: self)
            if self.isShowAsDialog {
                self.view = self.container
            } else {
                self.view = UIView()
            }
        }
    }
    
    open override func viewWillAppear(_ animated: Bool) {
        
        super.viewWillAppear(animated)
        self.viewModel?.viewWillAppear(animated)
        self.systemNavigationBar?.enable = true
    }
    
    open override func viewDidAppear(_ animated: Bool) {
        
        super.viewDidAppear(animated)
        self.viewModel?.viewDidAppear(animated)
        self.isDisplaying = true
        self.displayTimes += 1
        
        if self.isFisrtDisplay {
            self.viewDidFirstAppear(animated)
        }
    }
    
    open override func viewWillDisappear(_ animated: Bool) {
        
        super.viewWillDisappear(animated)
        self.viewModel?.viewWillDisappear(animated)
    }
    
    open override func viewDidDisappear(_ animated: Bool) {
        
        super.viewDidDisappear(animated)
        self.viewModel?.viewDidDisappear(animated)
    }
    
    open override func viewDidLoad() {
        super.viewDidLoad()
        
        //防止侧滑返回 取消时 导航栏出现3个小点
        let backBarButtonItem = UIBarButtonItem()
        backBarButtonItem.title = ""
        self.navigationItem.backBarButtonItem = backBarButtonItem
        
        if #available(iOS 11.0, *) {
            
        } else {
            self.automaticallyAdjustsScrollViewInsets = false
        }
        self.navigationItem.hidesBackButton = true
        
        //显示自定义导航栏
        if self.shouldCreateNavigationBar && (self.parent?.isKind(of: UINavigationController.self) ?? false) {
            
            let cls = self.navigationBarClass as? NavigationBar.Type
            assert(cls != nil, "\(NSStringFromClass(self.classForCoder)) 的navigationBarClass 必须是 \(NSStringFromClass(NavigationBar.self)) 或其子类")
            
            self.navigatonBar = cls!.init()
            self.view.addSubview(self.navigatonBar!)
            
            self.navigatonBar?.snp.makeConstraints({ (maker) in
                maker.leading.trailing.top.equalTo(0)
                maker.bottom.equalTo(self.gkSafeAreaLayoutGuideTop)
            })
        }
        
        if self.isShowAsDialog {
            if self.container != nil {
                self.container?.safeLayoutGuide = .none
                
                //当 self.view 不是 container时， container中的子视图布局完成不会调用 viewDidLayoutSubviews 要手动，否则在 viewDidLayoutSubviews中获取 self.contentView的大小时会失败
                self.container?.layoutSubviewsCompletion = { [weak self] in
                    self?.viewDidLayoutSubviews(shouldCallSuper: false)
                }
                self.view.addSubview(self.container!)
            }
        } else {
            self.view.backgroundColor = .white
            if let nav = self.navigationController {
                if !self.gkShowBackItem && (nav.viewControllers.count > 1 || nav.presentingViewController != nil) {
                    self.gkShowBackItem = true
                }
            }
        }
    }
    
    open override func viewDidLayoutSubviews() {
        
        self.viewDidLayoutSubviews(shouldCallSuper: true)
    }
    
    private func viewDidLayoutSubviews(shouldCallSuper: Bool){
        
        if shouldCallSuper {
            super.viewDidLayoutSubviews()
        }
        
        self.isViewDidLayoutSubviews = true
        if self.navigatonBar != nil {
            self.view.bringSubviewToFront(self.navigatonBar!)
        }
    }
    
    deinit {
        
        cancelAllTasks()
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
        self.view.addGestureRecognizer(tap)
        
        return tap
    }()
    
    ///回收键盘
    @objc private func handleDismissKeyboard(){
        
        UIApplication.shared.keyWindow?.endEditing(true)
    }
    
    ///键盘高度改变
    public override func keyboardWillChangeFrame(_ notification: Notification) {
        
        super.keyboardWillChangeFrame(notification)
        
        //弹出键盘，改变弹窗位置
        if self.isShowAsDialog {
            // TODO: 调整弹窗
        }
    }
    
    // MARK: - UIGestureRecognizerDelegate
    
    public func gestureRecognizer(_ gestureRecognizer: UIGestureRecognizer, shouldReceive touch: UITouch) -> Bool {
        
        return self.view == touch.view
    }
    
    // TODO: 空视图
}

///内容视图
public extension BaseViewController{
    
    ///固定在顶部的视图 xib不要用
    var topView: UIView?{
        set{
            self.container?.topView = newValue
        }
        get{
            self.container?.topView
        }
    }
    
    ///固定在底部的视图 xib不要用
    var bottomView: UIView?{
        set{
            self.container?.bottomView = newValue
        }
        get{
            self.container?.bottomView
        }
    }
    
    ///内容视图 xib 不要用
    var contentView: UIView?{
        set{
            self.container?.contentView = newValue
        }
        get{
            self.container?.contentView
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
        self.addCanceledTask(task, cancelTheSame: false)
    }

    /**
     添加需要取消的请求 在dealloc
     
     @param task 请求
     @param cancel 是否取消相同的任务 通过 task.name 来判断
     */
    func addCanceledTask(_ task: HttpTask, cancelTheSame cancel: Bool){
        self.removeInvalidTasks(cancelTheSame: cancel, name: task.name)
        self.currentTasks.insert(WeakObjectContainer(weakObject: task))
    }

    /**
     添加需要取消的请求队列 在 dealloc
     
     @param tasks 请求
     */
    func addCanceledTasks(_ tasks: HttpMultiTasks){
        
        self.removeInvalidTasks(cancelTheSame: false, name: nil)
        self.currentTasks.insert(WeakObjectContainer(weakObject: tasks))
    }
    
    /**
    添加需要取消的请求 在dealloc
    
    @param cancelTheSame 取消相同的请求
    @param name 任务名称
    */
    private func removeInvalidTasks(cancelTheSame: Bool, name: String?){
        
        if self.currentTasks.count > 0 {
            
            var toRemoveTasks = Set<WeakObjectContainer>()
            for obj in self.currentTasks {
                
                if obj.weakObject == nil {
                    toRemoveTasks.insert(obj)
                } else if let task = obj.weakObject as? HttpTask {
                    if task.name == name {
                        task.cancel()
                        toRemoveTasks.insert(obj)
                    }
                }
            }
            
            self.currentTasks.remove(toRemoveTasks)
        }
    }
    
    ///取消正在执行的请求
    fileprivate func cancelAllTasks(){
        
        for obj in self.currentTasks {
            if let task = obj.weakObject as? HttpTask {
                task.cancel()
            } else if let tasks = obj.weakObject as? HttpMultiTasks {
                tasks.cancelAllTasks()
            }
        }
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
