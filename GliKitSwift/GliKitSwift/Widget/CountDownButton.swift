//
//  CountDownButton.swift
//  GliKitSwift
//
//  Created by 罗海雄 on 2020/11/5.
//  Copyright © 2020 luohaixiong. All rights reserved.
//

import UIKit

///倒计时按钮
open class CountDownButton: UIButton {
    
    ///正常时 UIControlStateNormal 按钮背景颜色
    public var normalBackgroundColor: UIColor = .clear {
        didSet{
            if isTiming {
                self.backgroundColor = normalBackgroundColor
            }
        }
    }
    
    ///倒计时 UIControlStateDisable 按钮背景颜色
    public var disableBackgroundColor: UIColor = .clear {
        didSet{
            if !isTiming {
                self.backgroundColor = disableBackgroundColor
            }
        }
    }
    
    ///倒计时结束回调
    public var completion: (() -> Void)?
    
    ///倒计时回调 timeLeft 剩余时间
    public var countDownCallback: ((_ timeLeft: TimeInterval) -> Void)?
    
    ///倒计时长 单位秒
    public var countdownTimeInterval: TimeInterval = 60
    
    ///是否正在计时
    public var isTiming: Bool {
        timer?.isExcuting ?? false
    }
    
    ///计时器
    private var timer: CountDownTimer?
    
    public override init(frame: CGRect) {
        super.init(frame: frame)
        initParams()
    }
    
    public required init?(coder: NSCoder) {
        super.init(coder: coder)
        initParams()
    }
    
    ///开始计时
    public func startTimer() {
        if timer == nil {
            timer = CountDownTimer(timeToCountDown: countdownTimeInterval, interval: 1)
            timer?.shouldStartImmediately = true
            timer?.onComplete = { [weak self] in
                self?.onFinish()
            }
            timer?.onTick = { [weak self] (timeLeft) in
                self?.countDown(timeLeft)
            }
        }
        timer?.start()
        onStart()
    }
    
    ///停止计时
    public func stopTimer() {
        if timer != nil {
            timer?.stop()
            onFinish()
        }
    }
    
    ///初始化
    open func initParams() {
        setTitleColor(.gkThemeColor, for: .normal)
        titleLabel?.font = .systemFont(ofSize: 14)
        titleLabel?.numberOfLines = 0
        titleLabel?.textAlignment = .center
        
        layer.borderColor = UIColor.gkThemeColor.cgColor
        setTitle("获取验证码", for: .normal)
        setTitleColor(.gray, for: .disabled)
    }
    
    ///倒计时开始
    public func onStart() {
        isEnabled = false
        backgroundColor = disableBackgroundColor
        layer.borderColor = currentTitleColor.cgColor
    }
    
    ///倒计时完成
    public func onFinish() {
        setTitle("重新获取", for: .normal)
        isEnabled = true
        backgroundColor = normalBackgroundColor
        layer.borderColor = currentTitleColor.cgColor
        completion?()
    }
    
    private func countDown(_ timeLeft: TimeInterval) {
        setTitle("重新获取(\(timeLeft.intValue)s)", for: .disabled)
        countDownCallback?(timeLeft)
    }
}
