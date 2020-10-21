//
//  ProgressHUD.swift
//  GliKitSwift
//
//  Created by 罗海雄 on 2020/1/20.
//  Copyright © 2020 luohaixiong. All rights reserved.
//

import UIKit

///状态
public enum ProgressHUDStatus {
    
    ///隐藏 什么都没
    case none
    
    ///加载中
    case loading
    
    ///提示错误信息
    case error
    
    ///提示成功信息
    case success
    
    ///警告
    case warning
}

///加载指示器代理
public protocol ProgressHUDProtocol: UIView {
    
    ///提示信息
    var text: String? {get set}
    
    ///内容视图是否延迟显示 0 不延迟
    var delay: Double {get set}
    
    ///状态
    var status: ProgressHUDStatus {get set}
    
    ///消失回调
    var dismissCallback: (() -> Void)? {get set}
    
    ///显示
    func show()
    
    ///关闭 loading
    func dismissProgress()
    
    ///关闭所有
    func dismiss()
}

///加载指示器 和 提示信息
open class ProgressHUD: UIView, ProgressHUDProtocol {
    
    ///垂直间距
    private static let progressHUDVerticalSpacing: CGFloat = 12

    ///水平间距
    private static let progressHUDHorizontalSpacing: CGFloat = 12

    ///文字间距
    private static let progressHUDLabelSpacing: CGFloat = 8
    
    ///黑色半透明背景视图
    public private(set) lazy var translucentView: UIView = {
        
        let view = UIView()
        view.layer.cornerRadius = 14
        view.layer.masksToBounds = true
        view.backgroundColor = UIColor.gkColor(red: 50, green: 50, blue: 50, alpha: 0.7)
        addSubview(view)
        
        return view
    }()
    
    ///提示信息
    public private(set) lazy var textLabel: UILabel = {
        
        let label = UILabel()
        label.textAlignment = .center
        label.backgroundColor = .clear
        label.font = font
        label.textColor = .white
        label.text = text
        label.numberOfLines = 0
        translucentView.addSubview(label)
        
        return label
    }()
    
    ///加载指示器
    public private(set) lazy var indicatorView: UIActivityIndicatorView = {
        let view = UIActivityIndicatorView(style: .whiteLarge)
        translucentView.addSubview(view)
        return view
    }()
    
    ///提示图标
    public private(set) lazy var imageView: UIImageView = {
        let imageView = UIImageView()
        translucentView.addSubview(imageView)
        return imageView
    }()
    
    ///文字大小
    private var textSize = CGSize.zero

    ///字体
    public var font = UIFont.systemFont(ofSize: 14)

    ///提示框最小
    public var minimumSize = CGSize(width: 200, height: 116)

    ///提示框最大
    public var maximumSize = CGSize(width: 200, height: 300)

    ///计时器延迟
    private var timer: Timer?
    
    // MARK: - ProgressHUDProtocol
    
    public var text: String? {
        didSet{
            if oldValue != text {
                textDidChange()
            }
        }
    }
    
    public var delay: TimeInterval = 0
    
    public var status: ProgressHUDStatus = .none{
        didSet{
            if oldValue != status {
                statusDidChange()
            }
        }
    }
    
    public var dismissCallback: (() -> Void)?
    
    public func show() {
        
        if status != .none {
            switch status {
            case .error, .success, .warning :
                
                startTimer(interval: delay)
            case .loading :
                
                //如果本身已经显示了，就不要延迟了
                if delay > 0 && translucentView.isHidden{
                    startTimer(interval: delay)
                }else{
                    delayShow()
                }
            default: break
            }

            setNeedsLayout()
        }
    }
    
    public func dismissProgress() {
        
        if status == .loading {
            dismiss()
        }
    }
    
    public func dismiss() {
        
        stopTimer()
        UIView.animate(withDuration: 0.25, animations: {
            
            self.translucentView.alpha = 0
        }) { _ in
            self.isHidden = true
            self.dismissCallback?()
        }
    }
    
    ///延迟显示
    private func delayShow(){
        
        translucentView.isHidden = false
        indicatorView.startAnimating()
        setNeedsLayout()
    }

    // MARK: - timer

    ///开始计时器
    private func startTimer(interval: Double){
        
        stopTimer()
        timer = Timer(timeInterval: interval, target: self, selector: #selector(self.handleTimer), userInfo: nil, repeats: false)
        RunLoop.main.add(timer!, forMode: .common)
    }

    ///停止计时器
    private func stopTimer(){
        timer?.invalidate()
        timer = nil
    }

    ///倒计时
    @objc private func handleTimer(){
        
        stopTimer()
        switch status {
        case .loading :
            delayShow()
        case .success, .error, .warning :
            dismiss()
        case .none :
            break
        }
    }

    // MARK: - property

    ///文字改变
    private func textDidChange() {
        
        if text != nil {
            textSize = text!.gkStringSize(font: font, with: maximumSize.width - ProgressHUD.progressHUDHorizontalSpacing * 2)
        } else {
            textSize = CGSize.zero
        }
        
        textSize.width = max(minimumSize.width - ProgressHUD.progressHUDHorizontalSpacing * 2, textSize.width)
        textSize.height = min(maximumSize.height, textSize.height)
      
        textLabel.text = text
    }

    ///状态改变
    private func statusDidChange() {
        
        switch status {
        case .error, .success, .warning :
            
            isUserInteractionEnabled = false
            isHidden = false
            imageView.isHidden = false
            translucentView.isHidden = false
            indicatorView.stopAnimating()
        case .loading :
            
            isUserInteractionEnabled = true
            isHidden = false
            imageView.isHidden = true
        case .none :
            isHidden = true
        }
    }
    
    open override func layoutSubviews() {
        super.layoutSubviews()
        
        if status != .none && !CGSize.zero.equalTo(bounds.size) {
            
            let imageUse = status == .error || status == .success || status == .warning
            let indicatorUse = status == .loading
            let textUse = !String.isEmpty(text)
            
            var realContentWidth = ProgressHUD.progressHUDHorizontalSpacing * 2
            var realConetnHeight: CGFloat = 0
            
            if imageUse {
                realConetnHeight += imageView.gkHeight
                realContentWidth = max(textUse ? textSize.width : 0, indicatorView.gkWidth)
            }else if indicatorUse {
                realConetnHeight += indicatorView.gkHeight
                realContentWidth = min(textUse ? textSize.width : 0, indicatorView.gkWidth)
            }
            
            if textUse {
                realConetnHeight += ProgressHUD.progressHUDLabelSpacing + textSize.height
            }
            
            let contentWidth = max(realContentWidth, minimumSize.width)
            let contentHeight = max(minimumSize.height, realConetnHeight + ProgressHUD.progressHUDVerticalSpacing * 2)
            
            translucentView.frame = CGRect(x: (self.gkWidth - contentWidth) / 2.0, y: (self.gkHeight - contentHeight) / 2.0, width: contentWidth, height: contentHeight)
            
            var y = (contentHeight - realConetnHeight) / 2
            if imageUse {
                imageView.center = CGPoint(x: contentWidth / 2, y: y + imageView.gkHeight / 2.0)
                y += imageView.gkHeight
            }else if indicatorUse {
                indicatorView.center = CGPoint(x: contentWidth / 2, y: y + indicatorView.gkHeight / 2.0)
                y += indicatorView.gkHeight
            }
            
            if(textUse){
                textLabel.frame = CGRect(x: (contentWidth - realContentWidth) / 2, y: y + ProgressHUD.progressHUDLabelSpacing, width: textSize.width, height: textSize.height)
            }
        }
    }
}
