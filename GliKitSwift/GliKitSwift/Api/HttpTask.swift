//
//  HttpTask.swift
//  GliKitSwift
//
//  Created by 罗海雄 on 2020/1/19.
//  Copyright © 2020 luohaixiong. All rights reserved.
//

import UIKit
import Alamofire

///json 结果
public typealias JSONResult = Dictionary<String, Any>

///代理
public protocol HttpTaskDelegate: AnyObject {
    
    ///请求失败
    func taskDidFail(_ task: HttpTask)
    
    ///请求成功
    func taskDidSuccess(_ task: HttpTask)
    
    ///请求完成
    func taskDidComplete(_ task: HttpTask)
}

///翻页起始页
public let GKHttpFirstPage = 1

///回调
public typealias HttpTaskCallback = (HttpTask) -> Void

/**
 单个http请求任务 子类可重写对应的方法
 不需要添加一个属性来保持 strong ，任务开始后会添加到一个全局 队列中
 */
open class HttpTask {
    
    ///锁
    private let lock: Lock = Lock()
    
    ///保存请求队列的单例
    private static var sharedTasks = Set<HttpTask>()
    
    ///唯一标识符
    public let id: UUID = UUID()
    
    ///当前请求
    private var request: Request?
    
    // MARK: - http参数
    
    ///请求超时
    public var timeoutInterval: TimeInterval = 15
    
    ///默认get
    open var httpMethod: HTTPMethod{
        .get
    }
    
    ///请求链接
    open var requestURL: String{
        ""
    }
    
    ///请求头
    open var headers: HTTPHeaders?{
        nil
    }
    
    ///请求参数
    open var params: Parameters?{
        nil
    }
    
    ///文件
    open var files: Dictionary<String, String>?{
        nil
    }
    
    // MARK: - 状态
    
    ///是否正在执行
    public var isExecuting: Bool {
        return request?.isResumed ?? false
    }
    
    ///是否暂停
    public var isSuspended: Bool {
        return request?.isSuspended ?? false
    }
    
    ///是否是自己取消
    public private(set) var isCancelled: Bool = false
    
    ///是否已完成
    private var isCompleted: Bool = false
    
    // MARK: - 回调
    
    ///成功回调
    public var successCallback: HttpTaskCallback?
    
    ///将要调用失败回调
    public var willFailCallback: HttpTaskCallback?
    
    ///失败回调
    public var failCallback: HttpTaskCallback?
    
    ///代理
    public weak var delegate: HttpTaskDelegate?
    
    // MARK: - 结果
    
    ///是否是网络错误
    public var isNetworkError: Bool = false
    
    ///接口是否请求成功
    public var isApiSuccess: Bool = false
    
    ///原始最外层字典
    public var data: JSONResult?
    
    ///提示的信息
    public var message: String?
    
    // MARK: - 其他
    
    ///请求标识 默认返回类的名称
    public lazy var name: String = {
        return String(describing: self)
    }()
    
    ///额外信息，用来传值的
    public var userInfo: Dictionary<String, Any>?
    
    // MARK: - Loading
    
    ///关联的view，用来显示 错误信息，loading
    public weak var view: UIView?
    
    ///loading显示延迟
    public var loadingHUDDelay: Double = 0.5
    
    ///是否要显示loading
    public var shouldShowloadingHUD: Bool = false
    
    ///是否提示错误信息，default is no
    public var shouldAlertErrorMsg: Bool = false
    
    public init() {

    }
    
    // MARK: - 子类重写 回调
    
    /// 请求开始了
    open func onStart(){
        HttpTask.sharedTasks.insert(self)
        if shouldShowloadingHUD {
            UIApplication.shared.gkKeyWindow?.endEditing(true)
            view?.gkShowProgress(delay: loadingHUDDelay)
        }
    }
    
    /// 子类实现这个校验接口返回的数据
    /// - Parameter data: 原始字典数据
    /// - Returns: 接口是否请求成功
    open func onLoadData(_ data: JSONResult) -> Bool{
        return true
    }
    
    /// 请求成功 在这里解析数据
    open func onSuccess(){
        
    }
    
    /// 请求失败
    open func onFail(){
        
    }
    
    /// 请求完成 无论是 失败 成功 或者取消
    open func onComplete(){
        
        isCompleted = true
        if shouldShowloadingHUD {
            view?.gkDismissProgress()
        }
        delegate?.taskDidComplete(self)
        request = nil
        HttpTask.sharedTasks.remove(self)
    }
    
    // MARK: - 外部调用方法
    
    /// 开始请求
    @discardableResult
    open func start() -> Self{
        lock.lock()
        defer {
            lock.unlock()
        }
        if !isExecuting && !isCancelled && !isCompleted {
            onStart()
            createRequestIfNeeded()
            request?.resume()
        }
        
        return self
    }
    
    ///创建请求
    private func createRequestIfNeeded() {
        if request == nil {
            let completion: (Alamofire.AFDataResponse<Any>) -> Void = { [weak self] (response: AFDataResponse<Any>) in
                
                if let self = self {
                    
                    if case .success(let value) = response.result {
                        if value is JSONResult {
                            let result = value as! JSONResult
                            self.processSuccessResult(result)
                        } else {
                            self.processError(HttpError.resultFormatError)
                        }
                    } else {
                        self.processError(response.error)
                    }
                }
            }
            if let uploadFiles = files, uploadFiles.count > 0 {
                
                request = AF.upload(multipartFormData: { formData in
                    for (key, filePath) in uploadFiles {
                        formData.append(URL(fileURLWithPath: filePath), withName: key)
                    }
                }, to: requestURL, headers: headers).responseJSON(completionHandler: completion)
            } else {
                
                request = AF.request(requestURL, method: httpMethod, parameters: params, headers: headers).responseJSON(completionHandler: completion)
            }
        }
    }
    
    /// 取消
    open func cancel(){
        lock.lock()
        defer {
            lock.unlock()
        }
        if !isCancelled && !isCompleted{
            isCancelled = true
            
            if isExecuting || isSuspended {
                request?.cancel()
            }
            
            onComplete()
        }
    }
    
    // MARK: - 处理结果
    
    ///处理http请求请求成功的结果
    open func processSuccessResult(_ result: JSONResult){
        
        data = result
        isApiSuccess = onLoadData(result)
        if isApiSuccess {
            
            requestDidSuccess()
        } else {
            
            requestDidFail()
        }
    }
    
    ///处理请求失败错误
    open func processError(_ error: Error?){
        
        //是自己取消的  因为服务端取消的也会被标记成 NSURLErrorCancelled
        if isCancelled {
            return
        }
        
        if error is URLError {
            let urlError = error as! URLError
            switch urlError {
            case URLError.timedOut,
                 URLError.cannotFindHost,
                 URLError.cannotConnectToHost,
                 URLError.networkConnectionLost,
                 URLError.notConnectedToInternet :
                isNetworkError = true
            default:
                break
            }
        }
        
        requestDidFail()
    }
    
    // MARK: - 内部回调
    
    ///请求成功
    public func requestDidSuccess() {
        onSuccess()
        delegate?.taskDidSuccess(self)
        
        dispatchAsyncMainSafe {
            self.lock.lock()
            defer {
                self.lock.unlock()
            }
            if !self.isCancelled {
                self.successCallback?(self)
                self.onComplete()
            }
        }
    }
    
    ///请求失败
    public func requestDidFail() {
        dispatchAsyncMainSafe {
            self.lock.lock()
            defer {
                self.lock.unlock()
            }
            if !self.isCancelled {
                self.willFailCallback?(self)
                self.onFail()
                self.failCallback?(self)
                self.delegate?.taskDidFail(self)
                self.onComplete()
            }
        }
    }
}

extension HttpTask: Equatable {
    
    public static func == (lhs: HttpTask, rhs: HttpTask) -> Bool {
        return lhs.id == lhs.id
    }
}

extension HttpTask: Hashable {

    public func hash(into hasher: inout Hasher) {
        hasher.combine(id)
    }
}

///为了语法方便
public extension HttpTask {
    
    func success(_ callback: @escaping HttpTaskCallback) -> Self {
        successCallback = callback
        return self
    }
    
    func fail(_ callback: @escaping HttpTaskCallback) -> Self {
        failCallback = callback
        return self
    }
    
    func willFail(_ callback: @escaping HttpTaskCallback) -> Self {
        willFailCallback = callback
        return self
    }
    
    func attach(_ view: UIView, loading: Bool = true, error: Bool = true) -> Self {
        self.view = view
        shouldShowloadingHUD = loading
        shouldAlertErrorMsg = error
        
        return self
    }
    
    func cancel(by cancelable: HttpTaskCancelable, cancelTheSame cancel: Bool = false) -> Self {
        cancelable.addCancelableTask(self, cancelTheSame: cancel)
        return self
    }
}

///可取消的
public protocol HttpTaskCancelable {
    
    /**
     添加需要取消的请求 在 deInit
     
     @param task 请求
     @param cancel 是否取消相同的任务 通过 task.name 来判断
     */
    func addCancelableTask(_ task: HttpTask, cancelTheSame cancel: Bool)
   
    /**
     添加需要取消的请求队列 在 deInit
     
     @param tasks 请求
     */
    func addCancelableTasks(_ tasks: HttpMultiTasks)
}

