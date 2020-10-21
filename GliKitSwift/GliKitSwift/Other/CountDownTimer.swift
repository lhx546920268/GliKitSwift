//
//  CountDownTimer.swift
//  GliKitSwift
//
//  Created by 罗海雄 on 2020/7/20.
//  Copyright © 2020 luohaixiong. All rights reserved.
//

import UIKit


/**
 倒计时 单位（秒）
 当不使用倒计时，需要自己手动停止倒计时，或者在时间到后会自己停止
 UIView 可在 - (void)willMoveToWindow:newWindow 中，newWindow不为空时开始倒计时，空时结束倒计时
 */
open class CountDownTimer {
    
    ///倒计时没有限制
    public static let countDownInfinite = TimeInterval.greatestFiniteMagnitude
    
    ///倒计时总时间长度，如果为 countDownInfinite 则 没有限制，倒计时不会停止 必须自己手动停止
    ///设置不同的时间会导致倒计时结束 且不会有回调
    public var timeToCountDown: TimeInterval {
        didSet {
            if oldValue != self.timeInterval {
                stop()
            }
        }
    }
    
    ///是否是无限的
    public var isInfinite: Bool {
        timeToCountDown == CountDownTimer.countDownInfinite
    }
    
    ///倒计时是否马上开始 默认 是 timeInterval 后只需第一次回调
    public var shouldStartImmediately: Bool = true
    
    ///倒计时间隔
    ///设置不同的时间会导致倒计时结束 且不会有回调
    public var timeInterval: TimeInterval {
        didSet{
            if oldValue != self.timeInterval {
                stop()
            }
        }
    }
    
    ///当前已进行的倒计时秒数
    public private(set) var ongoingTimeInterval: TimeInterval = 0
    
    ///倒计时是否正在执行
    public private(set) var isExcuting: Bool = false
    
    ///触发倒计时回调，timeLeft 剩余倒计时时间
    public var onTick: ((_ timeLeft: TimeInterval) -> Void)?
    
    ///倒计时完成回调
    public var onComplete: VoidCallback?
    
    ///倒计时停止时间
    private var timeToStop: TimeInterval = 0

    ///倒计时是否已取消
    private var isCancelled: Bool = false

    ///代理
    private let timerProxy: TimerProxy = TimerProxy()

    init(timeToCountDown: TimeInterval, interval: TimeInterval) {
        self.timeToCountDown = timeToCountDown
        self.timeInterval = interval
        self.timerProxy.onTick = { [weak self] in
            self?._onTick()
        }
    }
    
    deinit {
        removeNotifications()
        timerProxy.stopTimer()
    }
    
    ///开始倒计时
    public func start() {
        
        DispatchQueue.synchronized(token: self) {
            if isExcuting {
                return
            }
            self.isCancelled = false
            self.ongoingTimeInterval = 0
            if self.timeToCountDown <= 0 || self.timeInterval <= 0 {
                finish()
                return
            }
            
            self.timeToStop = self.timeToCountDown
            isExcuting = true
            
            if shouldStartImmediately {
                _onTick()
            }
            
            if isExcuting {
                timerProxy.startTimer(with: timeInterval)
                addNotifications()
            }
        }
    }
    
    /// 回调
    private func _onTick() {
        
        if isExcuting {
            ongoingTimeInterval += timeInterval
            if isInfinite {
                onTick?(CountDownTimer.countDownInfinite)
            } else {
                timeToStop -= timeInterval
                if timeToStop <= 0 {
                    finish()
                } else {
                    onTick?(timeToStop)
                }
            }
        }
    }
    
    ///结束倒计时
    public func stop() {
        
        DispatchQueue.synchronized(token: self) {
            if !isExcuting || isCancelled {
                return
            }
            isCancelled = true
            isExcuting = false
            timerProxy.stopTimer()
            removeNotifications()
        }
    }
    
    ///倒计时完成
    private func finish() {
        isExcuting = false
        removeNotifications()
        timerProxy.stopTimer()
        onComplete?()
    }

    ///app 停止时间
    private var date: Date?
    
    // MARK: - 通知

    ///添加通知 app进入后台 手机锁屏后 来电 计时器会停止
    private func addNotifications() {
        NotificationCenter.default.addObserver(self, selector: #selector(applicationWillResignActive), name: UIApplication.willResignActiveNotification, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(applicationDidBecomeActive), name: UIApplication.didBecomeActiveNotification, object: nil)
    }
    
    ///移除通知
    private func removeNotifications() {
        NotificationCenter.default.removeObserver(self)
    }
    
    @objc
    private func applicationWillResignActive() {
        self.date = Date()
    }
    
    @objc
    private func applicationDidBecomeActive() {
        
        //app唤醒了 根据前面保存的时间来触发对应回调
        if self.date != nil {
            let timeInterval = Date().timeIntervalSince(self.date!)
            if isInfinite {
                if timeInterval >= self.timeInterval {
                    onTick?(CountDownTimer.countDownInfinite)
                }
            } else {
                timeToStop -= timeInterval
                if timeToStop <= 0 {
                    finish()
                } else if timeInterval >= self.timeInterval {
                    onTick?(timeToStop)
                }
            }
            self.date = nil
        }
    }
    
    ///计时器代理，防止循环引用
    private class TimerProxy{
        
        ///倒计时
        var timer: Timer?
        
        ///回调
        var onTick: VoidCallback?
        
        ///开始计时器
        func startTimer(with timeInterval: TimeInterval) {
            
            stopTimer()
            timer = Timer(timeInterval: timeInterval, target: self, selector: #selector(handleTimer), userInfo: nil, repeats: true)
            RunLoop.main.add(timer!, forMode: .common)
        }
        
        ///停止计时器
        func stopTimer() {
            if self.timer != nil && self.timer!.isValid {
                self.timer!.invalidate()
                self.timer = nil
            }
        }
        
        ///
        @objc
        private func handleTimer() {
            onTick?()
        }
    }
}



