//
//  HttpMultiTasks.swift
//  GliKitSwift
//
//  Created by 罗海雄 on 2020/1/19.
//  Copyright © 2020 luohaixiong. All rights reserved.
//

import UIKit

///多任务处理
open class HttpMultiTasks: NSObject {
    
    ///保存请求队列的单例
    private static let sharedMultiTasks = Set<HttpMultiTasks>()

    ///当有一个任务失败时，是否取消所有任务
    public var shouldCancelAllTaskWhileOneFail = true

    ///是否只标记网络错误
    public var onlyFlagNetworkError = false

    //所有任务完成回调 hasFail 是否有任务失败了
    public var completion: ((HttpMultiTasks, Bool) -> Void)?
    
    ///任务列表
    private let tasks = Array<HttpTask>()

    ///是否有请求失败
    private var hasFail = false

    ///是否并发执行
    private var concurrent = true

    ///对应任务
    private var taskDictionary = NSMutableDictionary<String, HttpTask>()

    ///添加任务 key 为HttpTask.name
    public func addTask(_ task: HttpTask) {
        addTask(task, forKey: task.name)
    }
    
    /// 添加任务
    /// - Parameters:
    ///   - task: 对应任务 会自动调用 GKHttpTask 的start方法
    ///   - key: 唯一标识符
    public func addTask(_ task: HttpTask, forKey key: String) {
        
    }

    ///开始所有任务
    public func start() {
        
    }

    ///串行执行所有任务，按照添加顺序来执行
    public func startSerially() {
        
    }

    ///取消所有请求
    public func cancelAllTasks() {
        
    }

    ///获取某个请求
    public func taskForKey(_ key: String) -> HttpTask? {
        return taskDictionary[key]
    }
}
