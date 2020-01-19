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
public protocol HttpTaskDelegate: NSObjectProtocol {
    
    ///请求失败
    func taskDidFail(_ task: HttpTask)
    
    ///请求成功
    func taskDidSuccess(_ task: HttpTask)
    
    ///请求完成
    func taskDidComplete(_ task: HttpTask)
}


/**
 单个http请求任务 子类可重写对应的方法
 不需要添加一个属性来保持 strong ，任务开始后会添加到一个全局 队列中
 */
open class HttpTask: NSObject {
    
    ///保存请求队列的单例
    private static let sharedTasks = Set<HttpTask>()
    
    ///当前请求
    private var request: Request?
    
    // MARK: - http参数
    
    ///请求超时
    public var timeoutInterval: Double = 15
    
    ///默认get
    public var httpMethod = HTTPMethod.get
    
    ///请求链接
    public var requestURL: String?
    
    ///请求头
    public var headers: HTTPHeaders?
    
    ///请求参数
    public var params: Parameters?
    
    ///文件
    public var files: Dictionary<String, String>?
    
    
    // MARK: - 状态
    
    ///是否正在执行
    func isExecuting() -> Bool {
        return false
    }
    
    ///是否暂停
    func isSuspended() -> Bool {
        return false
    }
    
    ///是否是自己取消
    public private(set) var isCanceled = false
    
    // MARK: - 回调
    
    ///成功回调
    public var successCallback: ((HttpTask) -> Void)?
    
    ///将要调用失败回调
    public var willFailCallback: ((HttpTask) -> Void)?
    
    ///失败回调
    public var failCallback: ((HttpTask) -> Void)?
    
    ///代理
    public weak var delegate: HttpTaskDelegate?
    
    // MARK: - 结果
    
    ///是否是网络错误
    public var isNetworkError = false
    
    ///接口是否请求成功
    public var isApiSuccess = false
    
    ///原始最外层字典
    public var data: JSONResult?
    
    ///提示的信息
    public var message: String?
    
    // MARK: - 其他
    
    ///请求标识 默认返回类的名称
    public lazy var name: String = {
        return NSStringFromClass(self.classForCoder)
    }()
    
    ///额外信息，用来传值的
    public var userInfo: Dictionary<String, Any>?
    
    // MARK: - Loading
    
    ///关联的view，用来显示 错误信息，loading
    public weak var view: UIView?
    
    ///loading显示延迟
    public var loadingHUDDelay: Double = 0.5
    
    ///是否要显示loading
    public var shouldShowloadingHUD = false
    
    ///是否提示错误信息，default is no
    public var shouldAlertErrorMsg = false
    
    // MARK: - 子类重写 回调
    
    /// 请求开始了
    open func onStart(){
        HttpTask.sharedTasks.insert(self)
        if shouldShowloadingHUD {
            // TODO: 要加loading
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
        
        // TODO: 要加loading
        delegate?.taskDidComplete(self)
        HttpTask.sharedTasks.remove(self)
    }
    
    // MARK: - 外部调用方法
    
    /// 开始请求
    open func start(){
        if isExecuting() {
            return
        }
        
        guard requestURL != nil else {
            
            GKLog("\(name) requestURL can not be nil")
            onFail()
            return
        }
        
        onStart()
        if let uploadFiles = files, uploadFiles.count > 0 {
            
            Alamofire.upload(multipartFormData: { formdata in
                
                for (key, filePath) in uploadFiles {
                    formdata.append(URL(fileURLWithPath: filePath), withName: key)
                }
          
            }, to: requestURL!, headers: headers, encodingCompletion: { [weak self] result in
                switch result {
                case .success(let request, _, _) :
                    self?.request = request
                case .failure(let error) :
                    self?.processError(error)
                }
            })
            
        } else {
            request = Alamofire.request(requestURL!, method: httpMethod, parameters: params, headers: headers).responseJSON { [weak self] response in
                
                if self != nil {
                    if response.result.isSuccess {
                        let value = response.result.value
                        if value is JSONResult {
                            let result = value as! JSONResult
                            self?.processSuccessResult(result)
                        } else {
                            self?.processError(HttpError.resultFormatError)
                        }
                    } else {
                        self?.processError(response.error)
                    }
                }
            }
        }
    }
    
    /// 取消
    open func cancel(){
        if(isSuspended() || isExecuting()){
            isCanceled = true
            request?.cancel()
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
        if isCanceled {
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
        
        successCallback?(self)
        onComplete()
    }
    
    ///请求失败
    public func requestDidFail() {
        willFailCallback?(self)
        onFail()
        failCallback?(self)
        delegate?.taskDidFail(self)
        onComplete()
    }
}


