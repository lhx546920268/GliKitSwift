//
//  HttpMultiTasks.swift
//  GliKitSwift
//
//  Created by 罗海雄 on 2020/1/19.
//  Copyright © 2020 luohaixiong. All rights reserved.
//

import UIKit

///多任务处理
open class HttpMultiTasks {
    
    ///唯一标识符
    public let id: UUID = UUID()
    
    ///保存请求队列的单例
    private static var sharedMultiTasks = Set<HttpMultiTasks>()

    ///当有一个任务失败时，是否取消所有任务
    public var shouldCancelAllTaskWhileOneFail = true

    ///是否只标记网络错误
    public var onlyFlagNetworkError = false

    //所有任务完成回调 hasFail 是否有任务失败了
    public var completion: ((HttpMultiTasks, Bool) -> Void)?
    
    ///任务列表
    private var tasks = ContiguousArray<HttpTask>()

    ///是否有请求失败
    private var hasFail = false

    ///是否并发执行
    private var concurrent = true

    ///对应任务
    private var taskDictionary = Dictionary<String, HttpTask>()

    ///添加任务 key 为HttpTask.name
    public func addTask(_ task: HttpTask) {
        addTask(task, forKey: task.name)
    }
    
    /// 添加任务
    /// - Parameters:
    ///   - task: 对应任务 会自动调用 GKHttpTask 的start方法
    ///   - key: 唯一标识符
    public func addTask(_ task: HttpTask, forKey key: String) {
        
        tasks.append(task)
        taskDictionary[key] = task
        task.delegate = self
    }

    ///开始所有任务
    public func start() {
        
        dispatchAsyncMainSafe {
            self.concurrent = true
            self.startTask()
        }
    }

    ///串行执行所有任务，按照添加顺序来执行
    public func startSerially() {
        
        dispatchAsyncMainSafe {
            self.concurrent = false
            self.startTask()
        }
    }

    ///取消所有请求
    public func cancelAllTasks() {
        dispatchAsyncMainSafe {
            for task in self.tasks {
                task.cancel()
            }
            self.tasks.removeAll()
            self.taskDictionary.removeAll()
            HttpMultiTasks.sharedMultiTasks.remove(self)
        }
    }

    ///获取某个请求
    public func taskForKey(_ key: String) -> HttpTask? {
        return taskDictionary[key]
    }
    
    ///开始任务
    private func startTask() {
        HttpMultiTasks.sharedMultiTasks.insert(self)
        hasFail = false
        if self.concurrent {
            for task in tasks {
                task.start()
            }
        } else {
            startNextTask()
        }
    }

    ///开始执行下一个任务 串行时用到
    private func startNextTask(){
        tasks.first?.start()
    }

    ///任务完成
    private func taskDiComplete(_ task: HttpTask, success: Bool) {
        
        tasks.remove(task)
        if !success {
            hasFail = true
            if shouldCancelAllTaskWhileOneFail {
                for task in tasks {
                    task.cancel()
                }
                tasks.removeAll()
            }
        }
        
        if tasks.count == 0 {
            completion?(self, hasFail)
            taskDictionary.removeAll()
            HttpMultiTasks.sharedMultiTasks.remove(self)
        } else if !concurrent {
            startNextTask()
        }
    }
}

extension HttpMultiTasks: HttpTaskDelegate {
    
    public func taskDidFail(_ task: HttpTask) {
        
    }
    
    public func taskDidSuccess(_ task: HttpTask) {
        
    }
    
    public func taskDidComplete(_ task: HttpTask) {
        dispatchAsyncMainSafe {
            self.taskDiComplete(task, success: task.isApiSuccess || (!task.isNetworkError && self.onlyFlagNetworkError))
        }
    }
}

extension HttpMultiTasks: Equatable {
    
    public static func == (lhs: HttpMultiTasks, rhs: HttpMultiTasks) -> Bool {
        return lhs.id == lhs.id
    }
}

extension HttpMultiTasks: Hashable {

    public func hash(into hasher: inout Hasher) {
        hasher.combine(id)
    }
}
