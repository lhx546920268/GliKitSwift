//
//  ProgressView.swift
//  GliKitSwift
//
//  Created by 罗海雄 on 2020/10/26.
//  Copyright © 2020 luohaixiong. All rights reserved.
//

import UIKit

///进度条样式
public enum ProgressViewStyle {
    ///直线
    case straightLine
    
    ///圆环
    case circle
    
    ///圆饼 从空到满
    case roundCakesFromEmpty
    
    ///圆饼 从满到空
    case roundCakesFromFull
};

///进度条
open class ProgressView: UIView {
    
    ///是否开启进度条 当设置为false时，将重置 progress
    public var openProgress: Bool = true {
        didSet{
            if oldValue != openProgress {
                isHidden = !openProgress
                if !openProgress {
                    reset()
                }
            }
        }
    }
    
    ///当前进度，范围 0.0 ~ 1.0 当 openProgress = false 时，忽略所有设置的值
    public var progress: CGFloat {
        set{
            if openProgress && newValue != _progress {
                if isHidden {
                    isHidden = false
                    self.layer.opacity = 1.0
                }
                if _progress > 1.0 {
                    _progress = 1.0
                }else if progress < 0 {
                    _progress = 0
                }
                
                previousProgress = _progress
                _progress = progress
                
                if previousProgress > _progress {
                    previousProgress = 0
                }
                
                updateProgress()
            }
        }
        get{
            _progress
        }
    }
    private var _progress: CGFloat = 0
    
    ///原来的进度
    private var previousProgress: CGFloat = 0
    
    ///进度条进度颜色
    @NeedLayoutWrapper
    public var progressColor: UIColor = .green
    
    ///进度条轨道颜色
    @NeedLayoutWrapper
    public var trackColor: UIColor = UIColor(white: 0.9, alpha: 1.0)
    
    ///进度条样式
    public private(set) var style: ProgressViewStyle{
        didSet{
            progressLineWidth = style == .circle ? 10 : 3
        }
    }
    
    ///进度条线条大小，当style = circle，default is '10.0'，当 style = roundCakes，default is '3.0'
    @NeedLayoutWrapper
    public var progressLineWidth: CGFloat!
    
    ///是否隐藏 当进度满的时候
    public var hideAfterFinish: Bool = true
    
    ///是否动画隐藏，使用渐变
    public var hideAnimated: Bool = true
    
    ///是否显示百分比 只有当style = circle 时 有效
    public var showPercent: Bool = false {
        didSet{
            if showPercent {
                if percentLabel == nil {
                    let label = UILabel()
                    label.textColor = .black
                    label.font = .systemFont(ofSize: 20)
                    label.textAlignment = .center
                    addSubview(label)
                    
                    label.snp.makeConstraints { (make) in
                        make.center.equalTo(self)
                    }
                    percentLabel = label
                }
            } else {
                percentLabel?.removeFromSuperview()
                percentLabel = nil
            }
        }
    }
    
    ///百分比label, 显示在圆环中间，只有当style = circle && showPercent = true 时 有效
    public var percentLabel: UILabel?
    
    ///进度条layer
    private var progressLayer: CAShapeLayer = {
        let layer = CAShapeLayer()
        layer.fillColor = UIColor.clear.cgColor
        return layer
    }()
    
    ///当前layer
    private var shapeLayer: CAShapeLayer {
        layer as! CAShapeLayer
    }
    
    public init(frame: CGRect = .zero, style: ProgressViewStyle = .straightLine) {
        self.style = style
        super.init(frame: frame)
        initParams()
    }
    
    required public init?(coder: NSCoder) {
        style = .straightLine
        super.init(coder: coder)
        initParams()
    }
    
    open override class var layerClass: AnyClass {
        CAShapeLayer.self
    }
    
    private func initParams() {
        clipsToBounds = true
        isUserInteractionEnabled = false
        backgroundColor = .clear
        
        shapeLayer.fillColor = UIColor.clear.cgColor
    }
    
    open override func layoutSubviews() {
        super.layoutSubviews()
        setupStyle()
        updateProgressLayer()
    }
    
    ///设置样式
    private func setupStyle() {
        
        if !bounds.size.equalTo(.zero) {
            switch style {
            case .circle :
                progressLayer.lineWidth = progressLineWidth
                progressLayer.strokeColor = progressColor.cgColor
                shapeLayer.lineWidth = progressLineWidth
                shapeLayer.strokeColor = trackColor.cgColor
                
            case .straightLine :
                progressLayer.strokeColor = progressColor.cgColor
                progressLayer.lineWidth = bounds.width
                shapeLayer.lineWidth = bounds.height
                shapeLayer.strokeColor = trackColor.cgColor
                
            case .roundCakesFromEmpty :
                progressLayer.fillColor = progressColor.cgColor
                shapeLayer.strokeColor = trackColor.cgColor
                shapeLayer.lineWidth = progressLineWidth
                
            case .roundCakesFromFull :
                progressLayer.fillColor = progressColor.cgColor
                shapeLayer.strokeColor = trackColor.cgColor
                shapeLayer.lineWidth = progressLineWidth
                
            }
        }
    }
    
    ///更新进度条
    private func updateProgress() {
        
        layer.removeAllAnimations()
        progressLayer.removeAllAnimations()
        
        CATransaction.begin()
        
        switch style {
        case .straightLine, .circle :
            percentLabel?.text = "\((_progress * 100).intValue)%"
            progressLayer.strokeEnd = _progress
            
            //动画显示进度条
            let animation = CABasicAnimation(keyPath: "strokeEnd")
            animation.timingFunction = CAMediaTimingFunction(name: .easeOut)
            animation.duration = 0.25
            animation.fromValue = previousProgress
            animation.toValue = _progress
            animation.isRemovedOnCompletion = true
            progressLayer.add(animation, forKey: "progress")
            
        case .roundCakesFromEmpty, .roundCakesFromFull :
            //动画帧数量
            let frames = ceil(0.25 * 60).intValue
            var animatedPaths = [CGPath]()
            
            //起始弧度 、目标弧度
            let startAngle = -CGFloat.pi / 2
            var progress = style == .roundCakesFromEmpty ? _progress : (1 - _progress)
            let endAngle = -CGFloat.pi / 2 + CGFloat.pi * 2 * progress
            
            //当前最新的弧度
            progress = style == .roundCakesFromEmpty ? previousProgress : (1 - previousProgress)
            let lastAngle = -CGFloat.pi / 2 +  CGFloat.pi * 2 * progress
            
            //圆心、半径
            let center = CGPoint(bounds.width / 2, bounds.height / 2)
            let radius = min(bounds.width / 2, bounds.height / 2)
            
            for i in 1...frames {
                let path = UIBezierPath()
                let end = lastAngle + (endAngle - lastAngle) / (frames * i).cgFloatValue
                path.addArc(withCenter: center, radius: radius, startAngle: startAngle, endAngle:end, clockwise: true)
                path.addLine(to: center)
                path.close()
                animatedPaths.append(path.cgPath)
            }
            
            //添加动画
            progressLayer.path = animatedPaths.last
            
            let animation = CAKeyframeAnimation(keyPath: "path")
            animation.values = animatedPaths
            animation.timingFunction = CAMediaTimingFunction(name: .easeOut)
            animation.duration = 0.25
            animation.isRemovedOnCompletion = true
            progressLayer.add(animation, forKey: "path")
        }
        
        if _progress >= 1.0 {
            CATransaction.setCompletionBlock { [weak self] in
                self?.hideProgressIfNeeded()
            }
        }
        CATransaction.commit()
    }
    
    ///动画结束，隐藏进度条
    private func hideProgressIfNeeded() {
        if hideAfterFinish {
            if hideAnimated {
                CATransaction.begin()
                CATransaction.setCompletionBlock { [weak self] in
                    self?.isHidden = true
                    self?.reset()
                }
                
                let animation = CABasicAnimation(keyPath: "opacity")
                animation.duration = 0.25
                animation.fromValue = 1.0
                animation.toValue = 0
                layer.add(animation, forKey: "opacity")
                
                CATransaction.commit()
            }
        }
    }
    
    ///重新设置
    private func reset() {
        previousProgress = 0
        progress = 0
    }
    
    ///更新进度条样式
    private func updateProgressLayer() {
        let size = bounds.size
        if !size.equalTo(.zero) {
            let path: UIBezierPath =  UIBezierPath()
            switch style {
            case .straightLine :
                path.move(to: CGPoint(0, size.height / 2))
                path.addLine(to: CGPoint(size.width, size.height / 2))
                
            default :
                let center = CGPoint(size.width / 2, size.height / 2)
                let radius = min(size.width / 2, size.height / 2) - progressLineWidth / 2
                path.addArc(withCenter: center, radius: radius, startAngle: -CGFloat.pi / 2, endAngle: 3 * CGFloat.pi / 2, clockwise: true)
            }
            
            if style != .roundCakesFromEmpty && style != .roundCakesFromFull {
                progressLayer.path = path.cgPath
            }
            
            shapeLayer.path = path.cgPath
            updateProgress()
        }
    }
}
